//
//  FeedListViewSnapshotTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamic on 13.04.25.
//

import Testing
import SnapshotTestUtility
import SwiftUI
import Dependencies
import SharedModels
import Common

@testable import FeedListFeature

@MainActor
@Suite struct FeedListViewSnapshotTests {
    func createTestFeed(
        url: String = "https://example.com/feed",
        title: String = "Test Feed",
        description: String = "This is a test feed with some description text that should span at least a couple of lines to test the layout of the feed row.",
        isFavorite: Bool = false,
        notificationsEnabled: Bool = false,
        imageURL: URL? = nil
    ) -> Feed {
        Feed(
            url: URL(string: url)!,
            title: title,
            description: description,
            imageURL: imageURL,
            isFavorite: isFavorite,
            notificationsEnabled: notificationsEnabled
        )
    }
    
    @Test("FeedListView empty state")
    func testFeedListViewEmpty() async throws {
        let viewModel = AllFeedsViewModel()
        viewModel.state = .empty
        
        let view = NavigationStack {
            FeedListView(viewModel: viewModel)
                .navigationTitle(viewModel.navigationTitle)
        }
        
        assertSnapshot(
            view: view,
            named: "FeedListEmpty"
        )
    }
    
    @Test("FeedListView loading state")
    func testFeedListViewLoading() async throws {
        let viewModel = AllFeedsViewModel()
        viewModel.state = .loading
        
        let view = NavigationStack {
            FeedListView(viewModel: viewModel)
                .navigationTitle(viewModel.navigationTitle)
        }
        
        assertSnapshot(
            view: view,
            named: "FeedListLoading"
        )
    }
    
    @Test("FeedListView error state")
    func testFeedListViewError() async throws {
        let viewModel = AllFeedsViewModel()
        viewModel.state = .error(AppError.networkError)
        
        let view = NavigationStack {
            FeedListView(viewModel: viewModel)
                .navigationTitle(viewModel.navigationTitle)
        }
        
        assertSnapshot(
            view: view,
            named: "FeedListError"
        )
    }
}
