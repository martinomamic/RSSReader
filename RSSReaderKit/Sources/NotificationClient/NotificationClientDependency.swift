//
//  NotificationClientDependency.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 17.04.25.
//

import Dependencies
import Foundation
@preconcurrency import UserNotifications

private enum NotificationClientKey: DependencyKey {
    static let liveValue = NotificationClient.live()
    static let testValue = NotificationClient(
        requestPermissions: { },
        checkForNewItems: { },
        checkAuthorizationStatus: { .notDetermined }
    )
}

extension DependencyValues {
    public var notificationClient: NotificationClient {
        get { self[NotificationClientKey.self] }
        set { self[NotificationClientKey.self] = newValue }
    }
}
