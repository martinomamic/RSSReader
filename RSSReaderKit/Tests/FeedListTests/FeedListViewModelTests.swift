//
//  FeedListViewModelTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 29.04.25.
//

import Testing
import Dependencies
import SwiftUI
import Common
import SharedModels
import FeedRepository

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
        let viewModel = FeedListViewModel()
        
        #expect(viewModel.state == .loading)
    }
    
    @Test("Navigation title is correct")
    func testNavigationTitle() {
        let viewModel = FeedListViewModel()
        
        #expect(viewModel.navigationTitle(showOnlyFavorites: false) == LocalizedStrings.FeedList.rssFeeds)
        #expect(viewModel.navigationTitle(showOnlyFavorites: true) == LocalizedStrings.FeedList.favoriteFeeds)
    }
    
    @Test("FeedItemsViewModel is created correctly")
    func testMakeFeedItemsViewModel() {
        let viewModel = FeedListViewModel()
        let feed = createTestFeed(url: "https://example.com", title: "Test Feed")
        
        let feedItemsViewModel = viewModel.makeFeedItemsViewModel(for: feed)
        
        #expect(feedItemsViewModel.feedURL == URL(string: "https://example.com"))
        #expect(feedItemsViewModel.feedTitle == "Test Feed")
    }
}
