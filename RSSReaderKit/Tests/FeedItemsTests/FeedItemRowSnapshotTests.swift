//
//  FeedItemRowSnapshotTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 21.04.25.
//

import Testing
import SnapshotTestUtility
import SwiftUI
import SharedModels
import Common

@testable import FeedItemsFeature

private let pubDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy"
    return formatter
}()

@MainActor
@Suite struct FeedItemRowSnapshotTests {
    func createTestItem(
        id: UUID = UUID(),
        feedID: UUID = UUID(),
        title: String = "Test Item",
        link: URL = URL(string: "https://example.com/item")!,
        pubDate: Date? = pubDateFormatter.date(from: "09.05.2025"),
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
    
    @Test("FeedItemRow variations")
    func testFeedItemRowVariations() async throws {
        let itemWithImage = createTestItem(
            title: "Breaking News: Important Event",
            imageURL: URL(string: "https://example.com/image.jpg")
        )
        let rowWithImage = FeedItemRow(item: itemWithImage)
            .background(Color(.systemBackground))
        
        let itemWithoutImage = createTestItem(
            title: "Text Only News Item",
            description: "This is a news item without an image to show how the layout adapts to text-only content."
        )
        let rowWithoutImage = FeedItemRow(item: itemWithoutImage)
            .background(Color(.systemBackground))
        
        let itemWithLongTitle = createTestItem(
            title: "This is an extremely long title that should be truncated or wrapped depending on the layout settings of the FeedItemRow component",
            description: "Short description."
        )
        let rowWithLongTitle = FeedItemRow(item: itemWithLongTitle)
            .background(Color(.systemBackground))
        
        let minimalItem = createTestItem(
            title: "Minimal Item",
            pubDate: nil,
            description: nil
        )
        let minimalRow = FeedItemRow(item: minimalItem)
            .background(Color(.systemBackground))
        
        assertSnapshot(
            view: rowWithImage,
            layouts: [.fixed(size: CGSize(width: 375, height: 300))],
            named: "FeedItemRowWithImage"
        )
        assertSnapshot(
            view: rowWithoutImage,
            layouts: [.fixed(size: CGSize(width: 375, height: 150))],
            named: "FeedItemRowWithoutImage"
        )
        assertSnapshot(
            view: rowWithLongTitle,
            layouts: [.fixed(size: CGSize(width: 375, height: 150))],
            named: "FeedItemRowLongTitle"
        )
        assertSnapshot(
            view: minimalRow,
            layouts: [.fixed(size: CGSize(width: 375, height: 80))],
            named: "FeedItemRowMinimal"
        )
        
        assertSnapshot(
            view: rowWithoutImage,
            layouts: [.fixed(size: CGSize(width: 375, height: 200))],
            accessibility: .XXXL,
            named: "FeedItemRowAccessible"
        )
    }
}
