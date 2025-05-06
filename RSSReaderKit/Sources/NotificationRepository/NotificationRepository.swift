//
//  NotificationsRepository.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 03.05.25.
//

import Common
import Dependencies
import Foundation
import SharedModels
@preconcurrency import UserNotifications

public struct NotificationRepository: Sendable {
    public var requestPermissions: @Sendable () async throws -> Void
    public var checkForNewItems: @Sendable () async throws -> Void
    public var notificationsAuthorized: @Sendable () async -> Bool
    public var scheduleNotificationForItem: @Sendable (FeedItem, _ from: Feed) async throws -> Void
    public var manuallyTriggerBackgroundRefresh: @Sendable () async -> Bool
    public var activateBackgroundRefresh: @Sendable () async -> Void
    
    public var getNotificationStatus: @Sendable () async -> String
    public var sendDelayedNotification: @Sendable (Int) async throws -> Void
    public var testFeedParsing: @Sendable () async -> String
    public var getPendingNotifications: @Sendable () async -> [String]
    
    public init(
        requestPermissions: @escaping @Sendable () async throws -> Void,
        checkForNewItems: @escaping @Sendable () async throws -> Void,
        notificationsAuthorized: @escaping @Sendable () async -> Bool,
        scheduleNotificationForItem: @escaping @Sendable (FeedItem, _ from: Feed) async throws -> Void,
        manuallyTriggerBackgroundRefresh: @escaping @Sendable () async -> Bool,
        activateBackgroundRefresh: @escaping @Sendable () async -> Void,
        getNotificationStatus: @escaping @Sendable () async -> String,
        sendDelayedNotification: @escaping @Sendable (Int) async throws -> Void,
        testFeedParsing: @escaping @Sendable () async -> String,
        getPendingNotifications: @escaping @Sendable () async -> [String]
    ) {
        self.requestPermissions = requestPermissions
        self.checkForNewItems = checkForNewItems
        self.notificationsAuthorized = notificationsAuthorized
        self.scheduleNotificationForItem = scheduleNotificationForItem
        self.manuallyTriggerBackgroundRefresh = manuallyTriggerBackgroundRefresh
        self.activateBackgroundRefresh = activateBackgroundRefresh
        
        self.getNotificationStatus = getNotificationStatus
        self.sendDelayedNotification = sendDelayedNotification
        self.testFeedParsing = testFeedParsing
        self.getPendingNotifications = getPendingNotifications
    }
}
