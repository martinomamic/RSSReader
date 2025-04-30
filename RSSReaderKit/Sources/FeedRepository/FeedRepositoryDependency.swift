import Foundation
import Dependencies
import SharedModels

extension FeedRepository: DependencyKey {
    public static var liveValue: FeedRepository { .live }
    
    public static var testValue: FeedRepository {
        let feedStore = LockIsolated<[Feed]>([])
        let continuation = AsyncStream.makeStream(of: [Feed].self)
        
        return FeedRepository(
            feedsStream: continuation.stream,
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
                continuation.continuation.yield(feedStore.value)
            },
            delete: { url in
                feedStore.withValue { feeds in
                    feeds.removeAll(where: { $0.url == url })
                }
                continuation.continuation.yield(feedStore.value)
            },
            update: { feed in
                feedStore.withValue { feeds in
                    if let index = feeds.firstIndex(where: { $0.url == feed.url }) {
                        feeds[index] = feed
                    }
                }
                continuation.continuation.yield(feedStore.value)
            },
            toggleFavorite: { url in
                feedStore.withValue { feeds in
                    guard let index = feeds.firstIndex(where: { $0.url == url }) else {
                        return
                    }
                    feeds[index].isFavorite.toggle()
                }
                continuation.continuation.yield(feedStore.value)
            },
            toggleNotifications: { url in
                feedStore.withValue { feeds in
                    guard let index = feeds.firstIndex(where: { $0.url == url }) else {
                        return
                    }
                    feeds[index].notificationsEnabled.toggle()
                }
                continuation.continuation.yield(feedStore.value)
            },
            loadInitialFeeds:    {
                continuation.continuation.yield(feedStore.value)
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
