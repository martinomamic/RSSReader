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
    private let continuation: AsyncStream<[Feed]>.Continuation
    @Dependency(\.rssClient) var rssClient
    @Dependency(\.persistenceClient) var persistenceClient
    @Dependency(\.exploreClient) private var exploreClient
    
    private var initialLoadTask: Task<Void, Error>?
    private var modifyingURLs: Set<URL> = []
    
    init(continuation: AsyncStream<[Feed]>.Continuation) {
        self.continuation = continuation
    }
    
    func loadInitialFeeds() async throws {
        if let existingTask = initialLoadTask {
            return try await existingTask.value
        }
        let task = Task {
            let feeds = try await persistenceClient.loadFeeds()
            continuation.yield(feeds)
        }
        
        initialLoadTask = task
        
        defer {
            initialLoadTask = nil
        }
        
        try await task.value
    }
    
    func add(url: URL) async throws {
        guard !modifyingURLs.contains(url) else { return }
        modifyingURLs.insert(url)
        defer { modifyingURLs.remove(url) }
        
        let feedsBefore = try await persistenceClient.loadFeeds()
        if feedsBefore.contains(where: { $0.url == url }) {
            throw FeedRepositoryError.feedAlreadyExists
        }
        let feed = try await rssClient.fetchFeed(url)
        try await persistenceClient.saveFeed(feed)
        let feeds = try await persistenceClient.loadFeeds()
        continuation.yield(feeds)
    }
    
    func delete(url: URL) async throws {
        guard !modifyingURLs.contains(url) else {
            return
        }
        modifyingURLs.insert(url)
        defer { modifyingURLs.remove(url) }
        
        try await persistenceClient.deleteFeed(url)
        let feeds = try await persistenceClient.loadFeeds()
        continuation.yield(feeds)
    }
    
    func update(feed: Feed) async throws {
        guard !modifyingURLs.contains(feed.url) else { return }
        modifyingURLs.insert(feed.url)
        defer { modifyingURLs.remove(feed.url) }
        
        try await persistenceClient.updateFeed(feed)
        let feeds = try await persistenceClient.loadFeeds()
        continuation.yield(feeds)
    }
    
    func toggleFavorite(url: URL) async throws {
        guard !modifyingURLs.contains(url) else { return }
        modifyingURLs.insert(url)
        defer { modifyingURLs.remove(url) }
        
        let feedsBefore = try await persistenceClient.loadFeeds()
        guard var feed = feedsBefore.first(where: { $0.url == url }) else { return }
        feed.isFavorite.toggle()
        try await persistenceClient.updateFeed(feed)
        let feeds = try await persistenceClient.loadFeeds()
        continuation.yield(feeds)
    }
    
    func toggleNotifications(url: URL) async throws {
        guard !modifyingURLs.contains(url) else { return }
        modifyingURLs.insert(url)
        defer { modifyingURLs.remove(url) }
        
        let feedsBefore = try await persistenceClient.loadFeeds()
        guard var feed = feedsBefore.first(where: { $0.url == url }) else { return }
        feed.notificationsEnabled.toggle()
        try await persistenceClient.updateFeed(feed)
        let feeds = try await persistenceClient.loadFeeds()
        continuation.yield(feeds)
    }
    
    func fetch(url: URL) async throws -> Feed {
        return try await rssClient.fetchFeed(url)
    }
    
    func loadExploreFeeds() async throws -> [ExploreFeed] {
        return try await exploreClient.loadExploreFeeds()
    }
    
    func addExploreFeed(_ exploreFeed: ExploreFeed) async throws -> Feed {
        let feed = try await exploreClient.addFeed(exploreFeed)
        
        let feeds = try await getCurrentFeeds()
        continuation.yield(feeds)
        
        return feed
    }
    
    func getCurrentFeeds() async throws -> [Feed] {
        return try await persistenceClient.loadFeeds()
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
            },
            loadExploreFeeds: {
                try await actor.loadExploreFeeds()
            },
            addExploreFeed: { exploreFeed in
                try await actor.addExploreFeed(exploreFeed)
            },
            getCurrentFeeds: {
                try await actor.getCurrentFeeds()
            }
        )
    }()
}
