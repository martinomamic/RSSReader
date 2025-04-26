import Foundation
import SharedModels
import Dependencies
import RSSClient
import PersistenceClient

extension FeedRepository: DependencyKey {
    public static var liveValue: FeedRepository = {
        let continuation = AsyncStream.makeStream(of: [Feed].self)
        
        return Self(
            feedsStream: continuation.stream,
            fetch: { url in
                @Dependency(\.rssClient) var rssClient
                return try await rssClient.fetchFeed(url)
            },
            add: { url in
                @Dependency(\.rssClient) var rssClient
                @Dependency(\.persistenceClient) var persistenceClient
                
                let feed = try await rssClient.fetchFeed(url)
                try await persistenceClient.saveFeed(feed)
                
                let feeds = try await persistenceClient.loadFeeds()
                continuation.continuation.yield(feeds)
                
                return feed
            },
            delete: { url in
                @Dependency(\.persistenceClient) var persistenceClient
                
                try await persistenceClient.deleteFeed(url)
                let feeds = try await persistenceClient.loadFeeds()
                continuation.continuation.yield(feeds)
            },
            update: { feed in
                @Dependency(\.persistenceClient) var persistenceClient
                
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
                try await persistenceClient.updateFeed(feed)
                
                let updatedFeeds = try await persistenceClient.loadFeeds()
                continuation.continuation.yield(updatedFeeds)
            },
            refreshAll: {
                @Dependency(\.rssClient) var rssClient
                @Dependency(\.persistenceClient) var persistenceClient
                
                let feeds = try await persistenceClient.loadFeeds()
                for feed in feeds {
                    let updatedFeed = try await rssClient.fetchFeed(feed.url)
                    try await persistenceClient.updateFeed(updatedFeed)
                }
                
                let updatedFeeds = try await persistenceClient.loadFeeds()
                continuation.continuation.yield(updatedFeeds)
            }
        )
    }()
}