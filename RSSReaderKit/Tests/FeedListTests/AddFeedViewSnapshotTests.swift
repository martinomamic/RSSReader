//
//  AddFeedViewSnapshotTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 29.04.25.
//

import Common
import SharedModels
import SwiftUI
import Testing
import TestUtility

@testable import FeedListFeature

@MainActor
@Suite struct AddFeedViewSnapshotTests {
    @Test("AddFeedView initial state")
    func testAddFeedViewInitial() async throws {
        let model = AddFeedViewModel()
        model.state = .idle
        model.urlString = ""

        let view = AddFeedView(viewModel: model)
        
        assertSnapshot(
            view: NavigationStack { view },
            named: "AddFeedEmpty"
        )
    }
    
    @Test("AddFeedView with entered URL")
    func testAddFeedViewWithURL() async throws {
        let model = AddFeedViewModel()
        model.state = .idle
        model.urlString = "https://feeds.bbci.co.uk/news/world/rss.xml"

        let view = AddFeedView(viewModel: model)
        
        assertSnapshot(
            view: NavigationStack { view },
            named: "AddFeedWithURL"
        )
        
        assertSnapshot(
            view: NavigationStack { view },
            accessibility: .XXXL,
            named: "AddFeedWithURL"
        )
    }
    
    @Test("AddFeedView with invalid URL error")
    func testAddFeedViewWithError() async throws {
        let model = AddFeedViewModel()
        model.state = .error(.invalidURL)
        model.urlString = "invalid"

        let view = AddFeedView(viewModel: model)
        
        assertSnapshot(
            view: NavigationStack { view },
            named: "AddFeedError"
        )
    }
    
    @Test("AddFeedView in loading state")
    func testAddFeedViewLoading() async throws {
        let model = AddFeedViewModel()
        model.state = .loading
        model.urlString = "https://feeds.bbci.co.uk/news/world/rss.xml"

        let view = AddFeedView(viewModel: model)
        
        assertSnapshot(
            view: NavigationStack { view },
            named: "AddFeedLoading"
        )
    }
    
    @Test("AddFeedView with suggested feeds")
    func testAddFeedViewWithSuggestedFeeds() async throws {
        let model = AddFeedViewModel()
        model.state = .idle
        model.urlString = "https://feeds.bbci.co.uk/news/world/rss.xml"
        model.exploreFeeds = [
            ExploreFeed(name: "Feed1", url: "https://feeds.bbci.co.uk/news/world/rss.xml"),
            ExploreFeed(name: "Fee2", url: "https://feeds.bbci.co.uk/news/uk/rss.xml")
        ]

        let view = AddFeedView(viewModel: model)
        
        assertSnapshot(
            view: NavigationStack { view },
            named: "AddFeedLoading"
        )
    }
}
