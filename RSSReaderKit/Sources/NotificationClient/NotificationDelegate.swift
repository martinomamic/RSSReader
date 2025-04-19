//
//  NotificationDelegate.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 18.04.25.
//

import Foundation
@preconcurrency import UserNotifications

public final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    public static var shared: NotificationDelegate { NotificationDelegate() }

    private override init() {
        super.init()
    }

    public func setup() {
        UNUserNotificationCenter.current().delegate = self
        print("NotificationDelegate setup complete")
    }

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("⭐️ IMPORTANT: willPresent notification called for: \(notification.request.identifier)")
        print("⭐️ IMPORTANT: Notification content: \(notification.request.content.title) - \(notification.request.content.body)")
        
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .list, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("⭐️ IMPORTANT: User interacted with notification: \(response.notification.request.identifier)")

        completionHandler()
    }
}
