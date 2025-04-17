//
//  NotificationClientLive.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 17.04.25.
//

import Dependencies
import Foundation
import SharedModels
import UserNotifications

extension NotificationClient {
    public static func live() -> NotificationClient {
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
                // TODO: loadFeeds, possibly background fetch
            }
        )
    }
}
