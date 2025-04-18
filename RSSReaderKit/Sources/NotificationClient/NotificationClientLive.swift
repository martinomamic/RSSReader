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
        @Dependency(\.persistenceClient) var persistenceClient
        @Dependency(\.rssClient) var rssClient
        
        return NotificationClient(
            requestPermissions: {
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
                    break
                @unknown default:
                    throw NotificationError.permissionDenied
                }
            },
            checkForNewItems: {
                print("Starting background check for new items...")
                
                let center = UNUserNotificationCenter.current()
                let settings = await center.notificationSettings()
                
                guard settings.authorizationStatus == .authorized else {
                    print("Notifications not authorized, skipping check")
                    throw NotificationError.permissionDenied
                }
                
                let defaults = UserDefaults.standard
                let lastCheck = defaults.object(forKey: Constants.Storage.lastNotificationCheckKey) as? Date ?? Date.distantPast
                
                let notifiedItemIDs = defaults.stringArray(forKey: Constants.Storage.notifiedItemsKey) ?? []
                var newNotifiedItemIDs = notifiedItemIDs
                
                print("Last check time: \(lastCheck)")
                print("Currently notified item IDs: \(notifiedItemIDs.count)")
                
                let feeds = try await persistenceClient.loadFeeds()
                let notificationEnabledFeeds = feeds.filter { $0.notificationsEnabled }
                
                print("Total feeds: \(feeds.count), notification enabled: \(notificationEnabledFeeds.count)")
                
                // To keep track of errors without stopping the entire process
                var errors: [String: Error] = [:]
                
                for feed in notificationEnabledFeeds {
                    print("Checking feed: \(feed.title ?? feed.url.absoluteString)")
                    
                    do {
                        let items = try await rssClient.fetchFeedItems(feed.url)
                        print("  Found \(items.count) items in feed")
                        
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
                        
                        var delayOffset = 0.5
                        
                        for item in newItems {
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
                                errors[item.id.uuidString] = error
                            }
                        }
                    } catch {
                        print("Error parsing feed \(feed.url.absoluteString): \(error)")
                        errors[feed.url.absoluteString] = error
                    }
                }
                
                defaults.set(Date(), forKey: Constants.Storage.lastNotificationCheckKey)
                defaults.set(newNotifiedItemIDs, forKey: Constants.Storage.notifiedItemsKey)
                
                print("Updated last check time to now")
                print("Total notified item IDs: \(newNotifiedItemIDs.count)")
                
                if newNotifiedItemIDs.count > Constants.Notifications.maxStoredNotificationIDs {
                    defaults.set(Array(newNotifiedItemIDs.suffix(Constants.Notifications.pruneToCount)),
                                forKey: Constants.Storage.notifiedItemsKey)
                    print("Pruned notified item IDs to \(Constants.Notifications.pruneToCount)")
                }
                
                // Now list all pending notifications for debugging
                let pendingRequests = await center.pendingNotificationRequests()
                print("Pending notifications after check: \(pendingRequests.count)")
                
                // If we had any errors, log them but don't throw
                if !errors.isEmpty {
                    print("Completed with \(errors.count) errors:")
                    for (url, error) in errors {
                        print("  - \(url): \(error)")
                    }
                }
            }
        )
    }
}
