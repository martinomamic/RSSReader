//
//  FeedListViewSnapshotTests 2.swift
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
@Suite struct FeedViewSnapshotTests {
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
    
    @Test("FeedView")
    func testFeedViewRendering() throws {
        let feed = testFeed(title: "Test Feed", description: "This is a test feed description", isFavorite: true, notificationsEnabled: true)
        let feedViewModel = makeFeedViewModel(feed: feed, state: .loaded(feed))
        
        let view = FeedView(viewModel: feedViewModel)
            .frame(width: 375)
        
        assertSnapshot(of: view, as: .image)
    }
    
    @Test("FeedView error state")
    func testFeedViewError() throws {
        let feed = testFeed()
        let feedViewModel = makeFeedViewModel(
            feed: feed,
            state: .error(RSSViewError.networkError("Network connection failed"))
        )
        
        let view = FeedView(viewModel: feedViewModel)
            .frame(width: 375)
            
        
        assertSnapshot(of: view, as: .image)
    }
    
    @Test("FeedView loading state")
    func testFeedViewLoading() throws {
        let feed = testFeed()
        let feedViewModel = makeFeedViewModel(feed: feed, state: .loading)
        
        let view = FeedView(viewModel: feedViewModel)
            .frame(width: 375)
            
        
        assertSnapshot(of: view, as: .image)
    }
}
