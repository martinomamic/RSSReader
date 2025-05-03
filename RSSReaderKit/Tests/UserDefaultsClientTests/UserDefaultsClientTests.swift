//
//  UserDefaultsClientTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamic on 03.05.25.
//

import Testing
import Dependencies
import Foundation

@testable import UserDefaultsClient

@Suite struct UserDefaultsClientTests {
    @Test("getLastNotificationCheckTime returns nil when no value is set")
    func testGetLastNotificationCheckTimeReturnsNilWhenNoValueIsSet() {
        let client = UserDefaultsClient(
            getLastNotificationCheckTime: { nil },
            setLastNotificationCheckTime: { _ in }
        )
        
        #expect(client.getLastNotificationCheckTime() == nil)
    }
    
    @Test("getLastNotificationCheckTime returns set value")
    func testGetLastNotificationCheckTimeReturnsSetValue() {
        let testDate = Date()
        let mockStorage = LockIsolated<Date?>(nil)
        
        let client = UserDefaultsClient(
            getLastNotificationCheckTime: { mockStorage.value },
            setLastNotificationCheckTime: { date in
                mockStorage.setValue(date)
            }
        )
        
        client.setLastNotificationCheckTime(testDate)
        
        #expect(client.getLastNotificationCheckTime() == testDate)
    }
    
    @Test("setLastNotificationCheckTime updates stored value")
    func testSetLastNotificationCheckTimeUpdatesStoredValue() {
        let testDate = Date()
        let newerDate = Date().addingTimeInterval(3600)
        let mockStorage = LockIsolated<Date?>(nil)
        
        let client = UserDefaultsClient(
            getLastNotificationCheckTime: { mockStorage.value },
            setLastNotificationCheckTime: { date in
                mockStorage.setValue(date)
            }
        )
        
        client.setLastNotificationCheckTime(testDate)
        #expect(client.getLastNotificationCheckTime() == testDate)
        
        client.setLastNotificationCheckTime(newerDate)
        #expect(client.getLastNotificationCheckTime() == newerDate)
        #expect(client.getLastNotificationCheckTime() != testDate)
    }
    
    @Test("Test dependency injection works properly")
    func testDependencyInjection() async throws {
        let testDate = Date()
        
        let client = withDependencies {
            $0.userDefaults = UserDefaultsClient(
                getLastNotificationCheckTime: { testDate },
                setLastNotificationCheckTime: { _ in }
            )
        } operation: {
            @Dependency(\.userDefaults) var userDefaults
            return userDefaults
        }
        
        #expect(client.getLastNotificationCheckTime() == testDate)
    }
}
