//
//  NotificationDelegate.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 18.04.25.
//

import Foundation
@preconcurrency import UserNotifications

public final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    // Fix the shared singleton pattern to be concurrency-safe
    public static var shared: NotificationDelegate { NotificationDelegate() }

    private override init() {
        super.init()
    }

    public func setup() {
        UNUserNotificationCenter.current().delegate = self
        print("NotificationDelegate setup complete")
    }

    // This method allows notifications to be displayed when the app is in the foreground
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("⭐️ IMPORTANT: willPresent notification called for: \(notification.request.identifier)")
        print("⭐️ IMPORTANT: Notification content: \(notification.request.content.title) - \(notification.request.content.body)")

        // Force all possible presentation options for notifications in foreground
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .list, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }

    // This method handles when a user interacts with a notification
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("⭐️ IMPORTANT: User interacted with notification: \(response.notification.request.identifier)")

        // Handle the notification response here if needed

        completionHandler()
    }
}
