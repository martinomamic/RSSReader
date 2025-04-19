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
        @Dependency(\.notificationCenter) var notificationCenter
        @Dependency(\.persistenceClient.loadFeeds) var loadFeeds
        @Dependency(\.rssClient.fetchFeedItems) var fetchFeedItems

        return NotificationClient(
            requestPermissions: {
                try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            },
            checkForNewItems: {
                try await checkForNewItems(
                    center: notificationCenter,
                    loadFeeds: loadFeeds,
                    fetchFeedItems: fetchFeedItems
                )
            }
        )
    }

    private static func checkForNewItems(
        center: UNUserNotificationCenter,
        loadFeeds: @escaping () async throws -> [Feed],
        fetchFeedItems: @escaping (URL) async throws -> [FeedItem]
    ) async throws {
        guard await center.notificationSettings().authorizationStatus == .authorized else {
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
            newNotifiedItemIDs: &newNotifiedItemIDs,
            center: center,
            fetchFeedItems: fetchFeedItems
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
        newNotifiedItemIDs: inout [String],
        center: UNUserNotificationCenter,
        fetchFeedItems: @escaping (URL) async throws -> [FeedItem]
    ) async throws {
        var delayOffset = 0.5

        for feed in feeds {
            do {
                let items = try await fetchFeedItems(feed.url)

                let newItems = items.filter { item in
                    guard let pubDate = item.pubDate else { return false }
                    return pubDate > lastCheck && !notifiedItemIDs.contains(item.id.uuidString)
                }

                for item in newItems {
                    try await scheduleNotification(
                        for: item,
                        from: feed,
                        delayOffset: delayOffset,
                        center: center
                    )
                    newNotifiedItemIDs.append(item.id.uuidString)
                    delayOffset += 0.5
                }
            } catch { }
        }
    }

    private static func scheduleNotification(
        for item: FeedItem,
        from feed: Feed,
        delayOffset: Double,
        center: UNUserNotificationCenter
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
                identifier: "notification-\(item.id.uuidString)",
                content: content,
                trigger: trigger
            )

            center.add(request) { error in
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
