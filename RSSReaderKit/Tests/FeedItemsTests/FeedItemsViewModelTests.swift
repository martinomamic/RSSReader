//
//  FeedItemsViewModelTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 21.04.25.
//

import Common
import Dependencies
import Foundation
import RSSClient
import SharedModels
import Testing
import TestUtility

@testable import FeedItemsFeature

@MainActor
@Suite struct FeedItemsViewModelTests {
    func createViewModel(
        url: String = "https://example.com",
        title: String = "Test Feed"
    ) -> FeedItemsViewModel {
        return FeedItemsViewModel(
            feedURL: URL(string: url)!,
            feedTitle: title
        )
    }
    
    @Test("Load items successfully")
    func testLoadItemsSuccess() async throws {
        let items = [
            SharedMocks.createFeedItem(title: "Item 1"),
            SharedMocks.createFeedItem(title: "Item 2")
        ]
        
        let viewModel = createViewModel()
        
        await withDependencies {
            $0.rssClient.fetchFeedItems = { _ in items }
        } operation: {
            viewModel.loadItems()
            
            await viewModel.waitForLoadToFinish()
            
            if case .content(let loadedItems) = viewModel.state {
                #expect(loadedItems.count == 2)
                #expect(loadedItems[0].title == "Item 1")
                #expect(loadedItems[1].title == "Item 2")
            } else {
                #expect(Bool(false), "ViewModel state was not .content: \(viewModel.state)")
            }
        }
    }
    
    @Test("Empty items state")
    func testEmptyItems() async throws {
        let viewModel = createViewModel()
        
        await withDependencies {
            $0.rssClient.fetchFeedItems = { _ in [] }
        } operation: {
            viewModel.loadItems()
            
            await viewModel.waitForLoadToFinish()
            
            #expect(viewModel.state == .empty)
        }
    }
    
    @Test("Handle loading error")
    func testLoadItemsError() async throws {
        let viewModel = createViewModel()
        
        await withDependencies {
            $0.rssClient.fetchFeedItems = { _ in
                throw RSSError.networkError(NSError(domain: "test", code: -1, userInfo: nil))
            }
        } operation: {
            viewModel.loadItems()
            
            await viewModel.waitForLoadToFinish()
            
            if case .error(let error) = viewModel.state {
                #expect(error.errorDescription == AppError.networkError.errorDescription)
            } else {
                #expect(Bool(false), "ViewModel state was not .error: \(viewModel.state)")
            }
        }
    }
    
    @Test("Verify feed title is set correctly")
    func testFeedTitle() async throws {
        let viewModel = createViewModel(title: "Custom Feed Title")
        
        #expect(viewModel.feedTitle == "Custom Feed Title")
    }
    
    @Test("Loading state is correct initially")
    func testInitialState() async throws {
        let viewModel = createViewModel()
        
        #expect(viewModel.state == .loading)
    }
}
