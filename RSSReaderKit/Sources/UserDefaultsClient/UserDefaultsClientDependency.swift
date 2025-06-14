//
//  UserDefaultsClientDependency.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 03.05.25.
//

import Dependencies
import Foundation

extension UserDefaultsClient: DependencyKey {
    public static let liveValue = UserDefaultsClient.live
    
    public static let testValue = Self(
        getLastNotificationCheckTime: { nil },
        setLastNotificationCheckTime: { _ in }
    )
}

extension DependencyValues {
    public var userDefaults: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}
