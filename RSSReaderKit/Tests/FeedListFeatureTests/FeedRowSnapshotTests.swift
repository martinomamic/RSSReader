//
//  FeedRowSnapshotTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 29.04.25.
//

import Common
import SharedModels
import SwiftUI
import Testing
import TestUtility

@testable import FeedListFeature

@MainActor
@Suite struct FeedRowSnapshotTests {
    @Test("FeedRow variations")
    func testFeedRowVariations() async throws {
        let defaultFeed = SharedMocks.createFeed()
        let defaultRow = FeedRow(
            feed: defaultFeed,
            onFavoriteToggle: {},
            onNotificationsToggle: {},
            notificationIcon: Constants.Images.notificationDisabledIcon,
            favoriteIcon: Constants.Images.isNotFavoriteIcon
        ).background(Color(.systemBackground))

        let favoriteFeed = SharedMocks.createFeed(isFavorite: true)
        let favoriteRow = FeedRow(
            feed: favoriteFeed,
            onFavoriteToggle: {},
            onNotificationsToggle: {},
            notificationIcon: Constants.Images.notificationDisabledIcon,
            favoriteIcon: Constants.Images.isFavoriteIcon
        ).background(Color(.systemBackground))

        let notificationsFeed = SharedMocks.createFeed(notificationsEnabled: true)
        let notificationsRow = FeedRow(
            feed: notificationsFeed,
            onFavoriteToggle: {},
            onNotificationsToggle: {},
            notificationIcon: Constants.Images.notificationEnabledIcon,
            favoriteIcon: Constants.Images.isNotFavoriteIcon
        ).background(Color(.systemBackground))

        let imageFeed = SharedMocks.createFeed(imageURL: URL(string: "https://example.com/image.jpg"))
        let imageRow = FeedRow(
            feed: imageFeed,
            onFavoriteToggle: {},
            onNotificationsToggle: {},
            notificationIcon: Constants.Images.notificationDisabledIcon,
            favoriteIcon: Constants.Images.isNotFavoriteIcon
        ).background(Color(.systemBackground))

        let longTitleFeed = SharedMocks.createFeed(
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
