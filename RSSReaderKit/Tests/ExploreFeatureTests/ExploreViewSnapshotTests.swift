//
//  ExploreViewSnapshotTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 21.04.25.
//

import Common
import Dependencies
import SharedModels
import SwiftUI
import Testing
import TestUtility

@testable import ExploreFeature

@MainActor
@Suite struct ExploreViewSnapshotTests {
    @Test("ExploreView with feeds")
    func testExploreViewWithFeeds() async throws {
        let feeds = [
            SharedMocks.createExploreFeed(name: "BBC News", url: "https://feeds.bbci.co.uk/news/world/rss.xml"),
            SharedMocks.createExploreFeed(name: "NBC News", url: "https://feeds.nbcnews.com/nbcnews/public/news"),
            SharedMocks.createExploreFeed(name: "Reuters World News", url: "https://feeds.reuters.com/reuters/worldnews")
        ]
        
        let view = ExploreView()
        view.viewModel.feeds = feeds
        view.viewModel.addedFeedURLs = []
        view.viewModel.selectedFilter = .notAdded
        view.viewModel.filterFeeds()
        
        assertSnapshot(
            view: view,
            named: "ExploreWithFeeds_NotAdded",
            embedding: .navigationStack()
        )
        
        assertSnapshot(
            view: view,
            accessibility: .XXXL,
            named: "ExploreWithFeeds_NotAdded_XXXL",
            embedding: .navigationStack()
        )

        view.viewModel.addedFeedURLs = Set(feeds.map { $0.url })
        view.viewModel.selectedFilter = .added
        view.viewModel.filterFeeds()

        assertSnapshot(
            view: view,
            named: "ExploreWithFeeds_Added",
            embedding: .navigationStack()
        )

        assertSnapshot(
            view: view,
            accessibility: .XXXL,
            named: "ExploreWithFeeds_Added_XXXL",
            embedding: .navigationStack()
        )
    }
    
    @Test("ExploreView with empty state - Not Added filter")
    func testExploreViewEmptyNotAdded() async throws {
        let view = ExploreView()
        view.viewModel.feeds = []
        view.viewModel.addedFeedURLs = []
        view.viewModel.selectedFilter = .notAdded
        view.viewModel.filterFeeds()
        
        assertSnapshot(
            view: view,
            named: "ExploreEmpty_NotAdded",
            embedding: .navigationStack()
        )
    }

    @Test("ExploreView with empty state - Added filter")
    func testExploreViewEmptyAdded() async throws {
        let view = ExploreView()
        view.viewModel.feeds = [SharedMocks.createExploreFeed(name: "Some Feed")]
        view.viewModel.addedFeedURLs = []
        view.viewModel.selectedFilter = .added
        view.viewModel.filterFeeds()
        
        assertSnapshot(
            view: view,
            named: "ExploreEmpty_Added",
            embedding: .navigationStack()
        )
    }
    
    @Test("ExploreView with error state")
    func testExploreViewError() async throws {
        let view = ExploreView()
        view.viewModel.state = .error(AppError.general)
        
        assertSnapshot(
            view: view,
            named: "ExploreError",
            embedding: .navigationStack()
        )
    }
    
    @Test("ExploreView in loading state")
    func testExploreViewLoading() async throws {
        let view = ExploreView()
        view.viewModel.state = .loading
        
        assertSnapshot(
            view: view,
            named: "ExploreLoading",
            embedding: .navigationStack()
        )
    }
}
