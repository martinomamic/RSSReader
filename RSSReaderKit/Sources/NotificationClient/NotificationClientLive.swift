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
                let center = UNUserNotificationCenter.current()
                let settings = await center.notificationSettings()
                
                guard settings.authorizationStatus == .authorized else {
                    return
                }
                
                let defaults = UserDefaults.standard
                let lastCheck = defaults.object(forKey: Constants.Storage.lastNotificationCheckKey) as? Date ?? Date.distantPast
                
                let notifiedItemIDs = defaults.stringArray(forKey: Constants.Storage.notifiedItemsKey) ?? []
                var newNotifiedItemIDs = notifiedItemIDs
                
                let feeds = try await persistenceClient.loadFeeds()
                let notificationEnabledFeeds = feeds.filter { $0.notificationsEnabled }
                
                for feed in notificationEnabledFeeds {
                    let items = try await rssClient.fetchFeedItems(feed.url)
                    
                    let newItems = items.filter { item in
                        guard let pubDate = item.pubDate else { return false }
                        return pubDate > lastCheck && !notifiedItemIDs.contains(item.id.uuidString)
                    }
                    
                    for item in newItems {
                        let content = UNMutableNotificationContent()
                        content.title = feed.title ?? "New item in feed"
                        content.body = item.title
                        content.sound = .default
   
                        let identifier = "notification-\(item.id.uuidString)"
                        
                        let request = UNNotificationRequest(
                            identifier: identifier,
                            content: content,
                            trigger: nil
                        )

                        try await center.add(request)
                        
                        newNotifiedItemIDs.append(item.id.uuidString)
                    }
                }
                
                defaults.set(Date(), forKey: Constants.Storage.lastNotificationCheckKey)
                defaults.set(newNotifiedItemIDs, forKey: Constants.Storage.notifiedItemsKey)
                
                if newNotifiedItemIDs.count > Constants.Notifications.maxStoredNotificationIDs {
                    defaults.set(Array(newNotifiedItemIDs.suffix(Constants.Notifications.pruneToCount)),
                                forKey: Constants.Storage.notifiedItemsKey)
                }
            }
        )
    }
}
