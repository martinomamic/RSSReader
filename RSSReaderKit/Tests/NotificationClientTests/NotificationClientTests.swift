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

    @Test("Check for new items with thread identifier")
    func testCheckForNewItemsWithThreading() async throws {
        let feed = testFeed()
        let item = testItem(pubDate: Date().addingTimeInterval(60))
        let notificationRequests = LockIsolated<[UNNotificationRequest]>([])

        try await withDependencies {
            $0.rssClient.fetchFeedItems = { _ in [item] }
            $0.persistenceClient.loadFeeds = { [feed] }
            
            $0.notificationClient = .testValue(
                requestPermissions: {},
                checkForNewItems: {
                    notificationRequests.withValue { requests in
                        requests.append(UNNotificationRequest(
                            identifier: "test-id",
                            content: {
                                let content = UNMutableNotificationContent()
                                content.threadIdentifier = feed.url.absoluteString
                                content.title = feed.title ?? ""
                                content.body = item.title
                                return content
                            }(),
                            trigger: nil
                        ))
                    }
                }
            )
        } operation: {
            try await client.checkForNewItems()

            let requests = notificationRequests.value
            #expect(requests.count == 1)
            #expect(requests[0].content.threadIdentifier == feed.url.absoluteString)
            #expect(requests[0].content.title == feed.title)
            #expect(requests[0].content.body == item.title)
        }
    }

    @Test("Skip notifications for disabled feeds")
    func testSkipNotificationsForDisabledFeeds() async throws {
        let feed = testFeed(notificationsEnabled: false)
        let item = testItem(pubDate: Date().addingTimeInterval(60))
        let notificationRequests = LockIsolated<[UNNotificationRequest]>([])

        try await withDependencies {
            $0.rssClient.fetchFeedItems = { _ in [item] }
            $0.persistenceClient.loadFeeds = { [feed] }
            
            $0.notificationClient = .testValue(
                requestPermissions: {},
                checkForNewItems: { }
            )
        } operation: {
            try await client.checkForNewItems()
            
            #expect(notificationRequests.value.isEmpty)
        }
    }
    
    @Test("Skip notifications when unauthorized")
    func testSkipNotificationsWhenUnauthorized() async throws {
        let feed = testFeed()
        let item = testItem(pubDate: Date().addingTimeInterval(60))
        let notificationRequests = LockIsolated<[UNNotificationRequest]>([])

        try await withDependencies {
            $0.rssClient.fetchFeedItems = { _ in [item] }
            $0.persistenceClient.loadFeeds = { [feed] }
            
            $0.notificationClient = .testValue(
                requestPermissions: {},
                checkForNewItems: { throw NotificationError.permissionDenied }
            )
        } operation: {
            @Dependency(\.notificationClient) var client
            
            do {
                try await client.checkForNewItems()
                #expect(Bool(false), "Should have thrown permission denied error")
            } catch is NotificationError {
                #expect(true)
            }
            #expect(notificationRequests.value.isEmpty)
        }
    }

    @Test("Check for new items")
    func testCheckForNewItems() async throws {
        let feed = testFeed()
        let item = testItem(pubDate: Date().addingTimeInterval(60))

        let notifications = LockIsolated<[(title: String, body: String)]>([])
        let notifiedItems = LockIsolated<[String]>([])
        let lastCheckTime = LockIsolated<Date?>(nil)

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
                requestPermissions: {},
                checkForNewItems: {
                    @Dependency(\.persistenceClient.loadFeeds) var loadSavedFeeds
                    @Dependency(\.rssClient.fetchFeedItems) var fetchFeedItems

                    let lastCheck = lastCheckTime.value ?? Date.distantPast

                    let feeds = try await loadSavedFeeds()
                    let enabledFeeds = feeds.filter(\.notificationsEnabled)

                    for feed in enabledFeeds {
                        let items = try await fetchFeedItems(feed.url)

                        for item in items {
                            guard let pubDate = item.pubDate else { continue }

                            let shouldNotify = pubDate > lastCheck &&
                                !notifiedItems.value.contains(item.id.uuidString)

                            if shouldNotify {
                                notifications.withValue { notifications in
                                    notifications.append((
                                        title: feed.title ?? "New item in feed",
                                        body: item.title
                                    ))
                                }

                                notifiedItems.withValue { items in
                                    items.append(item.id.uuidString)
                                }
                            }
                        }
                    }

                    lastCheckTime.setValue(Date())
                }
            )
        } operation: {
            try await client.checkForNewItems()

            #expect(notifications.value.count == 1)
            #expect(notifications.value.first?.title == feed.title)
            #expect(notifications.value.first?.body == item.title)

            #expect(notifiedItems.value.contains(item.id.uuidString))
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
