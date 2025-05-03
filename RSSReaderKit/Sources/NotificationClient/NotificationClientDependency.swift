//
//  NotificationClientLive.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 17.04.25.
//

import Dependencies
import Foundation
import SharedModels

extension NotificationClient: DependencyKey {
    public static var liveValue: NotificationClient { .live() }

    public static var testValue: NotificationClient {
        NotificationClient(
            requestPermissions: {},
            checkForNewItems: {}
        )
    }
}

extension DependencyValues {
    public var notificationClient: NotificationClient {
        get { self[NotificationClient.self] }
        set { self[NotificationClient.self] = newValue }
    }
}
