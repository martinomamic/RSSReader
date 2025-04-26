import Foundation
import SharedModels
import Dependencies
import RSSClient
import PersistenceClient

private actor FeedRepositoryActor {
    private let continuation: AsyncStream<[Feed]>.Continuation
    @Dependency(\.rssClient) var rssClient
    @Dependency(\.persistenceClient) var persistenceClient
    
    init(continuation: AsyncStream<[Feed]>.Continuation) {
        self.continuation = continuation
    }
    
    func loadInitialFeeds() async throws {
        print("DEBUG: Starting initial feeds load")
        let feeds = try await persistenceClient.loadFeeds()
        print("DEBUG: Loaded \(feeds.count) feeds from persistence")
        continuation.yield(feeds)
        print("DEBUG: Yielded feeds to stream")
    }
    
    func add(url: URL) async throws {
        let feed = try await rssClient.fetchFeed(url)
        try await persistenceClient.saveFeed(feed)
        
        let feeds = try await persistenceClient.loadFeeds()
        continuation.yield(feeds)
    }
    
    func delete(url: URL) async throws {
        try await persistenceClient.deleteFeed(url)
        
        let feeds = try await persistenceClient.loadFeeds()
        continuation.yield(feeds)
    }
    
    func update(feed: Feed) async throws {
        try await persistenceClient.updateFeed(feed)
        
        let feeds = try await persistenceClient.loadFeeds()
        continuation.yield(feeds)
    }
    
    func toggleFavorite(url: URL) async throws {
        var feeds = try await persistenceClient.loadFeeds()
        guard var feed = feeds.first(where: { $0.url == url }) else {
            throw FeedRepositoryError.feedNotFound
        }
        
        feed.isFavorite.toggle()
        try await persistenceClient.updateFeed(feed)
        
        feeds = try await persistenceClient.loadFeeds()
        continuation.yield(feeds)
    }
    
    func toggleNotifications(url: URL) async throws {
        var feeds = try await persistenceClient.loadFeeds()
        guard var feed = feeds.first(where: { $0.url == url }) else {
            throw FeedRepositoryError.feedNotFound
        }
        
        feed.notificationsEnabled.toggle()
        try await persistenceClient.updateFeed(feed)
        
        feeds = try await persistenceClient.loadFeeds()
        continuation.yield(feeds)
    }
    
    func fetch(url: URL) async throws -> Feed {
        return try await rssClient.fetchFeed(url)
    }
}

extension FeedRepository {
    private static let continuation = AsyncStream.makeStream(of: [Feed].self)
    
    public static let live: FeedRepository = {
        
        
        let actor = FeedRepositoryActor(
            continuation: continuation.continuation
        )
        
        return Self(
            feedsStream: continuation.stream,
            fetch: { url in
                try await actor.fetch(url: url)
            },
            add: { url in
                try await actor.add(url: url)
            },
            delete: { url in
                try await actor.delete(url: url)
            },
            update: { feed in
                try await actor.update(feed: feed)
            },
            toggleFavorite: { url in
                try await actor.toggleFavorite(url: url)
            },
            toggleNotifications: { url in
                try await actor.toggleNotifications(url: url)
            },
            loadInitialFeeds: {
                try await actor.loadInitialFeeds()
            }
        )
    }()
}
