//
//  UserDefaultsClient.swift
//  RSSReaderKit
//
//  Created by Martino Mamic on 03.05.25.
//

import Dependencies
import Foundation

public struct UserDefaultsClient: Sendable {
    public var getLastNotificationCheckTime: @Sendable () -> Date?
    public var setLastNotificationCheckTime: @Sendable (Date) -> Void
 
    
    public init(
        getLastNotificationCheckTime: @escaping @Sendable () -> Date?,
        setLastNotificationCheckTime: @escaping @Sendable (Date) -> Void
    ) {
        self.getLastNotificationCheckTime = getLastNotificationCheckTime
        self.setLastNotificationCheckTime = setLastNotificationCheckTime
    }
}
