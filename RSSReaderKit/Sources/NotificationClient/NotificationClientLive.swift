//
//  NotificationClientLive.swift
//  RSSReaderKit

import Common
import Dependencies
import Foundation
import PersistenceClient
import RSSClient
import SharedModels
import UserDefaultsClient
@preconcurrency import UserNotifications


extension NotificationClient {
    public static func live() -> NotificationClient {
        @Dependency(\.notificationCenter) var notificationCenter

        return NotificationClient(
            requestPermissions: {
                try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            },
            checkForNewItems: {
                try await checkForNewItems()
            }
        )
    }
    
    private static func checkForNewItems() async throws {
        guard await notificationsAuthorized() else {
            throw NotificationError.permissionDenied
        }

        @Dependency(\.persistenceClient.loadFeeds) var loadFeeds
        let feeds = try await loadFeeds()
        let enabledFeeds = feeds.filter(\.notificationsEnabled)
        
        guard !enabledFeeds.isEmpty else { return }
        let currentTime = Date()
        @Dependency(\.userDefaults) var userDefaults
        let lastCheckTime = userDefaults.getLastNotificationCheckTime() ?? currentTime
        
        userDefaults.setLastNotificationCheckTime(currentTime)
        
        try await processFeeds(
            enabledFeeds,
            lastCheckTime: lastCheckTime
        )
    }

    private static func processFeeds(
        _ feeds: [Feed],
        lastCheckTime: Date
    ) async throws {
        var delayOffset = 0.5
        
        @Dependency(\.rssClient.fetchFeedItems) var fetchFeedItems
        for feed in feeds {
            do {
                let items = try await fetchFeedItems(feed.url)

                let newItems = items.filter { item in
                    guard let pubDate = item.pubDate else { return false }
                    return pubDate > lastCheckTime
                }

                for item in newItems {
                    try await scheduleNotification(
                        for: item,
                        from: feed,
                        delayOffset: delayOffset
                    )
                    delayOffset += 0.5
                }
            } catch {
                print("Error fetching items for feed \(feed.url): \(error)")
            }
        }
    }

    private static func scheduleNotification(
        for item: FeedItem,
        from feed: Feed,
        delayOffset: Double
    ) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let content = UNMutableNotificationContent()
            content.title = feed.title ?? "New item in feed"
            content.body = item.title
            content.sound = .default
            content.threadIdentifier = feed.url.absoluteString

            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: delayOffset,
                repeats: false
            )

            let requestId = "notification-\(feed.url.absoluteString)-\(item.id.uuidString)"
            
            let request = UNNotificationRequest(
                identifier: requestId,
                content: content,
                trigger: trigger
            )
            @Dependency(\.notificationCenter) var center
            center.add(request) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    public static func notificationsAuthorized() async -> Bool {
        @Dependency(\.notificationCenter) var center
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .authorized
    }
}

private enum NotificationCenterKey: DependencyKey {
    static let liveValue = UNUserNotificationCenter.current()
}

extension DependencyValues {
    var notificationCenter: UNUserNotificationCenter {
        get { self[NotificationCenterKey.self] }
        set { self[NotificationCenterKey.self] = newValue }
    }
}
