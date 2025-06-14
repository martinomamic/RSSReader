//
//  UserDefaultsClientLive.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 03.05.25.
//

import Dependencies
import Foundation

extension UserDefaultsClient {
    private enum Keys {
        static let lastNotificationCheckKey = "lastNotificationCheck"
    }
    
    public static let live = Self(
        getLastNotificationCheckTime: {
            return UserDefaults.standard.object(forKey: Keys.lastNotificationCheckKey) as? Date
        },
        setLastNotificationCheckTime: { date in
            UserDefaults.standard.set(date, forKey: Keys.lastNotificationCheckKey)
        }
    )
}
