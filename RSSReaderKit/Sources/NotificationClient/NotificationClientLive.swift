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
        print("🔔 Checking \(enabledFeeds.count) enabled feeds for updates")

        // Store current check time before processing
        let currentCheck = Date()
        let lastCheck = UserDefaults.standard.object(
            forKey: Constants.Storage.lastNotificationCheckKey
        ) as? Date ?? Date.distantPast

        print("🔔 Last check was at: \(lastCheck)")

        // Get stored notification IDs
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

        // Update state only if we processed feeds successfully
        UserDefaults.standard.set(currentCheck, forKey: Constants.Storage.lastNotificationCheckKey)

        // Manage notification IDs
        let updatedIDs = (notifiedItemIDs + newNotifiedItemIDs)
            .suffix(Constants.Notifications.pruneToCount)
        UserDefaults.standard.set(Array(updatedIDs), forKey: Constants.Storage.notifiedItemsKey)

        print("🔔 Check complete. New notifications: \(newNotifiedItemIDs.count)")
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
                print("🔔 Checking feed: \(feed.title ?? feed.url.absoluteString)")
                let items = try await fetchFeedItems(feed.url)

                let newItems = items.filter { item in
                    guard let pubDate = item.pubDate else {
                        print("🔔 Item has no publication date: \(item.title)")
                        return false
                    }

                    let isNew = pubDate > lastCheck
                    let isNotNotified = !notifiedItemIDs.contains(item.id.uuidString)

                    if isNew {
                        print("🔔 Found new item: \(item.title) published at \(pubDate)")
                    }

                    return isNew && isNotNotified
                }

                print("🔔 Found \(newItems.count) new items in feed")

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
            } catch {
                print("🔔 Error processing feed \(feed.url): \(error)")
            }
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

            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: delayOffset,
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: "notification-\(item.id.uuidString)",
                content: content,
                trigger: trigger
            )

            print("🔔 Scheduling notification for: \(item.title)")
            center.add(request) { error in
                if let error = error {
                    print("🔔 Failed to schedule notification: \(error)")
                    continuation.resume(throwing: error)
                } else {
                    print("🔔 Successfully scheduled notification")
                    continuation.resume()
                }
            }
        }
    }
}

// MARK: - Dependencies

private enum NotificationCenterKey: DependencyKey {
    static let liveValue = UNUserNotificationCenter.current()
}

extension DependencyValues {
    var notificationCenter: UNUserNotificationCenter {
        get { self[NotificationCenterKey.self] }
        set { self[NotificationCenterKey.self] = newValue }
    }
}
