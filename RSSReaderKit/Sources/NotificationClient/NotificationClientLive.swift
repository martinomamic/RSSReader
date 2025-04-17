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

extension NotificationClient {
    public static func live() -> NotificationClient {
        @Dependency(\.persistenceClient) var persistenceClient
        @Dependency(\.rssClient) var rssClient
        
        return NotificationClient(
            requestPermissions: {
                let center = UNUserNotificationCenter.current()
                let settings = await center.notificationSettings()
                
                switch settings.authorizationStatus {
                case .notDetermined:
                    try await center.requestAuthorization(options: [.alert, .sound, .badge])
                case .denied:
                    throw NotificationError.permissionDenied
                case .authorized, .provisional, .ephemeral:
                    break
                @unknown default:
                    break
                }
            },
            checkForNewItems: {
                // Get current notification settings
                let center = UNUserNotificationCenter.current()
                let settings = await center.notificationSettings()
                
                // Only proceed if notifications are authorized
                guard settings.authorizationStatus == .authorized else {
                    return
                }
                
                // Get the timestamp of the last check
                let defaults = UserDefaults.standard
                let lastCheck = defaults.object(forKey: Constants.Storage.lastNotificationCheckKey) as? Date ?? Date.distantPast
                
                // Get previously notified items to avoid duplicates
                let notifiedItemIDs = defaults.stringArray(forKey: Constants.Storage.notifiedItemsKey) ?? []
                var newNotifiedItemIDs = notifiedItemIDs
                
                // Load all feeds that have notifications enabled
                let feeds = try await persistenceClient.loadFeeds()
                let notificationEnabledFeeds = feeds.filter { $0.notificationsEnabled }
                
                for feed in notificationEnabledFeeds {
                    // Fetch latest items for each feed
                    let items = try await rssClient.fetchFeedItems(feed.url)
                    
                    // Filter items that are newer than the last check and haven't been notified yet
                    let newItems = items.filter { item in
                        guard let pubDate = item.pubDate else { return false }
                        return pubDate > lastCheck && !notifiedItemIDs.contains(item.id.uuidString)
                    }
                    
                    // Schedule notifications for new items
                    for item in newItems {
                        let content = UNMutableNotificationContent()
                        content.title = feed.title ?? "New item in feed"
                        content.body = item.title
                        content.sound = .default
                        
                        // Create a unique identifier for this notification
                        let identifier = "notification-\(item.id.uuidString)"
                        
                        // Create the notification request
                        let request = UNNotificationRequest(
                            identifier: identifier,
                            content: content,
                            trigger: nil
                        )
                        
                        // Add to the notification center
                        try await center.add(request)
                        
                        // Track this item as notified
                        newNotifiedItemIDs.append(item.id.uuidString)
                    }
                }
                
                // Update the last check time and notified items
                defaults.set(Date(), forKey: Constants.Storage.lastNotificationCheckKey)
                defaults.set(newNotifiedItemIDs, forKey: Constants.Storage.notifiedItemsKey)
                
                // If we have too many notified items, keep only the most recent ones
                if newNotifiedItemIDs.count > Constants.Notifications.maxStoredNotificationIDs {
                    defaults.set(Array(newNotifiedItemIDs.suffix(Constants.Notifications.pruneToCount)),
                                forKey: Constants.Storage.notifiedItemsKey)
                }
            }
        )
    }
}
