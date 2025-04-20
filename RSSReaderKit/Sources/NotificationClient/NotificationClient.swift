//
//  NotificationClient.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 17.04.25.
//

import Foundation
import UserNotifications

public struct NotificationClient: Sendable {
    public var requestPermissions: @Sendable () async throws -> Void
    public var checkForNewItems: @Sendable () async throws -> Void
    public var checkAuthorizationStatus: @Sendable () async -> UNAuthorizationStatus

    public init(
        requestPermissions: @escaping @Sendable () async throws -> Void,
        checkForNewItems: @escaping @Sendable () async throws -> Void,
        checkAuthorizationStatus: @escaping @Sendable () async -> UNAuthorizationStatus
    ) {
        self.requestPermissions = requestPermissions
        self.checkForNewItems = checkForNewItems
        self.checkAuthorizationStatus = checkAuthorizationStatus
    }
}
