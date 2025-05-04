//
//  NotificationsRepositoryLive.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 03.05.25.
//

import BackgroundRefreshClient
import Common
import Dependencies
import Foundation
import PersistenceClient
import RSSClient
import SharedModels
import UserDefaultsClient
import UserNotificationClient

extension NotificationRepository {
    public static func live() -> NotificationRepository {
        @Dependency(\.userNotifications) var userNotifications
        @Dependency(\.backgroundRefresh) var backgroundRefresh
        @Dependency(\.persistenceClient.loadFeeds) var loadFeeds
        @Dependency(\.rssClient.fetchFeedItems) var fetchFeedItems
        @Dependency(\.userDefaults) var userDefaults
        
        return NotificationRepository(
            requestPermissions: {
                let authorized = try await userNotifications.requestAuthorization([.alert, .sound, .badge])
                if authorized {
                    await backgroundRefresh.scheduleAppRefresh()
                }
            },
            checkForNewItems: {
                let settings = await userNotifications.getNotificationSettings()
                guard settings.authorizationStatus == .authorized else {
                    throw NotificationError.permissionDenied
                }
                
                let feeds = try await loadFeeds()
                let enabledFeeds = feeds.filter(\.notificationsEnabled)
                
                guard !enabledFeeds.isEmpty else { return }
                
                let currentTime = Date()
                let lastCheckTime = userDefaults.getLastNotificationCheckTime() ?? currentTime
                
                userDefaults.setLastNotificationCheckTime(currentTime)
                
                var delayOffset = 0.5
                
                for feed in enabledFeeds {
                    do {
                        let items = try await fetchFeedItems(feed.url)
                        
                        let newItems = items.filter { item in
                            guard let pubDate = item.pubDate else { return false }
                            return pubDate > lastCheckTime
                        }
                        
                        for item in newItems {
                            try await scheduleNotificationForItem(item, from: feed, delayOffset: delayOffset)
                            delayOffset += 0.5
                        }
                    } catch {
                        print("Error fetching items for feed \(feed.url): \(error)")
                    }
                }
            },
            notificationsAuthorized: {
                let settings = await userNotifications.getNotificationSettings()
                return settings.authorizationStatus == .authorized
            },
            scheduleNotificationForItem: { item, feed in
                try await scheduleNotificationForItem(item, from: feed, delayOffset: 1.0)
            },
            manuallyTriggerBackgroundRefresh: {
                await backgroundRefresh.manuallyTriggerBackgroundRefresh()
            },
            activateBackgroundRefresh: {
                await backgroundRefresh.scheduleAppRefresh()
            },
            getNotificationStatus: {
                await userNotifications.getNotificationStatusDescription()
            },
            sendDelayedNotification: { seconds in
                try await userNotifications.sendTestNotification(
                    "Delayed Test Notification",
                    "This notification was scheduled \(seconds) seconds ago",
                    TimeInterval(seconds)
                )
            },
            testFeedParsing: {
                await backgroundRefresh.testFeedParsing()
            },
            getPendingNotifications: {
                let requests = await userNotifications.pendingNotificationRequests()
                return requests.map { "[\($0.identifier)] \($0.content.title) - \($0.content.body)" }
            }
        )
        
        @Sendable
        func scheduleNotificationForItem(
            _ item: FeedItem,
            from feed: Feed,
            delayOffset: Double
        ) async throws {
            let request = UserNotificationClient.NotificationRequest(
                id: "notification-\(feed.url.absoluteString)-\(item.id.uuidString)",
                title: feed.title ?? "New item in feed",
                body: item.title,
                sound: .default,
                userInfo: ["feedURL": feed.url.absoluteString, "itemURL": item.link.absoluteString],
                threadIdentifier: feed.url.absoluteString
            )
            
            try await userNotifications.addNotificationRequest(request)
        }
    }
}
