//
//  FeedRepositoryActor.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 27.04.25.
//

import Dependencies
import ExploreClient
import Foundation
import PersistenceClient
import RSSClient
import SharedModels

private actor FeedRepositoryActor {
    @Dependency(\.rssClient) private var rssClient
    @Dependency(\.persistenceClient) private var persistenceClient
    @Dependency(\.exploreClient) private var exploreClient

    private var feeds: [Feed] = []

    private static let allFeedsStreamPair = AsyncStream.makeStream(of: [Feed].self)
    private static let favoriteFeedsStreamPair = AsyncStream.makeStream(of: [Feed].self)

    private let allFeedsContinuation: AsyncStream<[Feed]>.Continuation
    private let favoriteFeedsContinuation: AsyncStream<[Feed]>.Continuation

    nonisolated let allFeedsStream: AsyncStream<[Feed]>
    nonisolated let favoriteFeedsStream: AsyncStream<[Feed]>

    init() {
        self.allFeedsStream = Self.allFeedsStreamPair.stream
        self.allFeedsContinuation = Self.allFeedsStreamPair.continuation
        self.favoriteFeedsStream = Self.favoriteFeedsStreamPair.stream
        self.favoriteFeedsContinuation = Self.favoriteFeedsStreamPair.continuation
    }

    private func broadcast(_ feeds: [Feed]) {
        self.feeds = feeds
        let favoriteFeedsToYield = feeds.filter { $0.isFavorite }
      
        Task { @MainActor in
            allFeedsContinuation.yield(feeds)
            favoriteFeedsContinuation.yield(favoriteFeedsToYield)
        }
    }

    func loadInitialFeeds() async throws {
        let loaded = try await persistenceClient.loadFeeds()
        broadcast(loaded)
    }

    func add(url: URL) async throws {
        let feedsBefore = try await persistenceClient.loadFeeds()
        if feedsBefore.contains(where: { $0.url == url }) {
            throw FeedRepositoryError.feedAlreadyExists
        }
        let feed = try await rssClient.fetchFeed(url)
        try await persistenceClient.saveFeed(feed)
        let updated = try await persistenceClient.loadFeeds()
        broadcast(updated)
    }

    func delete(url: URL) async throws {
        try await persistenceClient.deleteFeed(url)
        let updated = try await persistenceClient.loadFeeds()
        broadcast(updated)
    }

    func update(feed: Feed) async throws {
        try await persistenceClient.updateFeed(feed)
        let updated = try await persistenceClient.loadFeeds()
        broadcast(updated)
    }

    func toggleFavorite(url: URL) async throws {
        let feedsBefore = try await persistenceClient.loadFeeds()
        guard var feed = feedsBefore.first(where: { $0.url == url }) else { return }
        feed.isFavorite.toggle()
        try await persistenceClient.updateFeed(feed)
        let updated = try await persistenceClient.loadFeeds()
        broadcast(updated)
    }

    func toggleNotifications(url: URL) async throws {
        let feedsBefore = try await persistenceClient.loadFeeds()
        guard var feed = feedsBefore.first(where: { $0.url == url }) else { return }
        feed.notificationsEnabled.toggle()
        try await persistenceClient.updateFeed(feed)
        let updated = try await persistenceClient.loadFeeds()
        broadcast(updated)
    }

    func fetch(url: URL) async throws -> Feed {
        try await rssClient.fetchFeed(url)
    }

    func loadExploreFeeds() async throws -> [ExploreFeed] {
        try await exploreClient.loadExploreFeeds()
    }

    func addExploreFeed(_ exploreFeed: ExploreFeed) async throws -> Feed {
        let feed = try await exploreClient.addFeed(exploreFeed)
        let updated = try await persistenceClient.loadFeeds()
        broadcast(updated)
        return feed
    }

    func getCurrentFeeds() async throws -> [Feed] {
        try await persistenceClient.loadFeeds()
    }

    func fetchFeedItems(url: URL) async throws -> [FeedItem] {
        try await rssClient.fetchFeedItems(url)
    }

    deinit {
        allFeedsContinuation.finish()
        favoriteFeedsContinuation.finish()
    }
}

extension FeedRepository {
    public static let live: FeedRepository = {
        let actor = FeedRepositoryActor()
        return FeedRepository(
            feedsStream: actor.allFeedsStream,
            favoriteFeedsStream: actor.favoriteFeedsStream,
            fetch: { url in try await actor.fetch(url: url) },
            add: { url in try await actor.add(url: url) },
            delete: { url in try await actor.delete(url: url) },
            update: { feed in try await actor.update(feed: feed) },
            toggleFavorite: { url in try await actor.toggleFavorite(url: url) },
            toggleNotifications: { url in try await actor.toggleNotifications(url: url) },
            loadInitialFeeds: { try await actor.loadInitialFeeds() },
            loadExploreFeeds: { try await actor.loadExploreFeeds() },
            addExploreFeed: { feed in try await actor.addExploreFeed(feed) },
            getCurrentFeeds: { try await actor.getCurrentFeeds() },
            fetchItems: { feed in try await actor.fetchFeedItems(url: feed.url) }
        )
    }()
}
