//
//  NotificationClientLive.swift
//  RSSReaderKit
//
//  REFACTORED: simplified dependency usage & last‑fetch logic
//

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
                print("🔍 [NotificationClient] Starting checkForNewItems...")
                try await checkForNewItems(
                    center: notificationCenter,
                    loadFeeds: loadFeeds,
                    fetchFeedItems: fetchFeedItems
                )
            },
            checkAuthorizationStatus: {
                await notificationCenter.notificationSettings().authorizationStatus
            }
        )
    }

    private static func checkForNewItems(
        center: UNUserNotificationCenter,
        loadFeeds: @escaping () async throws -> [Feed],
        fetchFeedItems: @escaping (URL) async throws -> [FeedItem]
    ) async throws {
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized else {
            print("⚠️ [NotificationClient] Notification permission denied.")
            throw NotificationError.permissionDenied
        }

        let feeds = try await loadFeeds()
        print("📦 [NotificationClient] Loaded feeds: \(feeds.count)")
        let enabledFeeds = feeds.filter(\.notificationsEnabled)
        print("🔔 [NotificationClient] Feeds with notifications enabled: \(enabledFeeds.count)")
        
        guard !enabledFeeds.isEmpty else {
            print("🛑 [NotificationClient] No feeds with notifications enabled.")
            return
        }

        try await processFeeds(
            enabledFeeds,
            center: center,
            fetchFeedItems: fetchFeedItems
        )
    }

    private static func processFeeds(
        _ feeds: [Feed],
        center: UNUserNotificationCenter,
        fetchFeedItems: @escaping (URL) async throws -> [FeedItem]
    ) async throws {
        var delayOffset = 0.5

        for var feed in feeds {
            do {
                print("➡️ [NotificationClient] Processing feed: \(feed.title ?? feed.url.absoluteString)")
                let items = try await fetchFeedItems(feed.url)
                print("  - Total items fetched: \(items.count)")
                let cutoffDate = feed.lastFetchDate ?? Date()
                // --- SIMULATION PATCH START ---
                // To simulate new RSS items for every refresh, uncomment the next line:
                 let newItems = items.prefix(1) // always pretend the first item is 'new'
                // To restore normal behavior, comment out/remove above and use:
//                let newItems = items.filter { item in
//                    guard let pubDate = item.pubDate else { return false }
//                    return pubDate > cutoffDate
//                }
                // --- SIMULATION PATCH END ---
                print("  - New items found: \(newItems.count) (cutoff: \(cutoffDate))")

                for item in newItems {
                    print("    🆕 Scheduling notification for item: \(item.title) (\(item.id))")
                    try await scheduleNotification(
                        for: item,
                        from: feed,
                        delayOffset: delayOffset,
                        center: center
                    )
                    delayOffset += 0.5
                }

                feed.lastFetchDate = Date()
                @Dependency(\.persistenceClient) var persistenceClient
                try await persistenceClient.updateFeed(feed)
                print("  ▶️ Updated feed lastFetchDate to now")
            } catch {
                print("❌ Notification check error for \(feed.url): \(error)")
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
