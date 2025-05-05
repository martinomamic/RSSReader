import Testing
import Dependencies
import Foundation
import Common
import SharedModels

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
                [Feed(url: URL(string: "https://example.com")!, notificationsEnabled: true)]
            }
            $0.feedRepository.fetchItems = { _ in
                [FeedItem(
                    feedID: UUID(),
                    title: "Test",
                    link: URL(string: "https://example.com")!,
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
                [Feed(url: URL(string: "https://example.com")!, title: "Test Feed")]
            }
            $0.rssClient.fetchFeedItems = { _ in
                [FeedItem(
                    feedID: UUID(),
                    title: "Test Item",
                    link: URL(string: "https://example.com")!
                )]
            }
        } operation: {
            let client = BackgroundRefreshClient.live()
            let result = await client.testFeedParsing()
            #expect(!result.isEmpty)
            #expect(result.contains("Test Feed"))
        }
    }
}
