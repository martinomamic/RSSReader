//
//  FeedItemRowSnapshotTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 21.04.25.
//

import Testing
import SnapshotTesting
import SwiftUI
import SharedModels
import Common

@testable import FeedItemsFeature

@MainActor
@Suite struct FeedItemRowSnapshotTests {
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
    
    @Test("FeedItemRow with image")
    func testFeedItemRowWithImage() async throws {
        let item = createTestItem(
            title: "Breaking News: Important Event",
            imageURL: URL(string: "https://example.com/image.jpg")
        )
        
        let view = FeedItemRow(item: item)
            .frame(width: 375)
            .padding()
        
        assertSnapshot(of: view, as: .image)
    }
    
    @Test("FeedItemRow without image")
    func testFeedItemRowWithoutImage() async throws {
        let item = createTestItem(
            title: "Text Only News Item",
            description: "This is a news item without an image to show how the layout adapts to text-only content."
        )
        
        let view = FeedItemRow(item: item)
            .frame(width: 375)
            .padding()
        
        assertSnapshot(of: view, as: .image)
    }
    
    @Test("FeedItemRow with long title")
    func testFeedItemRowWithLongTitle() async throws {
        let item = createTestItem(
            title: "This is an extremely long title that should be truncated or wrapped depending on the layout settings of the FeedItemRow component",
            description: "Short description."
        )
        
        let view = FeedItemRow(item: item)
            .frame(width: 375)
            .padding()
        
        assertSnapshot(of: view, as: .image)
    }
    
    @Test("FeedItemRow with minimal data")
    func testFeedItemRowWithMinimalData() async throws {
        let item = createTestItem(
            title: "Minimal Item",
            pubDate: nil,
            description: nil
        )
        
        let view = FeedItemRow(item: item)
            .frame(width: 375)
            .padding()
        
        assertSnapshot(of: view, as: .image)
    }
}
