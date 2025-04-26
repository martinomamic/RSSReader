import Foundation
import SharedModels
import Dependencies
import RSSClient
import PersistenceClient

extension FeedRepository {
    private static let continuation = AsyncStream.makeStream(of: [Feed].self)
    
    public static let live: FeedRepository = {
        print("FeedRepository: Creating live instance") // Debug
        
        // Load initial feeds
        Task {
            @Dependency(\.persistenceClient) var persistenceClient
            do {
                print("FeedRepository: Loading initial feeds") // Debug
                let feeds = try await persistenceClient.loadFeeds()
                print("FeedRepository: Found \(feeds.count) feeds in persistence") // Debug
                continuation.continuation.yield(feeds)
                print("FeedRepository: Yielded initial feeds to stream") // Debug
            } catch {
                print("FeedRepository: Failed to load initial feeds: \(error)") // Debug
            }
        }
        
        let repository = Self(
            feedsStream: continuation.stream,
            fetch: { url in
                @Dependency(\.rssClient) var rssClient
                return try await rssClient.fetchFeed(url)
            },
            add: { url in
                @Dependency(\.rssClient) var rssClient
                @Dependency(\.persistenceClient) var persistenceClient
                
                let feed = try await rssClient.fetchFeed(url)
                print("FeedRepository: Adding new feed: \(url)") // Debug
                try await persistenceClient.saveFeed(feed)
                
                let feeds = try await persistenceClient.loadFeeds()
                print("FeedRepository: Current feeds count after add: \(feeds.count)") // Debug
                continuation.continuation.yield(feeds)
            },
            delete: { url in
                @Dependency(\.persistenceClient) var persistenceClient
                print("FeedRepository: Deleting feed: \(url)") // Debug
                try await persistenceClient.deleteFeed(url)
                
                let feeds = try await persistenceClient.loadFeeds()
                continuation.continuation.yield(feeds)
            },
            update: { feed in
                @Dependency(\.persistenceClient) var persistenceClient
                print("FeedRepository: Updating feed: \(feed.url)") // Debug
                try await persistenceClient.updateFeed(feed)
                
                let feeds = try await persistenceClient.loadFeeds()
                continuation.continuation.yield(feeds)
            },
            toggleFavorite: { url in
                @Dependency(\.persistenceClient) var persistenceClient
                
                let feeds = try await persistenceClient.loadFeeds()
                guard var feed = feeds.first(where: { $0.url == url }) else {
                    throw FeedRepositoryError.feedNotFound
                }
                
                feed.isFavorite.toggle()
                print("FeedRepository: Toggling favorite for: \(url) to \(feed.isFavorite)") // Debug
                try await persistenceClient.updateFeed(feed)
                
                let updatedFeeds = try await persistenceClient.loadFeeds()
                continuation.continuation.yield(updatedFeeds)
            },
            toggleNotifications: { url in
                @Dependency(\.persistenceClient) var persistenceClient
                
                let feeds = try await persistenceClient.loadFeeds()
                guard var feed = feeds.first(where: { $0.url == url }) else {
                    throw FeedRepositoryError.feedNotFound
                }
                
                feed.notificationsEnabled.toggle()
                print("FeedRepository: Toggling notifications for: \(url) to \(feed.notificationsEnabled)") // Debug
                try await persistenceClient.updateFeed(feed)
                
                let updatedFeeds = try await persistenceClient.loadFeeds()
                continuation.continuation.yield(updatedFeeds)
            },
            refreshAll: {
                @Dependency(\.rssClient) var rssClient
                @Dependency(\.persistenceClient) var persistenceClient
                
                print("FeedRepository: Starting refresh all") // Debug
                let feeds = try await persistenceClient.loadFeeds()
                print("FeedRepository: Found \(feeds.count) feeds to refresh") // Debug
                
                for feed in feeds {
                    let updatedFeed = try await rssClient.fetchFeed(feed.url)
                    var feedToUpdate = updatedFeed
                    feedToUpdate.isFavorite = feed.isFavorite
                    feedToUpdate.notificationsEnabled = feed.notificationsEnabled
                    try await persistenceClient.updateFeed(feedToUpdate)
                }
                
                let updatedFeeds = try await persistenceClient.loadFeeds()
                continuation.continuation.yield(updatedFeeds)
                print("FeedRepository: Refresh complete, yielded \(updatedFeeds.count) feeds") // Debug
            }
        )
        
        return repository
    }()
}
