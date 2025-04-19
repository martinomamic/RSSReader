//
//  NotificationClientLive.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 17.04.25.
//

import Dependencies
import Foundation
import SharedModels

@available(macOS 14.0, iOS 17.0, *)
extension NotificationClient: DependencyKey {
    public static var liveValue: NotificationClient { .live() }

    public static var testValue: NotificationClient {
        NotificationClient(
            requestPermissions: {},
            checkForNewItems: {}
        )
    }
}

@available(macOS 14.0, iOS 17.0, *)
extension DependencyValues {
    public var notificationClient: NotificationClient {
        get { self[NotificationClient.self] }
        set { self[NotificationClient.self] = newValue }
    }
}
