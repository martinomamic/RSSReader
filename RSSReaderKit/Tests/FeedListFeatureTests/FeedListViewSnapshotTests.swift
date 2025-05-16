//
//  FeedListViewSnapshotTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamic on 13.04.25.
//

import Common
import Dependencies
import SharedModels
import SwiftUI
import Testing
import TestUtility

@testable import FeedListFeature

@MainActor
@Suite struct FeedListViewSnapshotTests {
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
