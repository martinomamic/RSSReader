//
//  UserNotificationClientLive.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 03.05.25.
//

import Dependencies
import Foundation
@preconcurrency import UserNotifications

extension UserNotificationClient {
    public static func live() -> Self {
        return Self(
            requestAuthorization: { options in
                try await UNUserNotificationCenter.current().requestAuthorization(options: options)
            },
            getNotificationSettings: {
                let settings = await UNUserNotificationCenter.current().notificationSettings()
                return NotificationSettings(authorizationStatus: settings.authorizationStatus)
            },
            addNotificationRequest: { request in
                let content = UNMutableNotificationContent()
                content.title = request.title
                content.body = request.body
                
                if let sound = request.sound {
                    content.sound = sound
                }
                
                content.userInfo = request.userInfo
                
                if let threadIdentifier = request.threadIdentifier {
                    content.threadIdentifier = threadIdentifier
                }
                
                let notificationRequest = UNNotificationRequest(
                    identifier: request.id,
                    content: content,
                    trigger: request.trigger
                )
                
                try await UNUserNotificationCenter.current().add(notificationRequest)
            },
            pendingNotificationRequests: {
                await UNUserNotificationCenter.current().pendingNotificationRequests()
            },
            removeAllPendingNotificationRequests: {
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            },
            removePendingNotificationRequests: { identifiers in
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
            },
            setDelegate: {
                UNUserNotificationCenter.current().delegate = UserNotificationDelegate.shared
            },
            sendTestNotification: { title, body, delay in
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = .default
                
                let trigger = UNTimeIntervalNotificationTrigger(
                    timeInterval: delay,
                    repeats: false
                )
                
                let request = UNNotificationRequest(
                    identifier: "test-\(UUID().uuidString)",
                    content: content,
                    trigger: trigger
                )
                
                try await UNUserNotificationCenter.current().add(request)
            },
            getNotificationStatusDescription: {
                let settings = await UNUserNotificationCenter.current().notificationSettings()
                
                switch settings.authorizationStatus {
                case .authorized: return "Authorized"
                case .denied: return "Denied"
                case .notDetermined: return "Not Determined"
                case .provisional: return "Provisional"
                case .ephemeral: return "Ephemeral"
                @unknown default: return "Unknown"
                }
            }
        )
    }
}
