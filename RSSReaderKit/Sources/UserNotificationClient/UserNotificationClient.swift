//
//  UserNotificationClient.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 03.05.25.
//

import Dependencies
import Foundation
@preconcurrency import UserNotifications

public struct UserNotificationClient: Sendable {
    public var requestAuthorization: @Sendable (_ options: UNAuthorizationOptions) async throws -> Bool
    public var getNotificationSettings: @Sendable () async -> NotificationSettings
    public var addNotificationRequest: @Sendable (_ request: NotificationRequest) async throws -> Void
    public var pendingNotificationRequests: @Sendable () async -> [UNNotificationRequest]
    public var removeAllPendingNotificationRequests: @Sendable () -> Void
    public var removePendingNotificationRequests: @Sendable (_ identifiers: [String]) -> Void
    public var setDelegate: @Sendable () -> Void
    public var sendTestNotification: @Sendable (_ title: String, _ body: String, _ delay: TimeInterval) async throws -> Void
    public var getNotificationStatusDescription: @Sendable () async -> String
    
    public init(
        requestAuthorization: @escaping @Sendable (_ options: UNAuthorizationOptions) async throws -> Bool,
        getNotificationSettings: @escaping @Sendable () async -> NotificationSettings,
        addNotificationRequest: @escaping @Sendable (_ request: NotificationRequest) async throws -> Void,
        pendingNotificationRequests: @escaping @Sendable () async -> [UNNotificationRequest],
        removeAllPendingNotificationRequests: @escaping @Sendable () -> Void,
        removePendingNotificationRequests: @escaping @Sendable (_ identifiers: [String]) -> Void,
        setDelegate: @escaping @Sendable () -> Void,
        sendTestNotification: @escaping @Sendable (_ title: String, _ body: String, _ delay: TimeInterval) async throws -> Void,
        getNotificationStatusDescription: @escaping @Sendable () async -> String
    ) {
        self.requestAuthorization = requestAuthorization
        self.getNotificationSettings = getNotificationSettings
        self.addNotificationRequest = addNotificationRequest
        self.pendingNotificationRequests = pendingNotificationRequests
        self.removeAllPendingNotificationRequests = removeAllPendingNotificationRequests
        self.removePendingNotificationRequests = removePendingNotificationRequests
        self.setDelegate = setDelegate
        self.sendTestNotification = sendTestNotification
        self.getNotificationStatusDescription = getNotificationStatusDescription
    }
    
    public struct NotificationSettings: Equatable, Sendable {
        public var authorizationStatus: UNAuthorizationStatus
        
        public init(authorizationStatus: UNAuthorizationStatus) {
            self.authorizationStatus = authorizationStatus
        }
    }
    
    public struct NotificationRequest: Equatable, Sendable, Identifiable {
        public var id: String
        public var title: String
        public var body: String
        public var sound: UNNotificationSound?
        public var userInfo: [String: any Sendable]
        public var trigger: UNNotificationTrigger?
        public var threadIdentifier: String?
        
        public init(
            id: String,
            title: String,
            body: String,
            sound: UNNotificationSound? = .default,
            userInfo: [String: any Sendable] = [:],
            trigger: UNNotificationTrigger? = nil,
            threadIdentifier: String? = nil
        ) {
            self.id = id
            self.title = title
            self.body = body
            self.sound = sound
            self.userInfo = userInfo
            self.trigger = trigger
            self.threadIdentifier = threadIdentifier
        }
        
        public static func == (lhs: NotificationRequest, rhs: NotificationRequest) -> Bool {
            lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.body == rhs.body
        }
    }
}
