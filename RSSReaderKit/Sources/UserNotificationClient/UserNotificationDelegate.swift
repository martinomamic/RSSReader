//
//  NotificationDelegate.swift
//  RSSReaderKit
//
//  Created by Martino Mamic on 03.05.25.
//

import Foundation
@preconcurrency import UserNotifications

public final class UserNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    public static var shared: UserNotificationDelegate { UserNotificationDelegate() }
    
    private override init() {
        super.init()
    }
    
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .list, .sound, .badge]
    }
    
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        
        if let feedURL = userInfo["feedURL"] as? String,
           let itemURL = userInfo["itemURL"] as? String,
           let feedURL = URL(string: feedURL),
           let itemURL = URL(string: itemURL) {
            print("User opened a notification for a feed: \(feedURL), item URL: \(itemURL)")
        }
    }
}
