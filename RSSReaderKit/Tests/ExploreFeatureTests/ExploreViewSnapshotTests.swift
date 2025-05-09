//
//  ExploreViewSnapshotTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 21.04.25.
//

import Testing
import SnapshotTestUtility
import SwiftUI
import Dependencies
import SharedModels
import Common

@testable import ExploreFeature

@MainActor
@Suite struct ExploreViewSnapshotTests {
    private func createExploreFeed(
        name: String = "Test Feed",
        url: String = "https://example.com/feed"
    ) -> ExploreFeed {
        ExploreFeed(name: name, url: url)
    }
    
    @Test("ExploreView with feeds")
    func testExploreViewWithFeeds() async throws {
        let feeds = [
            createExploreFeed(name: "BBC News", url: "https://feeds.bbci.co.uk/news/world/rss.xml"),
            createExploreFeed(name: "NBC News", url: "https://feeds.nbcnews.com/nbcnews/public/news"),
            createExploreFeed(name: "Reuters World News", url: "https://feeds.reuters.com/reuters/worldnews")
        ]
        
        let view = ExploreView()
        view.viewModel.state = .content(feeds)
        
        assertSnapshot(
            view: view,
            named: "ExploreWithFeeds"
        )
        
        assertSnapshot(
            view: view,
            accessibility: .XXXL,
            named: "ExploreWithFeeds"
        )
    }
    
    @Test("ExploreView with empty state")
    func testExploreViewEmpty() async throws {
        let view = ExploreView()
        view.viewModel.state = .empty
        
        assertSnapshot(
            view: view,
            named: "ExploreEmpty"
        )
    }
    
    @Test("ExploreView with error state")
    func testExploreViewError() async throws {
        let view = ExploreView()
        view.viewModel.state = .error(AppError.general)
        
        assertSnapshot(
            view: view,
            named: "ExploreError"
        )
    }
    
    @Test("ExploreView in loading state")
    func testExploreViewLoading() async throws {
        let view = ExploreView()
        view.viewModel.state = .loading
        
        assertSnapshot(
            view: view,
            named: "ExploreLoading"
        )
    }
}
