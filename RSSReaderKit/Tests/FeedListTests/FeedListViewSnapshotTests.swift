//
//  FeedListViewSnapshotTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 21.04.25.
//

import Testing
import SnapshotTesting
import SwiftUI
import Dependencies
import SharedModels
import PersistenceClient
import Common

@testable import FeedListFeature

@MainActor
@Suite struct FeedListViewSnapshotTests {
    private func testFeed(
        url: String = "https://example.com",
        title: String = "Test Feed",
        description: String = "Test Description",
        isFavorite: Bool = false,
        notificationsEnabled: Bool = false
    ) -> Feed {
        Feed(
            url: URL(string: url)!,
            title: title,
            description: description,
            imageURL: URL(string: "https://example.com/image.jpg"),
            isFavorite: isFavorite,
            notificationsEnabled: notificationsEnabled
        )
    }
    
    private func makeFeedViewModel(
        feed: Feed,
        state: FeedViewState = .loaded(Feed(url: URL(string: "https://example.com")!))
    ) -> FeedViewModel {
        let viewModel = FeedViewModel(url: feed.url, feed: feed)
        viewModel.state = state
        return viewModel
    }
    
    @Test("FeedListView with feeds")
    func testFeedListViewWithFeeds() async throws {
        let mockFeeds = [
            testFeed(title: "First Feed", description: "First feed description"),
            testFeed(url: "https://example2.com", title: "Second Feed", description: "Second feed description"),
            testFeed(url: "https://example3.com", title: "Third Feed", description: "Third feed description", isFavorite: true)
        ]
        
        withDependencies {
            $0.persistenceClient.loadFeeds = { mockFeeds }
        } operation: {
            let view = FeedListView()
                .frame(width: 375, height: 600)
            
            assertSnapshot(of: view, as: .image)
        }
    }
    
    @Test("FeedListView with favorites")
    func testFeedListViewWithFavorites() async throws {
        let mockFeeds = [
            testFeed(title: "First Feed", description: "First feed description", isFavorite: true),
            testFeed(url: "https://example2.com", title: "Second Feed", description: "Second feed description"),
            testFeed(url: "https://example3.com", title: "Third Feed", description: "Third feed description", isFavorite: true)
        ]
        
        withDependencies {
            $0.persistenceClient.loadFeeds = { mockFeeds }
        } operation: {
            let view = FeedListView(showOnlyFavorites: true)
                .frame(width: 375, height: 600)
            
            assertSnapshot(of: view, as: .image)
        }
    }
    
    @Test("FeedListView with empty state")
    func testFeedListViewEmpty() async throws {
        withDependencies {
            $0.persistenceClient.loadFeeds = { [] }
        } operation: {
            let view = FeedListView()
                .frame(width: 375, height: 600)
            
            assertSnapshot(of: view, as: .image)
            assertSnapshot(of: view, as: .image)
        }
    }
    
    @Test("FeedListView with error state")
    func testFeedListViewError() async throws {
        withDependencies {
            $0.persistenceClient.loadFeeds = { throw PersistenceError.loadFailed("Failed to load feeds") }
        } operation: {
            let view = FeedListView()
                .frame(width: 375, height: 600)
            
            assertSnapshot(of: view, as: .image)
        }
    }
}
