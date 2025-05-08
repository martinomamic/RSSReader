//
//  FeedRepository.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 27.04.25.
//

//
//  FeedRepositoryDependency.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 27.04.25.
//

import Dependencies
import ExploreClient
import Foundation
import SharedModels

extension FeedRepository: DependencyKey {
    public static var liveValue: FeedRepository { .live }
    
    public static var testValue: FeedRepository {
        let feedStore = LockIsolated<[Feed]>([])
        let allFeedsContinuation = AsyncStream.makeStream(of: [Feed].self)
        let favoriteFeedsContinuation = AsyncStream.makeStream(of: [Feed].self)
        
        return FeedRepository(
            feedsStream: allFeedsContinuation.stream,
            favoriteFeedsStream: favoriteFeedsContinuation.stream,
            
            fetch: { url in
                guard let feed = feedStore.value.first(where: { $0.url == url }) else {
                    throw FeedRepositoryError.feedNotFound
                }
                return feed
            },
            add: { url in
                let feed = Feed(url: url)
                feedStore.withValue { feeds in
                    feeds.append(feed)
                }
                allFeedsContinuation.continuation.yield(feedStore.value)
                favoriteFeedsContinuation.continuation.yield(feedStore.value.filter { $0.isFavorite })
            },
            delete: { url in
                feedStore.withValue { feeds in
                    feeds.removeAll(where: { $0.url == url })
                }
                allFeedsContinuation.continuation.yield(feedStore.value)
                favoriteFeedsContinuation.continuation.yield(feedStore.value.filter { $0.isFavorite })
            },
            update: { feed in
                feedStore.withValue { feeds in
                    guard let index = feeds.firstIndex(where: { $0.url == feed.url }) else {
                        return
                    }
                    feeds[index] = feed
                }
                allFeedsContinuation.continuation.yield(feedStore.value)
                favoriteFeedsContinuation.continuation.yield(feedStore.value.filter { $0.isFavorite })
            },
            toggleFavorite: { url in
                feedStore.withValue { feeds in
                    guard let index = feeds.firstIndex(where: { $0.url == url }) else {
                        return
                    }
                    feeds[index].isFavorite.toggle()
                }
                allFeedsContinuation.continuation.yield(feedStore.value)
                favoriteFeedsContinuation.continuation.yield(feedStore.value.filter { $0.isFavorite })
            },
            toggleNotifications: { url in
                feedStore.withValue { feeds in
                    guard let index = feeds.firstIndex(where: { $0.url == url }) else {
                        return
                    }
                    feeds[index].notificationsEnabled.toggle()
                }
                allFeedsContinuation.continuation.yield(feedStore.value)
                favoriteFeedsContinuation.continuation.yield(feedStore.value.filter { $0.isFavorite })
            },
            loadInitialFeeds: {
                allFeedsContinuation.continuation.yield(feedStore.value)
                favoriteFeedsContinuation.continuation.yield(feedStore.value.filter { $0.isFavorite })
            },
            loadExploreFeeds: {
                [
                    ExploreFeed(name: "Test Feed", url: "https://example.com/feed"),
                    ExploreFeed(name: "Another Feed", url: "https://example.org/rss")
                ]
            },
            addExploreFeed: { exploreFeed in
                guard let url = URL(string: exploreFeed.url) else {
                    throw ExploreError.invalidURL
                }

                return Feed(
                    url: url,
                    title: exploreFeed.name,
                    description: "Test feed description"
                )
            },
            getCurrentFeeds: {
                feedStore.value
            },
            fetchItems: { _ in
                [
                    FeedItem(feedID: UUID(), title: "Test Item", link: URL(string: "https://example.com/feed")!)
                ]
            }
        )
    }
}

extension DependencyValues {
    public var feedRepository: FeedRepository {
        get { self[FeedRepository.self] }
        set { self[FeedRepository.self] = newValue }
    }
}
