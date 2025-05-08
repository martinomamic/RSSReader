//
//  AddFeedViewSnapshotTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 29.04.25.
//

import Testing
import SnapshotTesting
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

        let addFeedView = AddFeedView(viewModel: model)
            .frame(width: 375, height: 600)
        
        assertSnapshot(of: addFeedView, as: .image)
    }
    
    @Test("AddFeedView with entered URL")
    func testAddFeedViewWithURL() async throws {
        let model = AddFeedViewModel()
        model.state = .idle
        model.urlString = "https://feeds.bbci.co.uk/news/world/rss.xml"

        let addFeedView = AddFeedView(viewModel: model)
        .frame(width: 375, height: 600)
        
        assertSnapshot(of: addFeedView, as: .image)
    }
    
    @Test("AddFeedView with invalid URL error")
    func testAddFeedViewWithError() async throws {
        let model = AddFeedViewModel()
        model.state = .error(.invalidURL)
        model.urlString = ""

        let addFeedView = AddFeedView(viewModel: model)
        .frame(width: 375, height: 600)
        
        assertSnapshot(of: addFeedView, as: .image)
    }
    
    @Test("AddFeedView in loading state")
    func testAddFeedViewLoading() async throws {
        let model = AddFeedViewModel()
        model.state = .loading
        model.urlString = "https://feeds.bbci.co.uk/news/world/rss.xml"

        let addFeedView = AddFeedView(viewModel: model)
            .frame(width: 375, height: 600)
        
        assertSnapshot(of: addFeedView, as: .image)
    }
    
    @Test("AddFeedView in dark mode")
    func testAddFeedViewDarkMode() async throws {
        let model = AddFeedViewModel()
        model.state = .idle
        model.urlString = "https://feeds.bbci.co.uk/news/world/rss.xml"

        let addFeedView = AddFeedView(viewModel: model)
            .frame(width: 375, height: 600)
            .environment(\.colorScheme, .dark)
        
        assertSnapshot(of: addFeedView, as: .image)
    }
}
