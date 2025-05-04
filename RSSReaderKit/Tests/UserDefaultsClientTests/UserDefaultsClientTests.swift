//
//  UserDefaultsClientTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamic on 03.05.25.
//

import Testing
import Dependencies
import Foundation
import ConcurrencyExtras

@testable import UserDefaultsClient

@Suite struct UserDefaultsClientTests {
    @Test("getLastNotificationCheckTime returns nil when no value is set")
    func testGetLastNotificationCheckTimeReturnsNilWhenNoValueIsSet() {
        let client = UserDefaultsClient.testValue
        
        #expect(client.getLastNotificationCheckTime() == nil)
    }
    
    @Test("getLastNotificationCheckTime returns set value")
    func testGetLastNotificationCheckTimeReturnsSetValue() {
        let testDate = Date()
        let mockStorage = LockIsolated<Date?>(nil)
        
        var client = UserDefaultsClient.testValue
        client.getLastNotificationCheckTime = { mockStorage.value }
        client.setLastNotificationCheckTime = { date in
            mockStorage.setValue(date)
        }
        
        client.setLastNotificationCheckTime(testDate)
        
        #expect(client.getLastNotificationCheckTime() == testDate)
    }
    
    @Test("setLastNotificationCheckTime updates stored value")
    func testSetLastNotificationCheckTimeUpdatesStoredValue() {
        let testDate = Date()
        let newerDate = Date().addingTimeInterval(3600)
        let mockStorage = LockIsolated<Date?>(nil)
        
        var client = UserDefaultsClient.testValue
        client.getLastNotificationCheckTime = { mockStorage.value }
        client.setLastNotificationCheckTime = { date in
            mockStorage.setValue(date)
        }
        
        client.setLastNotificationCheckTime(testDate)
        #expect(client.getLastNotificationCheckTime() == testDate)
        
        client.setLastNotificationCheckTime(newerDate)
        #expect(client.getLastNotificationCheckTime() == newerDate)
        #expect(client.getLastNotificationCheckTime() != testDate)
    }
}
