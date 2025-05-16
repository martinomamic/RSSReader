//
//  FeedItemRowSnapshotTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 21.04.25.
//

import Common
import SharedModels
import SwiftUI
import Testing
import TestUtility

@testable import FeedItemsFeature

@MainActor
@Suite struct FeedItemRowSnapshotTests {
    @Test("FeedItemRow variations")
    func testFeedItemRowVariations() async throws {
        let itemWithImage = SharedMocks.createFeedItem(
            title: "Breaking News: Important Event",
            imageURLString: "https://example.com/image.jpg"
        )
        let rowWithImage = FeedItemRow(item: itemWithImage)
            .background(Color(.systemBackground))
        
        let itemWithoutImage = SharedMocks.createFeedItem(
            title: "Text Only News Item",
            description: "This is a news item without an image to show how the layout adapts to text-only content."
        )
        let rowWithoutImage = FeedItemRow(item: itemWithoutImage)
            .background(Color(.systemBackground))
        
        let itemWithLongTitle = SharedMocks.createFeedItem(
            title: "This is an extremely long title that should be truncated or wrapped depending on the layout settings of the FeedItemRow component",
            description: "Short description."
        )
        let rowWithLongTitle = FeedItemRow(item: itemWithLongTitle)
            .background(Color(.systemBackground))
        
        let minimalItem = SharedMocks.createFeedItem(
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
