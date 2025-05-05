//
//  File.swift
//  RSSReaderKit
//
//  Created by Martino Mamic on 03.05.25.
//

import Dependencies
import Foundation
@preconcurrency import UserNotifications

extension UserNotificationClient: DependencyKey {
    public static let liveValue = UserNotificationClient.live()
    
    public static let testValue = Self(
        requestAuthorization: { _ in true },
        getNotificationSettings: { NotificationSettings(authorizationStatus: .authorized) },
        addNotificationRequest: { _ in },
        pendingNotificationRequests: { [] },
        removeAllPendingNotificationRequests: {},
        removePendingNotificationRequests: { _ in },
        setDelegate: {},
        sendTestNotification: { _,_,_  in },
        getNotificationStatusDescription: { "testStatus" }
    )
}

extension DependencyValues {
    public var userNotifications: UserNotificationClient {
        get { self[UserNotificationClient.self] }
        set { self[UserNotificationClient.self] = newValue }
    }
}
