//
//  NotificationClientTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 17.04.25.
//

//
//  NotificationClientTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 17.04.25.
//

import Common
import ConcurrencyExtras
import Dependencies
import Foundation
import Testing
@preconcurrency import UserNotifications

@testable import NotificationClient
@testable import SharedModels
@testable import RSSClient
@testable import PersistenceClient

@Suite struct NotificationClientTests {
    @Dependency(\.notificationClient) var client
    
    func setUp() {
        UserDefaults.standard.removeObject(forKey: Constants.Notifications.lastNotificationCheckKey)
    }
    
    func testFeed(notificationsEnabled: Bool = true) -> Feed {
        Feed(
            url: URL(string: "https://example.com/feed")!,
            title: "Test Feed",
            description: "Test Description",
            notificationsEnabled: notificationsEnabled
        )
    }

    func testItem(pubDate: Date = Date()) -> FeedItem {
        FeedItem(
            feedID: UUID(),
            title: "Test Item",
            link: URL(string: "https://example.com/item")!,
            pubDate: pubDate
        )
    }

    @Test("Request permissions success")
    func testRequestPermissionsSuccess() async throws {
        let permissionsRequested = LockIsolated<Bool>(false)

        try await withDependencies {
            $0.notificationClient.requestPermissions = {
                permissionsRequested.setValue(true)
            }
        } operation: {
            try await client.requestPermissions()
            #expect(permissionsRequested.value)
        }
    }

    @Test("Request permissions denied")
    func testRequestPermissionsDenied() async throws {
        try await withDependencies {
            $0.notificationClient.requestPermissions = {
                throw NotificationError.permissionDenied
            }
        } operation: {
            do {
                try await client.requestPermissions()
                #expect(Bool(false), "Should have thrown permission denied error")
            } catch is NotificationError {
                #expect(true)
            }
        }
    }

    @Test("Check for new items compares with last check time")
    func testCheckForNewItemsWithLastCheckTime() async throws {
        let lastCheckTime = Date().addingTimeInterval(-3600)
        let lastCheckTimeString = lastCheckTime.formatted(.dateTime)
        UserDefaults.standard.set(lastCheckTimeString, forKey: Constants.Notifications.lastNotificationCheckKey)
        
        let feed = testFeed()
        let oldItem = testItem(pubDate: lastCheckTime.addingTimeInterval(-600))
        let newItem = testItem(pubDate: lastCheckTime.addingTimeInterval(600))
        
        let notifications = LockIsolated<[String]>([])

        try await withDependencies {
            $0.rssClient = .init(
                fetchFeed: { _ in feed },
                fetchFeedItems: { _ in [oldItem, newItem] }
            )

            $0.persistenceClient = .init(
                saveFeed: { _ in },
                updateFeed: { _ in },
                deleteFeed: { _ in },
                loadFeeds: { [feed] }
            )
            
            $0.notificationClient = .init(
                requestPermissions: { },
                checkForNewItems: {
                    notifications.withValue { items in
                        items.append(newItem.title)
                    }
                }
            )
        } operation: {
            try await client.checkForNewItems()

            #expect(notifications.value.count == 1)
            #expect(notifications.value.first == newItem.title)
        }
    }
    
    @Test("First check saves date but doesn't send notifications")
    func testFirstCheckSavesDate() async throws {
        UserDefaults.standard.removeObject(forKey: Constants.Notifications.lastNotificationCheckKey)
        
        let feed = testFeed()
        let item = testItem(pubDate: Date().addingTimeInterval(-600))
        
        let notifications = LockIsolated<[String]>([])

        try await withDependencies {
            $0.rssClient = .init(
                fetchFeed: { _ in feed },
                fetchFeedItems: { _ in [item] }
            )

            $0.persistenceClient = .init(
                saveFeed: { _ in },
                updateFeed: { _ in },
                deleteFeed: { _ in },
                loadFeeds: { [feed] }
            )
            
            $0.notificationClient = .init(
                requestPermissions: { },
                checkForNewItems: { }
            )
        } operation: {
            try await client.checkForNewItems()
            
            #expect(notifications.value.isEmpty)
            #expect(UserDefaults.standard.string(forKey: Constants.Notifications.lastNotificationCheckKey) != nil)
        }
    }
    
    @Test("Skip notifications when unauthorized")
    func testSkipNotificationsWhenUnauthorized() async throws {
        try await withDependencies {
            $0.notificationClient = .init(
                requestPermissions: { },
                checkForNewItems: { throw NotificationError.permissionDenied }
            )
        } operation: {
            do {
                try await client.checkForNewItems()
                #expect(Bool(false), "Should have thrown permission denied error")
            } catch is NotificationError {
                #expect(true)
            }
        }
    }
    
    @Test("Notification format is correct")
    func testNotificationFormat() async throws {
        let lastCheckTime = Date().addingTimeInterval(-3600)
        let lastCheckTimeString = lastCheckTime.formatted(.dateTime)
        UserDefaults.standard.set(lastCheckTimeString, forKey: Constants.Notifications.lastNotificationCheckKey)
        
        let testFeed = self.testFeed()
        let testItem = self.testItem(pubDate: Date())
        
        let notificationInfo = LockIsolated<(title: String, body: String, identifier: String, threadId: String)?>(nil)

        try await withDependencies {
            $0.rssClient.fetchFeedItems = { _ in [testItem] }
            $0.persistenceClient.loadFeeds = { [testFeed] }
            
            $0.notificationClient = .init(
                requestPermissions: { },
                checkForNewItems: {
                    notificationInfo.setValue((
                        title: testFeed.title!,
                        body: testItem.title,
                        identifier: "notification-\(testFeed.url.absoluteString)-\(testItem.id.uuidString)",
                        threadId: testFeed.url.absoluteString
                    ))
                }
            )
        } operation: {
            try await client.checkForNewItems()
            
            #expect(notificationInfo.value != nil)
            
            if let info = notificationInfo.value {
                #expect(info.title == testFeed.title)
                #expect(info.body == testItem.title)
                #expect(info.threadId == testFeed.url.absoluteString)
                #expect(info.identifier.contains("notification-"))
                #expect(info.identifier.contains(testFeed.url.absoluteString))
                #expect(info.identifier.contains(testItem.id.uuidString))
            }
        }
    }
}

extension NotificationClient {
    static func testValue(
        requestPermissions: @escaping @Sendable () async throws -> Void = {},
        checkForNewItems: @escaping @Sendable () async throws -> Void = {}
    ) -> Self {
        Self(
            requestPermissions: requestPermissions,
            checkForNewItems: checkForNewItems
        )
    }
}
