//
//  FeedItemsViewSnapshotTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 21.04.25.
//

import Testing
import SnapshotTesting
import SwiftUI
import Dependencies
import SharedModels
import Common
import ConcurrencyExtras

@testable import FeedItemsFeature

@MainActor
@Suite struct FeedItemsViewSnapshotTests {
    func createTestItem(
        id: UUID = UUID(),
        feedID: UUID = UUID(),
        title: String = "Test Item",
        link: URL = URL(string: "https://example.com/item")!,
        pubDate: Date? = Date(),
        description: String? = "This is a detailed description of the item that contains multiple lines of text to demonstrate how the layout handles longer content in the feed item row component.",
        imageURL: URL? = nil
    ) -> FeedItem {
        FeedItem(
            id: id,
            feedID: feedID,
            title: title,
            link: link,
            pubDate: pubDate,
            description: description,
            imageURL: imageURL
        )
    }
    
    func createViewModel(
        url: URL = URL(string: "https://example.com")!,
        title: String = "Test Feed"
    ) -> FeedItemsViewModel {
        let viewModel = FeedItemsViewModel(
            feedURL: url,
            feedTitle: title
        )
        return viewModel
    }
    
    @Test("FeedItemsView with loaded items")
    func testFeedItemsViewLoaded() async throws {
        let items = [
            createTestItem(
                title: "First News Item",
                description: "This is the first news item with a detailed description.",
                imageURL: URL(string: "https://example.com/image1.jpg")
            ),
            createTestItem(
                title: "Second News Item",
                description: "This is the second news item without an image."
            ),
            createTestItem(
                title: "Third News Item with a Very Long Title That Should Wrap",
                description: "This is the third news item with a long title.",
                imageURL: URL(string: "https://example.com/image3.jpg")
            )
        ]
        
        withDependencies {
            $0.rssClient.fetchFeedItems = { _ in items }
        } operation: {
            let view = FeedItemsView(viewModel: createViewModel(title: "BBC News"))
                .frame(width: 375, height: 600)
            
            assertSnapshot(of: view, as: .image)
        }
    }
    
    @Test("FeedItemsView in loading state")
    func testFeedItemsViewLoading() async throws {
        let view = FeedItemsView(viewModel: createViewModel(title: "Feed Loading..."))
            .frame(width: 375, height: 600)
        
        assertSnapshot(of: view, as: .image)
    }
    
    @Test("FeedItemsView with empty state")
    func testFeedItemsViewEmpty() async throws {
        withDependencies {
            $0.rssClient.fetchFeedItems = { _ in [] }
        } operation: {
            let view = FeedItemsView(viewModel: createViewModel(title: "Empty Feed"))
                .frame(width: 375, height: 600)
            
            assertSnapshot(of: view, as: .image)
        }
    }
    
    @Test("FeedItemsView with error state")
    func testFeedItemsViewError() async throws {
        withDependencies {
            $0.rssClient.fetchFeedItems = { _ in
                throw RSSViewError.networkError("Network connection failed")
            }
        } operation: {
            let view = FeedItemsView(viewModel: createViewModel(title: "Error Feed"))
                .frame(width: 375, height: 600)
            
            assertSnapshot(of: view, as: .image)
        }
    }
    
    @Test("FeedItemsView in dark mode")
    func testFeedItemsViewDarkMode() async throws {
        let items = [
            createTestItem(
                title: "Dark Mode Item",
                description: "Testing dark mode appearance",
                imageURL: URL(string: "https://example.com/image.jpg")
            ),
            createTestItem(
                title: "Another Dark Mode Item",
                description: "More dark mode testing"
            )
        ]
        
        withDependencies {
            $0.rssClient.fetchFeedItems = { _ in items }
        } operation: {
            let view = FeedItemsView(viewModel: createViewModel(title: "Dark Mode Feed"))
                .frame(width: 375, height: 600)
            
            assertSnapshot(of: view, as: .image)
        }
    }
}
