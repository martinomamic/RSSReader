//
//  FeedListViewSnapshotTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 21.04.25.
//

import Testing
import Foundation
import Dependencies
import SharedModels
import PersistenceClient
import RSSClient
import Common

@testable import FeedListFeature

@Suite struct FeedListViewModelTests {
    func testFeed(
        url: String = "https://example.com",
        title: String = "Test Feed",
        description: String = "Test Description",
        isFavorite: Bool = false,
        notificationsEnabled: Bool = false
    ) -> Feed {
        Feed(
            url: URL(string: url)!,
            title: title,
            description: description,
            imageURL: nil,
            isFavorite: isFavorite,
            notificationsEnabled: notificationsEnabled
        )
    }
    
    @MainActor
    func createViewModelWithFeeds(feeds: [Feed] = []) async -> FeedListViewModel {
        let viewModel = FeedListViewModel()
        viewModel.feeds = feeds.map { FeedViewModel(url: $0.url, feed: $0) }
        return viewModel
    }
    
    @Test("Load feeds successfully")
    func testDisplayFeeds() async throws {
        let mockFeed = testFeed()
        let viewModel = await createViewModelWithFeeds(feeds: [mockFeed])
        
        await withDependencies {
            $0.persistenceClient.loadFeeds = { [mockFeed] }
        } operation: {
            await viewModel.loadFeeds()
            
            #expect(await viewModel.feeds.count == 0)
            #expect(await viewModel.feeds[0].feed.title == "Test Feed")
            #expect(await viewModel.feeds[0].feed.url.absoluteString == "https://example.com")
            #expect(await viewModel.state == .idle)
        }
    }
    
    @Test("Filter favorite feeds correctly")
    func testFavoriteFeeds() async throws {
        let mockFeeds = [
            testFeed(url: "https://example1.com", title: "Feed 1", isFavorite: true),
            testFeed(url: "https://example2.com", title: "Feed 2", isFavorite: false)
        ]
        let viewModel = await createViewModelWithFeeds(feeds: mockFeeds)
        
        await withDependencies {
            $0.persistenceClient.loadFeeds = { mockFeeds }
        } operation: {
            #expect(await viewModel.favoriteFeeds.count == 1)
            #expect(await viewModel.favoriteFeeds[0].feed.title == "Feed 1")
            #expect(await viewModel.displayedFeeds(showOnlyFavorites: true).count == 1)
            #expect(await viewModel.displayedFeeds(showOnlyFavorites: false).count == 2)
        }
    }
    
    @Test("Handle load feeds error")
    func testLoadFeedsError() async throws {
        let viewModel = await FeedListViewModel()
        let error = PersistenceError.loadFailed("Failed to load feeds")
        
        await withDependencies {
            $0.persistenceClient.loadFeeds = { throw error }
        } operation: {
            await viewModel.loadFeeds()
            
            if case .error(let viewError) = await viewModel.state {
                #expect(viewError.errorDescription.contains("Failed to load feeds"))
            }
        }
    }
    
    @Test("Remove feed successfully")
    func testRemoveFeed() async throws {
        let mockFeed = testFeed()
        let viewModel = await createViewModelWithFeeds(feeds: [mockFeed])

        await withDependencies {
            $0.persistenceClient.loadFeeds = { [mockFeed] }
            $0.persistenceClient.deleteFeed = { _ in }
        } operation: {
            #expect(await viewModel.feeds.count == 1)
            await viewModel.removeFeed(at: IndexSet(integer: 0))
            #expect(await viewModel.feeds.isEmpty)
        }
    }


    
    @Test("Navigation title shows correctly for feeds")
    func testNavigationTitleForFeeds() async throws {
        let viewModel = await FeedListViewModel()
        
        await #expect(viewModel.navigationTitle(showOnlyFavorites: false) == LocalizedStrings.FeedList.rssFeeds)
        await #expect(viewModel.navigationTitle(showOnlyFavorites: true) == LocalizedStrings.FeedList.favoriteFeeds)
    }
    
    @Test("Empty state titles show correctly")
    func testEmptyStateTitles() async throws {
        let viewModel = await FeedListViewModel()
        
        await #expect(viewModel.emptyStateTitle(showOnlyFavorites: false) == LocalizedStrings.FeedList.noFeeds)
        await #expect(viewModel.emptyStateTitle(showOnlyFavorites: true) == LocalizedStrings.FeedList.noFavorites)
    }
    
    @Test("Creates FeedItemsViewModel correctly")
    func testMakeFeedItemsViewModel() async throws {
        let viewModel = await FeedListViewModel()
        let mockFeed = testFeed(title: "Test Feed")
        
        let feedViewModel = await FeedViewModel(url: URL(string: "https://example.com")!, feed: mockFeed)
        let itemsViewModel = await viewModel.makeFeedItemsViewModel(for: feedViewModel)
        
        await #expect(itemsViewModel.feedURL == URL(string: "https://example.com")!)
        await #expect(itemsViewModel.feedTitle == "Test Feed")
    }
}
