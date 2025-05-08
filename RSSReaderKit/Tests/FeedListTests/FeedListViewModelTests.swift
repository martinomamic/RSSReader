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

@testable import FeedListFeature

@MainActor
@Suite struct FeedListViewModelTests {
    func createTestFeed(
        url: String = "https://example.com/feed",
        title: String = "Test Feed",
        description: String = "Test description",
        isFavorite: Bool = false,
        notificationsEnabled: Bool = false
    ) -> Feed {
        Feed(
            url: URL(string: url)!,
            title: title,
            description: description,
            isFavorite: isFavorite,
            notificationsEnabled: notificationsEnabled
        )
    }
    
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
        let feed = createTestFeed(url: "https://example.com", title: "Test Feed")
        
        let feedItemsViewModel = viewModel.makeFeedItemsViewModel(for: feed)
        
        #expect(feedItemsViewModel.feedURL == URL(string: "https://example.com"))
        #expect(feedItemsViewModel.feedTitle == "Test Feed")
    }
}
