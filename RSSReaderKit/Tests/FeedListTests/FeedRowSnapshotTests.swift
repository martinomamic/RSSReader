//
//  FeedRowSnapshotTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 29.04.25.
//

import Testing
import SnapshotTestUtility
import SwiftUI
import Common
import SharedModels

@testable import FeedListFeature

@MainActor
@Suite struct FeedRowSnapshotTests {
    func createTestFeed(
        url: String = "https://example.com/feed",
        title: String = "Test Feed",
        description: String = "This is a test feed with some description text that should span at least a couple of lines to test the layout of the feed row.",
        isFavorite: Bool = false,
        notificationsEnabled: Bool = false,
        imageURL: URL? = nil
    ) -> Feed {
        Feed(
            url: URL(string: url)!,
            title: title,
            description: description,
            imageURL: imageURL,
            isFavorite: isFavorite,
            notificationsEnabled: notificationsEnabled
        )
    }
    
    @Test("FeedRow variations")
    func testFeedRowVariations() async throws {
        let defaultFeed = createTestFeed()
        let defaultRow = FeedRow(
            feed: defaultFeed,
            onFavoriteToggle: {},
            onNotificationsToggle: {},
            notificationIcon: Constants.Images.notificationDisabledIcon,
            favoriteIcon: Constants.Images.isNotFavoriteIcon
        ).background(Color(.systemBackground))

        let favoriteFeed = createTestFeed(isFavorite: true)
        let favoriteRow = FeedRow(
            feed: favoriteFeed,
            onFavoriteToggle: {},
            onNotificationsToggle: {},
            notificationIcon: Constants.Images.notificationDisabledIcon,
            favoriteIcon: Constants.Images.isFavoriteIcon
        ).background(Color(.systemBackground))
        
        let notificationsFeed = createTestFeed(notificationsEnabled: true)
        let notificationsRow = FeedRow(
            feed: notificationsFeed,
            onFavoriteToggle: {},
            onNotificationsToggle: {},
            notificationIcon: Constants.Images.notificationEnabledIcon,
            favoriteIcon: Constants.Images.isNotFavoriteIcon
        ).background(Color(.systemBackground))
        
        let imageFeed = createTestFeed(imageURL: URL(string: "https://example.com/image.jpg"))
        let imageRow = FeedRow(
            feed: imageFeed,
            onFavoriteToggle: {},
            onNotificationsToggle: {},
            notificationIcon: Constants.Images.notificationDisabledIcon,
            favoriteIcon: Constants.Images.isNotFavoriteIcon
        ).background(Color(.systemBackground))
        
        let longTitleFeed = createTestFeed(
            title: "This is a very long feed title that should definitely be truncated because it's way too long to fit on a single line"
        )
        let longTitleRow = FeedRow(
            feed: longTitleFeed,
            onFavoriteToggle: {},
            onNotificationsToggle: {},
            notificationIcon: Constants.Images.notificationDisabledIcon,
            favoriteIcon: Constants.Images.isNotFavoriteIcon
        ).background(Color(.systemBackground))
        
        assertSnapshot(
            view: defaultRow,
            layouts: [.smallPhone],
            named: "FeedRowDefault",
        )
        assertSnapshot(
            view: favoriteRow,
            layouts: [.smallPhone],
            named: "FeedRowFavorite"
        )
        assertSnapshot(
            view: notificationsRow,
            layouts: [.smallPhone],
            named: "FeedRowNotifications")
        assertSnapshot(
            view: imageRow,
            layouts: [.smallPhone],
            named: "FeedRowWithImage"
        )
        assertSnapshot(
            view: longTitleRow,
            layouts: [.smallPhone],
            named: "FeedRowLongTitle"
        )
        
        assertSnapshot(
            view: defaultRow,
            layouts: [.smallPhone],
            accessibility: .XXXL,
            named: "FeedRowAccessible"
        )
    }
}
