//
//  TestHelpers.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 21.04.25.
//

import Foundation
import SharedModels
import RSSClient
import Common
import Dependencies

@testable import FeedListFeature
import PersistenceClient

enum TestHelpers {
    static func createTestFeed(
        url: String = "https://example.com",
        title: String = "Test Feed",
        description: String = "Test Description",
        isFavorite: Bool = false,
        notificationsEnabled: Bool = false,
        withImage: Bool = false
    ) -> Feed {
        Feed(
            url: URL(string: url)!,
            title: title,
            description: description,
            imageURL: withImage ? URL(string: "https://example.com/image.jpg") : nil,
            isFavorite: isFavorite,
            notificationsEnabled: notificationsEnabled
        )
    }
    
    @MainActor
    static func createFeedViewModel(feed: Feed, state: FeedViewState = .loading) -> FeedViewModel {
        let viewModel = FeedViewModel(url: feed.url, feed: feed)
        viewModel.state = state
        return viewModel
    }
    
    static func mockDependenciesWithFeeds(_ feeds: [Feed]) -> DependencyValues {
        var dependencies = DependencyValues()
        dependencies.persistenceClient.loadFeeds = { feeds }
        dependencies.persistenceClient.deleteFeed = { _ in }
        dependencies.persistenceClient.updateFeed = { _ in }
        dependencies.persistenceClient.addFeed = { _ in }
        
        dependencies.rssClient.fetchFeed = { url in
            if let feed = feeds.first(where: { $0.url == url }) {
                return feed
            }
            return Feed(url: url)
        }
        
        dependencies.rssClient.fetchFeedItems = { _ in [] }
        
        return dependencies
    }
    
    static func mockErrorDependencies(
        _ error: Error = PersistenceError.loadFailed("Failed to load feeds")
    ) -> DependencyValues {
        var dependencies = DependencyValues()
        dependencies.persistenceClient.loadFeeds = { throw error }
        dependencies.rssClient.fetchFeed = { _ in throw error }
        dependencies.rssClient.fetchFeedItems = { _ in throw error }
        return dependencies
    }
}
