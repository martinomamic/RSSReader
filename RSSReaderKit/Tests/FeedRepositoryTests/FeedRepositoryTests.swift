import Testing
import Dependencies
import Foundation
import FeedRepository
import PersistenceClient
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
}
