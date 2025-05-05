//
//  NotificationsRepositoryDependency.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 03.05.25.
//

import Dependencies
import Foundation
import SharedModels

extension NotificationRepository: DependencyKey {
    public static let liveValue: NotificationRepository = .live()

    public static let testValue: NotificationRepository = NotificationRepository(
        requestPermissions: {},
        checkForNewItems: {},
        notificationsAuthorized: { true },
        scheduleNotificationForItem: { _, _ in },
        manuallyTriggerBackgroundRefresh: { false },
        activateBackgroundRefresh: {},
        getNotificationStatus: { "" },
        sendDelayedNotification: { _ in },
        testFeedParsing: { "" },
        getPendingNotifications: { [] },
    )
}

extension DependencyValues {
    public var notificationRepository: NotificationRepository {
        get { self[NotificationRepository.self] }
        set { self[NotificationRepository.self] = newValue }
    }
}
