import Testing
import Dependencies
import Foundation
import FeedRepository
import PersistenceClient
import RSSClient
import SharedModels

@Suite("FeedRepository Tests")
struct FeedRepositoryTests {
    @Test("Initial load emits correct feeds via stream")
    func testInitialLoadEmitsFeeds() async throws {
        let mockFeeds = [
            Feed(url: URL(string: "https://a.com")!, title: "A", isFavorite: false, notificationsEnabled: false),
            Feed(url: URL(string: "https://b.com")!, title: "B", isFavorite: true, notificationsEnabled: false)
        ]
       
        let repo = withDependencies {
            $0.persistenceClient = PersistenceClient(
                saveFeed: { _ in },
                updateFeed: { _ in },
                deleteFeed: { _ in },
                loadFeeds: { mockFeeds }
            )
        } operation: {
            FeedRepository.live
        }

        try await repo.loadInitialFeeds()
        await Task.yield()

        let stream = repo.feedsStream
        var iterator = stream.makeAsyncIterator()
        let first = await iterator.next()
        #expect(first == mockFeeds, "Initial stream value should match mock feeds")
    }
    
    @Test("Add feed operation adds feed and emits updates")
    func testAddFeed() async throws {
        let testURL = URL(string: "https://example.com/feed")!
        let testFeed = Feed(url: testURL, title: "Test Feed", description: "Test Description")
        
        let feedStore = LockIsolated<[Feed]>([])
        let continuation = AsyncStream.makeStream(of: [Feed].self)
        
        var repo = FeedRepository.testValue
        
        repo.feedsStream = continuation.stream
       
        repo.add = { _ in
                let feed = testFeed
                feedStore.withValue { feeds in
                    feeds.append(feed)
                }
                continuation.continuation.yield(feedStore.value)
            }
        
        var receivedFeeds: [Feed] = []
        let streamTask = Task {
            for await feeds in repo.feedsStream.prefix(2) {
                receivedFeeds = feeds
                if !feeds.isEmpty {
                    break
                }
            }
        }

        try await repo.add(testURL)

        let timeoutTask = Task {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            streamTask.cancel()
        }
        
        _ = await streamTask.result
        timeoutTask.cancel()
   
        #expect(feedStore.value.count == 1)
        #expect(feedStore.value[0].url == testURL)
        #expect(feedStore.value[0].title == "Test Feed")
        
        #expect(!receivedFeeds.isEmpty)
        #expect(receivedFeeds[0].url == testURL)
        #expect(receivedFeeds[0].title == "Test Feed")
    }
    
    @Test("Delete feed operation removes feed and emits updates")
    func testDeleteFeed() async throws {
        let testURL = URL(string: "https://example.com/feed")!
        let testFeed = Feed(url: testURL, title: "Test Feed", description: "Test Description")
        
        let feedStore = LockIsolated<[Feed]>([testFeed])
        let continuation = AsyncStream.makeStream(of: [Feed].self)
        
        var repo = FeedRepository.testValue
        
        repo.feedsStream = continuation.stream
        
        repo.delete = { url in
            feedStore.withValue { feeds in
                feeds.removeAll(where: { $0.url == url })
            }
            continuation.continuation.yield(feedStore.value)
        }
        
        continuation.continuation.yield(feedStore.value)
        
        var receivedFeeds: [Feed] = []
        let streamTask = Task {
            for await feeds in repo.feedsStream.prefix(3) {
                receivedFeeds = feeds
            }
        }
        
        try await repo.delete(testURL)
        
        let timeoutTask = Task {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            streamTask.cancel()
        }
        
        _ = await streamTask.result
        timeoutTask.cancel()
        
        #expect(feedStore.value.isEmpty)
        
        #expect(receivedFeeds.isEmpty)
    }

    @Test("Toggle favorite updates feed's favorite status and emits updates")
    func testToggleFavorite() async throws {
        let testURL = URL(string: "https://example.com/feed")!
        let testFeed = Feed(url: testURL, title: "Test Feed", description: "Test Description", isFavorite: false)
        
        let feedStore = LockIsolated<[Feed]>([testFeed])
        let continuation = AsyncStream.makeStream(of: [Feed].self)
        
        var repo = FeedRepository.testValue
        
        repo.feedsStream = continuation.stream
        
        repo.toggleFavorite = { url in
            feedStore.withValue { feeds in
                if let index = feeds.firstIndex(where: { $0.url == url }) {
                    feeds[index].isFavorite.toggle()
                }
            }
            continuation.continuation.yield(feedStore.value)
        }
        continuation.continuation.yield(feedStore.value)
        
        var receivedFeeds: [Feed] = []
        let streamTask = Task {
            for await feeds in repo.feedsStream.prefix(3) {
                receivedFeeds = feeds
            }
        }
        
        try await repo.toggleFavorite(testURL)
        
        let timeoutTask = Task {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            streamTask.cancel()
        }
        
        _ = await streamTask.result
        timeoutTask.cancel()
        
        #expect(feedStore.value.count == 1)
        #expect(feedStore.value[0].isFavorite == true)
        
        #expect(receivedFeeds.count == 1)
        #expect(receivedFeeds[0].isFavorite == true)
    }

    @Test("Toggle notifications updates feed's notification status and emits updates")
    func testToggleNotifications() async throws {
        let testURL = URL(string: "https://example.com/feed")!
        let testFeed = Feed(url: testURL, title: "Test Feed", description: "Test Description", notificationsEnabled: false)
        
        let feedStore = LockIsolated<[Feed]>([testFeed])
        let continuation = AsyncStream.makeStream(of: [Feed].self)
        
        var repo = FeedRepository.testValue
        
        repo.feedsStream = continuation.stream
        
        repo.toggleNotifications = { url in
            feedStore.withValue { feeds in
                if let index = feeds.firstIndex(where: { $0.url == url }) {
                    feeds[index].notificationsEnabled.toggle()
                }
            }
            continuation.continuation.yield(feedStore.value)
        }
        
        // Inicijalno emitiraj feedove
        continuation.continuation.yield(feedStore.value)
        
        var receivedFeeds: [Feed] = []
        let streamTask = Task {
            for await feeds in repo.feedsStream.prefix(3) {
                receivedFeeds = feeds
            }
        }

        try await repo.toggleNotifications(testURL)
        
        let timeoutTask = Task {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            streamTask.cancel()
        }
        
        _ = await streamTask.result
        timeoutTask.cancel()

        #expect(feedStore.value.count == 1)
        #expect(feedStore.value[0].notificationsEnabled == true)

        #expect(receivedFeeds.count == 1)
        #expect(receivedFeeds[0].notificationsEnabled == true)
    }
}
