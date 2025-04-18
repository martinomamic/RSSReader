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
import UserNotifications

@testable import NotificationClient
@testable import SharedModels
@testable import RSSClient
@testable import PersistenceClient

@Suite struct NotificationClientTests {
    
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
        
        try await withDependencies { deps in
            deps.notificationClient = .init(
                requestPermissions: {
                    permissionsRequested.setValue(true)
                },
                checkForNewItems: {}
            )
        } operation: {
            @Dependency(\.notificationClient) var client
            try await client.requestPermissions()
            #expect(permissionsRequested.value)
        }
    }
    
    @Test("Request permissions denied")
    func testRequestPermissionsDenied() async throws {
        try await withDependencies { deps in
            deps.notificationClient = .init(
                requestPermissions: { throw NotificationError.permissionDenied },
                checkForNewItems: {}
            )
        } operation: {
            @Dependency(\.notificationClient) var client
            
            do {
                try await client.requestPermissions()
                #expect(Bool(false), "Should have thrown permission denied error")
            } catch is NotificationError {
                
            }
        }
    }
    
    @Test("Check for new items")
    func testCheckForNewItems() async throws {
        let feed = testFeed()
        let item = testItem(pubDate: Date().addingTimeInterval(60))
        
        let notifications = LockIsolated<[(title: String, body: String)]>([])
        let notifiedItems = LockIsolated<[String]>([])
        let lastCheckTime = LockIsolated<Date?>(nil)
        
        try await withDependencies { deps in
            deps.rssClient = .init(
                fetchFeed: { _ in feed },
                fetchFeedItems: { _ in [item] }
            )
            
            deps.persistenceClient = .init(
                addFeed: { _ in },
                updateFeed: { _ in },
                deleteFeed: { _ in },
                loadFeeds: { [feed] }
            )
            
            deps.notificationClient = .init(
                requestPermissions: {},
                checkForNewItems: {
                    @Dependency(\.persistenceClient) var persistenceClient
                    @Dependency(\.rssClient) var rssClient
                    
                    let lastCheck = lastCheckTime.value ?? Date.distantPast
                    
                    let feeds = try await persistenceClient.loadFeeds()
                    let enabledFeeds = feeds.filter(\.notificationsEnabled)
                    
                    for feed in enabledFeeds {
                        let items = try await rssClient.fetchFeedItems(feed.url)
                        
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
            @Dependency(\.notificationClient) var client
            try await client.checkForNewItems()
            
            #expect(notifications.value.count == 1)
            #expect(notifications.value.first?.title == feed.title)
            #expect(notifications.value.first?.body == item.title)
            
            #expect(notifiedItems.value.contains(item.id.uuidString))
        }
    }
}
