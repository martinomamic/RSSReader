//
//  FeedRowSnapshotTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 29.04.25.
//

import Testing
import SnapshotTesting
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
    
    @Test("FeedRow with default state")
    func testFeedRowDefault() async throws {
        let feed = createTestFeed()
        
        let feedRow = FeedRow(
            feed: feed,
            onFavoriteToggle: {},
            onNotificationsToggle: {},
            notificationIcon: Constants.Images.notificationDisabledIcon,
            favoriteIcon: Constants.Images.isNotFavoriteIcon
        )
        .frame(width: 375)
        
        assertSnapshot(of: feedRow, as: .image)
    }
    
    @Test("FeedRow with favorite enabled")
    func testFeedRowFavorite() async throws {
        let feed = createTestFeed(isFavorite: true)
        
        let feedRow = FeedRow(
            feed: feed,
            onFavoriteToggle: {},
            onNotificationsToggle: {},
            notificationIcon: Constants.Images.notificationDisabledIcon,
            favoriteIcon: Constants.Images.isFavoriteIcon
        )
        .frame(width: 375)
        
        assertSnapshot(of: feedRow, as: .image)
    }
    
    @Test("FeedRow with notifications enabled")
    func testFeedRowNotifications() async throws {
        let feed = createTestFeed(notificationsEnabled: true)
        
        let feedRow = FeedRow(
            feed: feed,
            onFavoriteToggle: {},
            onNotificationsToggle: {},
            notificationIcon: Constants.Images.notificationEnabledIcon,
            favoriteIcon: Constants.Images.isNotFavoriteIcon
        )
        .frame(width: 375)
        
        assertSnapshot(of: feedRow, as: .image)
    }
    
    @Test("FeedRow with both favorite and notifications enabled")
    func testFeedRowFavoriteAndNotifications() async throws {
        let feed = createTestFeed(isFavorite: true, notificationsEnabled: true)
        
        let feedRow = FeedRow(
            feed: feed,
            onFavoriteToggle: {},
            onNotificationsToggle: {},
            notificationIcon: Constants.Images.notificationEnabledIcon,
            favoriteIcon: Constants.Images.isFavoriteIcon
        )
        .frame(width: 375)
        
        assertSnapshot(of: feedRow, as: .image)
    }
    
    @Test("FeedRow with image")
    func testFeedRowWithImage() async throws {
        let feed = createTestFeed(
            imageURL: URL(string: "https://example.com/image.jpg")
        )
        
        let feedRow = FeedRow(
            feed: feed,
            onFavoriteToggle: {},
            onNotificationsToggle: {},
            notificationIcon: Constants.Images.notificationDisabledIcon,
            favoriteIcon: Constants.Images.isNotFavoriteIcon
        )
        .frame(width: 375)
        
        assertSnapshot(of: feedRow, as: .image)
    }
    
    @Test("FeedRow with long title")
    func testFeedRowLongTitle() async throws {
        let feed = createTestFeed(
            title: "This is a very long feed title that should definitely be truncated because it's way too long to fit on a single line"
        )
        
        let feedRow = FeedRow(
            feed: feed,
            onFavoriteToggle: {},
            onNotificationsToggle: {},
            notificationIcon: Constants.Images.notificationDisabledIcon,
            favoriteIcon: Constants.Images.isNotFavoriteIcon
        )
        .frame(width: 375)
        
        assertSnapshot(of: feedRow, as: .image)
    }
    
    @Test("FeedRow with long description")
    func testFeedRowLongDescription() async throws {
        let feed = createTestFeed(
            description: "This is a very long description for the feed that should definitely be truncated after a few lines. We're making it extra long to ensure that the line limit for descriptions is working properly. It might truncate with an ellipsis if the text is too long."
        )
        
        let feedRow = FeedRow(
            feed: feed,
            onFavoriteToggle: {},
            onNotificationsToggle: {},
            notificationIcon: Constants.Images.notificationDisabledIcon,
            favoriteIcon: Constants.Images.isNotFavoriteIcon
        )
        .frame(width: 375)
        
        assertSnapshot(of: feedRow, as: .image)
    }
    
    @Test("FeedRow in dark mode")
    func testFeedRowDarkMode() async throws {
        let feed = createTestFeed()
        
        let feedRow = FeedRow(
            feed: feed,
            onFavoriteToggle: {},
            onNotificationsToggle: {},
            notificationIcon: Constants.Images.notificationDisabledIcon,
            favoriteIcon: Constants.Images.isNotFavoriteIcon
        )
        .frame(width: 375)
        .environment(\.colorScheme, .dark)
        
        assertSnapshot(of: feedRow, as: .image)
    }
}
