//
//  AddFeedViewSnapshotTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 29.04.25.
//

import Testing
import SnapshotTestUtility
import SwiftUI
import Common

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
            view: view,
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
            view: view,
            named: "AddFeedWithURL"
        )
        
        assertSnapshot(
            view: view,
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
            view: view,
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
            view: view,
            named: "AddFeedLoading"
        )
    }
}
