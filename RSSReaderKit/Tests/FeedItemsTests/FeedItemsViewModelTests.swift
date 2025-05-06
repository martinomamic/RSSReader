//
//  FeedItemsViewModelTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 21.04.25.
//

import Testing
import Foundation
import Dependencies
import SharedModels
import RSSClient
import Common

@testable import FeedItemsFeature

@MainActor
@Suite struct FeedItemsViewModelTests {
    func createTestItem(
        id: UUID = UUID(),
        feedID: UUID = UUID(),
        title: String = "Test Item",
        url: String = "https://example.com/item",
        pubDate: Date? = Date(),
        description: String? = "Test description",
        imageURL: String? = nil
    ) -> FeedItem {
        FeedItem(
            id: id,
            feedID: feedID,
            title: title,
            link: URL(string: url)!,
            pubDate: pubDate,
            description: description,
            imageURL: imageURL != nil ? URL(string: imageURL!) : nil
        )
    }
    
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
            createTestItem(title: "Item 1"),
            createTestItem(title: "Item 2")
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
