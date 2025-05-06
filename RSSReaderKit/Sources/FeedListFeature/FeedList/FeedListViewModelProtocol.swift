//
//  FeedListViewModelProtocol.swift
//  RSSReaderKit
//
//  Created by Martino Mamic on 06.05.25.
//

import Common
import FeedItemsFeature
import Foundation
import Observation
import SharedModels

@MainActor
public protocol FeedListViewModelProtocol: Observable {
    var feeds: [Feed] { get }
    var state: ViewState<[Feed]> { get set }
    
    var showEditButton: Bool { get }
    var navigationTitle: String { get }
    var listAccessibilityId: String { get }
    var emptyStateTitle: String { get }
    var emptyStateDescription: String { get }
    var primaryActionLabel: String? { get }
    
    func setupFeeds()
    func toggleNotifications(_ feed: Feed)
    func toggleFavorite(_ feed: Feed)
    func removeFeed(at indexSet: IndexSet)
    func makeFeedItemsViewModel(for feed: Feed) -> FeedItemsViewModel
    func notificationIcon(for feed: Feed) -> String
    func favoriteIcon(for feed: Feed) -> String
}

extension FeedListViewModelProtocol {
    public var showEditButton: Bool { !feeds.isEmpty }
    public var navigationTitle: String { LocalizedStrings.FeedList.rssFeeds }
    public var listAccessibilityId: String { AccessibilityIdentifier.FeedList.feedsList }
    public var emptyStateTitle: String { LocalizedStrings.FeedList.noFeeds }
    public var emptyStateDescription: String { LocalizedStrings.FeedList.noFeedsDescription }
    public var primaryActionLabel: String? { LocalizedStrings.FeedList.addFeed }
    
    public func makeFeedItemsViewModel(for feed: Feed) -> FeedItemsViewModel {
        FeedItemsViewModel(
            feedURL: feed.url,
            feedTitle: feed.title ?? LocalizedStrings.FeedList.unnamedFeed
        )
    }

    public func notificationIcon(for feed: Feed) -> String {
        let isEnabled = self.feeds.first(where: { $0.url == feed.url })?.notificationsEnabled ?? feed.notificationsEnabled
        return isEnabled ? Constants.Images.notificationEnabledIcon : Constants.Images.notificationDisabledIcon
    }

    public func favoriteIcon(for feed: Feed) -> String {
        let isFavorite = self.feeds.first(where: { $0.url == feed.url })?.isFavorite ?? feed.isFavorite
        return isFavorite ? Constants.Images.isFavoriteIcon : Constants.Images.isNotFavoriteIcon
    }
}
