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
        
        let view = FeedListView(viewModel: viewModel)
            .navigationTitle(viewModel.navigationTitle)
        
        assertSnapshot(
            view: view,
            named: "FeedListEmpty",
            embedding: .navigationStack()
        )
    }
    
    @Test("FeedListView loading state")
    func testFeedListViewLoading() async throws {
        let viewModel = AllFeedsViewModel()
        viewModel.state = .loading
        
        let view = FeedListView(viewModel: viewModel)
            .navigationTitle(viewModel.navigationTitle)
        
        assertSnapshot(
            view: view,
            named: "FeedListLoading",
            embedding: .navigationStack()
        )
    }
    
    @Test("FeedListView error state")
    func testFeedListViewError() async throws {
        let viewModel = AllFeedsViewModel()
        viewModel.state = .error(AppError.networkError)
        
        let view = FeedListView(viewModel: viewModel)
            .navigationTitle(viewModel.navigationTitle)
        
        assertSnapshot(
            view: view,
            named: "FeedListError",
            embedding: .navigationStack()
        )
    }
}
