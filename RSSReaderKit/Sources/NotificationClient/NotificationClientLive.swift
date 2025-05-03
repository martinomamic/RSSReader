//
//  NotificationClientLive.swift
//  RSSReaderKit

import Common
import Dependencies
import Foundation
import SharedModels
@preconcurrency import UserNotifications
import PersistenceClient
import RSSClient

extension NotificationClient {
    public static func live() -> NotificationClient {
        @Dependency(\.notificationCenter) var notificationCenter
        @Dependency(\.persistenceClient.loadFeeds) var loadFeeds
        @Dependency(\.rssClient.fetchFeedItems) var fetchFeedItems

        return NotificationClient(
            requestPermissions: {
                try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            },
            checkForNewItems: {
                try await checkForNewItems(
                    loadFeeds: loadFeeds,
                    fetchFeedItems: fetchFeedItems
                )
            }
        )
    }

    private static func checkForNewItems(
        loadFeeds: @escaping () async throws -> [Feed],
        fetchFeedItems: @escaping (URL) async throws -> [FeedItem]
    ) async throws {
        guard await notificationsAuthorized() else {
            throw NotificationError.permissionDenied
        }

        let feeds = try await loadFeeds()
        let enabledFeeds = feeds.filter(\.notificationsEnabled)
        
        let lastCheckTime = UserDefaults.standard.object(
            forKey: Constants.Storage.lastNotificationCheckKey
        ) as? Date ?? Date()
        
        let isFirstCheck = lastCheckTime == Date()
        
        let currentTime = Date()
        UserDefaults.standard.set(currentTime, forKey: Constants.Storage.lastNotificationCheckKey)
        
        if !isFirstCheck {
            try await processFeeds(
                enabledFeeds,
                lastCheckTime: lastCheckTime,
                fetchFeedItems: fetchFeedItems
            )
        }
    }

    private static func processFeeds(
        _ feeds: [Feed],
        lastCheckTime: Date,
        fetchFeedItems: @escaping (URL) async throws -> [FeedItem]
    ) async throws {
        var delayOffset = 0.5

        for feed in feeds {
            do {
                let items = try await fetchFeedItems(feed.url)

                let newItems = items.filter { item in
                    guard let pubDate = item.pubDate else
                    {
                        return false
                    }
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
            } catch { }
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

            let request = UNNotificationRequest(
                identifier: "notification-\(UUID().uuidString)",
                content: content,
                trigger: trigger
            )
            @Dependency(\.notificationCenter) var notificationCenter
            notificationCenter.add(request) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    public static func notificationsAuthorized() async -> Bool {
        @Dependency(\.notificationCenter) var notificationCenter
        let settings = await notificationCenter.notificationSettings()
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
