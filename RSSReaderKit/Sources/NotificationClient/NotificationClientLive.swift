//
//  NotificationClientLive.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 17.04.25.
//

import Dependencies
import Foundation
import SharedModels
import PersistenceClient
import RSSClient
import UserNotifications

extension NotificationClient {
    public static func live() -> NotificationClient {
        @Dependency(\.persistenceClient) var persistenceClient
        @Dependency(\.rssClient) var rssClient
        
        let lastCheckKey = "lastNotificationCheck"
        let notifiedItemsKey = "notifiedItems"
        
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
                let lastCheck = defaults.object(forKey: lastCheckKey) as? Date ?? Date.distantPast
                
                let notifiedItemIDs = defaults.stringArray(forKey: notifiedItemsKey) ?? []
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
                
                defaults.set(Date(), forKey: lastCheckKey)
                defaults.set(newNotifiedItemIDs, forKey: notifiedItemsKey)
                
                if newNotifiedItemIDs.count > 1000 {
                    defaults.set(Array(newNotifiedItemIDs.suffix(500)), forKey: notifiedItemsKey)
                }
            }
        )
    }
}
