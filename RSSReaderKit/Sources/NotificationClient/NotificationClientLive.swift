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
import UIKit

extension NotificationClient {
    public static func live() -> NotificationClient {
        NotificationClient(
            requestPermissions: {
                @Dependency(\.notificationCenter) var notificationCenter
                try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            },
            checkForNewItems: {
                try await checkForNewItems()
            },
            getAuthorizationStatus: {
                @Dependency(\.notificationCenter) var notificationCenter
                let settings = await notificationCenter.notificationSettings()
                return settings.authorizationStatus == .authorized
            },
            scheduleNotification: { content in
                try await scheduleNotification(content: content)
            }
        )
    }

    private static func checkForNewItems() async throws {
        @Dependency(\.notificationCenter) var notificationCenter
        @Dependency(\.persistenceClient.loadFeeds) var loadFeeds
        @Dependency(\.rssClient.fetchFeedItems) var fetchFeedItems
        
        guard await notificationCenter.notificationSettings().authorizationStatus == .authorized else {
            throw NotificationError.permissionDenied
        }

        let feeds = try await loadFeeds()
        let enabledFeeds = feeds.filter(\.notificationsEnabled)

        let currentCheck = Date()
        let lastCheck = UserDefaults.standard.object(
            forKey: Constants.Storage.lastNotificationCheckKey
        ) as? Date ?? Date.distantPast

        let notifiedItemIDs = UserDefaults.standard.stringArray(
            forKey: Constants.Storage.notifiedItemsKey
        ) ?? []

        var newNotifiedItemIDs = [String]()
        try await processFeeds(
            enabledFeeds,
            lastCheck: lastCheck,
            notifiedItemIDs: notifiedItemIDs,
            newNotifiedItemIDs: &newNotifiedItemIDs
        )

        UserDefaults.standard.set(currentCheck, forKey: Constants.Storage.lastNotificationCheckKey)

        let updatedIDs = (notifiedItemIDs + newNotifiedItemIDs)
            .suffix(Constants.Notifications.pruneToCount)
        UserDefaults.standard.set(Array(updatedIDs), forKey: Constants.Storage.notifiedItemsKey)
    }

    private static func processFeeds(
        _ feeds: [Feed],
        lastCheck: Date,
        notifiedItemIDs: [String],
        newNotifiedItemIDs: inout [String]
    ) async throws {
        @Dependency(\.rssClient.fetchFeedItems) var fetchFeedItems
        
        var delayOffset = 0.5

        for feed in feeds {
            do {
                let items = try await fetchFeedItems(feed.url)

                let newItems = items.filter { item in
                    guard let pubDate = item.pubDate else { return false }
                    return pubDate > lastCheck && !notifiedItemIDs.contains(item.id.uuidString)
                }

                for item in newItems {
                    let content = NotificationContent(
                        title: feed.title ?? "New item in feed",
                        body: item.title,
                        threadIdentifier: feed.url.absoluteString,
                        identifier: "notification-\(item.id.uuidString)",
                        delayInterval: delayOffset
                    )
                    try await scheduleNotification(content: content)
                    newNotifiedItemIDs.append(item.id.uuidString)
                    delayOffset += 0.5
                }
            } catch { }
        }
    }

    private static func scheduleNotification(content: NotificationContent) async throws {
        @Dependency(\.notificationCenter) var notificationCenter
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let notificationContent = UNMutableNotificationContent()
            notificationContent.title = content.title
            notificationContent.body = content.body
            notificationContent.sound = .default
            notificationContent.threadIdentifier = content.threadIdentifier

            let trigger = content.delayInterval.map {
                UNTimeIntervalNotificationTrigger(timeInterval: $0, repeats: false)
            }

            let request = UNNotificationRequest(
                identifier: content.identifier,
                content: notificationContent,
                trigger: trigger
            )

            notificationCenter.add(request) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
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
