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
