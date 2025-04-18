//
//  NotificationClientLive.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 17.04.25.
//

import Common
import Dependencies
import Foundation
import SharedModels
import UserNotifications
import PersistenceClient
import RSSClient
import UIKit

extension NotificationClient {
    public static func live() -> NotificationClient {
        @Dependency(\.persistenceClient)
        var persistenceClient
        
        @Dependency(\.rssClient)
        var rssClient
        
        return NotificationClient(
            requestPermissions: requestNotificationPermissions,
            checkForNewItems: {
                try await performBackgroundCheck(
                    persistenceClient: persistenceClient,
                    rssClient: rssClient
                )
            }
        )
    }
}

// MARK: - Permission Handling
private extension NotificationClient {
    static func requestNotificationPermissions() async throws {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        switch settings.authorizationStatus {
        case .notDetermined:
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            print("Notification permissions granted: \(granted)")
            if !granted { throw NotificationError.permissionDenied }
            
        case .denied:
            print("Notification permissions denied")
            throw NotificationError.permissionDenied
            
        case .authorized, .provisional, .ephemeral:
            print("Notification permissions already authorized")
            
        @unknown default:
            throw NotificationError.permissionDenied
        }
    }
}

// MARK: - Background Check Implementation
private extension NotificationClient {
    static func performBackgroundCheck(
        persistenceClient: PersistenceClient,
        rssClient: RSSClient
    ) async throws {
        let (center, settings) = try await prepareNotificationCheck()
        let (lastCheck, notifiedItemIDs) = loadCheckState()
        var newNotifiedItemIDs = notifiedItemIDs
        
        let feeds = try await loadAndFilterFeeds(persistenceClient)
        
        try await processFeeds(
            feeds,
            lastCheck: lastCheck,
            notifiedItemIDs: notifiedItemIDs,
            newNotifiedItemIDs: &newNotifiedItemIDs,
            center: center,
            rssClient: rssClient
        )
        
        updateCheckState(newNotifiedItemIDs: newNotifiedItemIDs)
    }
    
    static func prepareNotificationCheck() async throws
        -> (UNUserNotificationCenter, UNNotificationSettings)
    {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        guard settings.authorizationStatus == .authorized else {
            print("Notifications not authorized, skipping check")
            throw NotificationError.permissionDenied
        }
        
        return (center, settings)
    }
    
    static func loadCheckState() -> (Date, [String]) {
        let defaults = UserDefaults.standard
        let lastCheck = defaults.object(
            forKey: Constants.Storage.lastNotificationCheckKey
        ) as? Date ?? Date.distantPast
        
        let notifiedItemIDs = defaults.stringArray(
            forKey: Constants.Storage.notifiedItemsKey
        ) ?? []
        
        print("Last check time: \(lastCheck)")
        print("Currently notified item IDs: \(notifiedItemIDs.count)")
        
        return (lastCheck, notifiedItemIDs)
    }
    
    static func loadAndFilterFeeds(_ client: PersistenceClient) async throws -> [Feed] {
        let feeds = try await client.loadFeeds()
        let enabledFeeds = feeds.filter { $0.notificationsEnabled }
        
        print("Total feeds: \(feeds.count), notification enabled: \(enabledFeeds.count)")
        return enabledFeeds
    }
    
    static func updateCheckState(newNotifiedItemIDs: [String]) {
        let defaults = UserDefaults.standard
        defaults.set(Date(), forKey: Constants.Storage.lastNotificationCheckKey)
        defaults.set(newNotifiedItemIDs, forKey: Constants.Storage.notifiedItemsKey)
        
        print("Updated last check time to now")
        print("Total notified item IDs: \(newNotifiedItemIDs.count)")
        
        if newNotifiedItemIDs.count > Constants.Notifications.maxStoredNotificationIDs {
            let prunedIDs = Array(
                newNotifiedItemIDs.suffix(Constants.Notifications.pruneToCount)
            )
            defaults.set(prunedIDs, forKey: Constants.Storage.notifiedItemsKey)
            print("Pruned notified item IDs to \(Constants.Notifications.pruneToCount)")
        }
    }
}

// MARK: - Feed Processing
private extension NotificationClient {
    static func processFeeds(
        _ feeds: [Feed],
        lastCheck: Date,
        notifiedItemIDs: [String],
        newNotifiedItemIDs: inout [String],
        center: UNUserNotificationCenter,
        rssClient: RSSClient
    ) async throws {
        var errors: [String: Error] = [:]
        var delayOffset = 0.5
        
        for feed in feeds {
            print("Checking feed: \(feed.title ?? feed.url.absoluteString)")
            
            do {
                let items = try await rssClient.fetchFeedItems(feed.url)
                let newItems = filterNewItems(items, after: lastCheck, notified: notifiedItemIDs)
                
                try await scheduleNotifications(
                    for: newItems,
                    from: feed,
                    delayOffset: &delayOffset,
                    center: center,
                    newNotifiedItemIDs: &newNotifiedItemIDs
                )
            } catch {
                print("Error parsing feed \(feed.url.absoluteString): \(error)")
                errors[feed.url.absoluteString] = error
            }
        }
        
        logErrors(errors)
    }
    
    static func filterNewItems(
        _ items: [FeedItem],
        after lastCheck: Date,
        notified notifiedItemIDs: [String]
    ) -> [FeedItem] {
        let newItems = items.filter { item in
            guard let pubDate = item.pubDate else {
                print("  Item \(item.title) has no publication date")
                return false
            }
            
            let isAfterLastCheck = pubDate > lastCheck
            let isNotAlreadyNotified = !notifiedItemIDs.contains(item.id.uuidString)
            
            if isAfterLastCheck && isNotAlreadyNotified {
                print("  New item: \(item.title), published at \(pubDate)")
                return true
            }
            return false
        }
        
        print("  Found \(newItems.count) new items after \(lastCheck)")
        return newItems
    }
    
    static func logErrors(_ errors: [String: Error]) {
        guard !errors.isEmpty else { return }
        
        print("Completed with \(errors.count) errors:")
        for (url, error) in errors {
            print("  - \(url): \(error)")
        }
    }
}

// MARK: - Notification Scheduling
private extension NotificationClient {
    static func scheduleNotifications(
        for items: [FeedItem],
        from feed: Feed,
        delayOffset: inout Double,
        center: UNUserNotificationCenter,
        newNotifiedItemIDs: inout [String]
    ) async throws {
        for item in items {
            try await scheduleNotification(
                for: item,
                from: feed,
                delayOffset: &delayOffset,
                center: center,
                newNotifiedItemIDs: &newNotifiedItemIDs
            )
        }
    }
    
    static func scheduleNotification(
        for item: FeedItem,
        from feed: Feed,
        delayOffset: inout Double,
        center: UNUserNotificationCenter,
        newNotifiedItemIDs: inout [String]
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = feed.title ?? "New item in feed"
        content.body = item.title
        content.sound = .default
        
        let identifier = "notification-\(item.id.uuidString)"
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: delayOffset,
            repeats: false
        )
        delayOffset += 0.5
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            print("  Scheduled notification for item: \(item.title) with \(delayOffset-0.5)s delay")
            newNotifiedItemIDs.append(item.id.uuidString)
        } catch {
            print("  Failed to schedule notification: \(error)")
            throw error
        }
    }
}
