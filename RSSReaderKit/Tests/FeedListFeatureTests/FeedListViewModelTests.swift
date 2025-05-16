//
//  FeedListViewModelTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 29.04.25.
//

import Common
import Dependencies
import FeedRepository
import SharedModels
import SwiftUI
import Testing
import TestUtility

@testable import FeedListFeature

@MainActor
@Suite struct FeedListViewModelTests {
    @Test("ViewModel is initialized with loading state")
    func testInitialState() async throws {
        let viewModel = AllFeedsViewModel()
        
        #expect(viewModel.state == .loading)
    }
    
    @Test("Navigation title is correct")
    func testNavigationTitle() {
        let viewModel = AllFeedsViewModel()
        
        #expect(viewModel.navigationTitle == LocalizedStrings.FeedList.rssFeeds)
    }
    
    @Test("FeedItemsViewModel is created correctly")
    func testMakeFeedItemsViewModel() {
        let viewModel = AllFeedsViewModel()
        let feed = SharedMocks.createFeed(urlString: "https://example.com", title: "Test Feed")
        let feedItemsViewModel = viewModel.makeFeedItemsViewModel(for: feed)
        
        #expect(feedItemsViewModel.feedURL == URL(string: "https://example.com"))
        #expect(feedItemsViewModel.feedTitle == "Test Feed")
    }
}
