//
//  NotificationClient.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 17.04.25.
//

import Foundation
import SharedModels

public struct NotificationClient: Sendable {
    public var requestPermissions: @Sendable () async throws -> Void
    public var checkForNewItems: @Sendable () async throws -> Void
    public var getAuthorizationStatus: @Sendable () async -> Bool
    public var scheduleNotification: @Sendable (NotificationContent) async throws -> Void

    public init(
        requestPermissions: @escaping @Sendable () async throws -> Void,
        checkForNewItems: @escaping @Sendable () async throws -> Void,
        getAuthorizationStatus: @escaping @Sendable () async -> Bool,
        scheduleNotification: @escaping @Sendable (NotificationContent) async throws -> Void
    ) {
        self.requestPermissions = requestPermissions
        self.checkForNewItems = checkForNewItems
        self.getAuthorizationStatus = getAuthorizationStatus
        self.scheduleNotification = scheduleNotification
    }
}

public struct NotificationContent: Sendable {
    public let title: String
    public let body: String
    public let threadIdentifier: String
    public let identifier: String
    public let delayInterval: TimeInterval?
    
    public init(
        title: String,
        body: String,
        threadIdentifier: String,
        identifier: String,
        delayInterval: TimeInterval? = nil
    ) {
        self.title = title
        self.body = body
        self.threadIdentifier = threadIdentifier
        self.identifier = identifier
        self.delayInterval = delayInterval
    }
}
