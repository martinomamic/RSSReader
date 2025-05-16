//
//  BackgroundRefreshClientTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamic on 08.05.25.
//

import Common
import Dependencies
import Foundation
import SharedModels
import Testing
import TestUtility

@testable import BackgroundRefreshClient
@testable import UserNotificationClient
@testable import FeedRepository

@Suite struct BackgroundRefreshClientTests {
    @Test("Configure sets up background tasks")
    func testConfigure() async throws {
        let client = BackgroundRefreshClient.testValue
        client.configure()
    }
    
    @Test("Schedule app refresh")
    func testScheduleAppRefresh() async throws {
        let client = BackgroundRefreshClient.testValue
        await client.scheduleAppRefresh()
    }
    
    @Test("Scene did enter background")
    func testSceneDidEnterBackground() async throws {
        let client = BackgroundRefreshClient.testValue
        await client.sceneDidEnterBackground()
    }
    
    @Test("Manually trigger background refresh success")
    func testManuallyTriggerBackgroundRefreshSuccess() async throws {
        await withDependencies {
            $0.feedRepository.getCurrentFeeds = {
                [SharedMocks.createFeed(urlString: "https://example.com", notificationsEnabled: true)]
            }
            $0.feedRepository.fetchItems = { _ in
                [SharedMocks.createFeedItem(
                    title: "Test",
                    linkString: "https://example.com",
                    pubDate: Date()
                )]
            }
            $0.userDefaults.getLastNotificationCheckTime = { Date().addingTimeInterval(-3600) }
        } operation: {
            let client = BackgroundRefreshClient.live()
            let success = await client.manuallyTriggerBackgroundRefresh()
            #expect(success)
        }
    }
    
    @Test("Test feed parsing")
    func testFeedParsing() async throws {
        await withDependencies {
            $0.persistenceClient.loadFeeds = {
                [SharedMocks.createFeed(urlString: "https://example.com", title: "Test Feed")]
            }
            $0.rssClient.fetchFeedItems = { _ in
                [SharedMocks.createFeedItem(
                    title: "Test Item",
                    linkString: "https://example.com"
                )]
            }
        } operation: {
            let client = BackgroundRefreshClient.live()
            let result = await client.testFeedParsing()
            #expect(!result.isEmpty)
            #expect(result.contains("Test Feed"))
        }
    }
    
        @Test("Schedule app refresh - no enabled feeds")
        func testScheduleAppRefreshNoEnabledFeeds() async throws {
            await withDependencies {
                $0.feedRepository.getCurrentFeeds = {
                    [
                        SharedMocks.createFeed(urlString: "https://example1.com", notificationsEnabled: false),
                        SharedMocks.createFeed(urlString: "https://example2.com", notificationsEnabled: false)
                    ]
                }
            } operation: {
                let client = BackgroundRefreshClient.live()
                await client.scheduleAppRefresh()
            }
        }

        @Test("Manually trigger background refresh - no enabled feeds")
        func testManuallyTriggerBackgroundRefreshNoEnabledFeeds() async throws {
            await withDependencies {
                $0.feedRepository.getCurrentFeeds = {
                    [
                        SharedMocks.createFeed(urlString: "https://example1.com", notificationsEnabled: false)
                    ]
                }
            } operation: {
                let client = BackgroundRefreshClient.live()
                let success = await client.manuallyTriggerBackgroundRefresh()
                #expect(success, "Refresh should 'succeed' (not throw) even with no enabled feeds, as it's not an error state for refreshFeeds itself.")
            }
        }

        @Test("Manually trigger background refresh - fetchItems error")
        func testManuallyTriggerBackgroundRefreshFetchItemsError() async throws {
            await withDependencies {
                $0.feedRepository.getCurrentFeeds = {
                    [SharedMocks.createFeed(urlString: "https://failing.com", notificationsEnabled: true)]
                }
                $0.feedRepository.fetchItems = { _ in
                    throw NSError(domain: "TestError", code: 123)
                }
                $0.userDefaults.getLastNotificationCheckTime = { Date().addingTimeInterval(-3600) }
            } operation: {
                let client = BackgroundRefreshClient.live()
                let success = await client.manuallyTriggerBackgroundRefresh()
                #expect(!success, "Refresh should fail if fetchItems throws an error for an enabled feed.")
            }
        }
        
        @Test("Manually trigger background refresh - items are old")
        func testManuallyTriggerBackgroundRefreshItemsAreOld() async throws {
            let veryOldDate = Date().addingTimeInterval(-7200)
            let lastCheck = Date().addingTimeInterval(-3600)
            let notificationSent: LockIsolated<Bool> = LockIsolated(false)

            await withDependencies {
                $0.feedRepository.getCurrentFeeds = {
                    [SharedMocks.createFeed(urlString: "https://example.com", notificationsEnabled: true)]
                }
                $0.feedRepository.fetchItems = { _ in
                    [SharedMocks.createFeedItem(title: "Old Item", pubDate: veryOldDate)]
                }
                $0.userDefaults.getLastNotificationCheckTime = { lastCheck }
                $0.userDefaults.setLastNotificationCheckTime = { _ in }
                $0.userNotifications.sendTestNotification = { _, _, _ in
                    notificationSent.setValue(true)
                    throw NSError(domain: "ShouldNotBeCalled", code: 0)
                }
            } operation: {
                let client = BackgroundRefreshClient.live()
                let success = await client.manuallyTriggerBackgroundRefresh()
                #expect(success, "Refresh should succeed even if items are old.")
                #expect(!notificationSent.value, "No notification should be sent for old items.")
            }
        }

        @Test("Scene did enter background - scheduling needed")
        func testSceneDidEnterBackgroundSchedulingNeeded() async throws {
            let client = BackgroundRefreshClient.live()
            await client.sceneDidEnterBackground()
        }

        @Test("Get background task status")
        func testGetBackgroundTaskStatus() async throws {
            await withDependencies {_ in }
            operation: {
                let client = BackgroundRefreshClient.live()
                client.configure()
                let status = await client.getBackgroundTaskStatus()
                #expect(status == "Background task scheduler is configured")
            }
        }
        
        @Test("Manually trigger background refresh - error in sending notification")
        func testManuallyTriggerBackgroundRefreshNotificationError() async throws {
            let now = Date()
            let feed = SharedMocks.createFeed(notificationsEnabled: true)
            let newItem = SharedMocks.createFeedItem(pubDate: now.addingTimeInterval(100))
            let didAttemptSend = LockIsolated(false)

            await withDependencies {
                $0.feedRepository.getCurrentFeeds = { [feed] }
                $0.feedRepository.fetchItems = { _ in [newItem] }
                $0.userDefaults.getLastNotificationCheckTime = { now }
                $0.userDefaults.setLastNotificationCheckTime = { _ in }
                $0.userNotifications.sendTestNotification = { _, _, _ in
                    didAttemptSend.setValue(true)
                    throw NSError(domain: "", code: 1)
                }
            } operation: {
                let client = BackgroundRefreshClient.live()
                let success = await client.manuallyTriggerBackgroundRefresh()
                #expect(!success, "Refresh should fail if sending notification fails.")
                #expect(didAttemptSend.value, "Should attempt to send notification.")
            }
        }

}
