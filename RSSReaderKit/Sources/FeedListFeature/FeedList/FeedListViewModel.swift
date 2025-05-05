//
//  FeedListViewModel.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 13.04.25.
//

import Common
import Dependencies
import FeedItemsFeature
import FeedRepository
import Foundation
import NotificationRepository
import Observation
import SharedModels
import SharedUI

@MainActor @Observable
public class FeedListViewModel {
    @ObservationIgnored
    @Dependency(\.feedRepository) private var feedRepository
    @ObservationIgnored
    @Dependency(\.notificationRepository) private var notificationRepository
    
    private(set) var feeds: [Feed] = []
    var state: ViewState<[Feed]> = .loading
    
    private var feedStreamTask: Task<Void, Never>?
    private var deleteTask: Task<Void, Never>?
    private var favoritesTask: Task<Void, Never>?
    private var notificationsTask: Task<Void, Never>?
    
    var favoriteFeeds: [Feed] {
        feeds.filter { $0.isFavorite }
    }
    
    var showEditButton: Bool {
        !feeds.isEmpty && !feeds.allSatisfy(\.isFavorite)
    }
    
    public init() {
        setupFeeds()
    }
    
    func setupFeeds() {
        feedStreamTask?.cancel()
        
        feedStreamTask = Task { @MainActor in
            do {
                try await feedRepository.loadInitialFeeds()
                
                for await updatedFeeds in feedRepository.feedsStream {
                    feeds = updatedFeeds
                    state = feeds.isEmpty ? .empty : .content(feeds)
                }
            } catch {
                state = .error(ErrorUtils.toAppError(error))
            }
        }
    }
    
    func toggleNotifications(_ feed: Feed) {
        notificationsTask?.cancel()
        
        notificationsTask = Task { @MainActor in
            do {
                if await !notificationRepository.notificationsAuthorized() {
                    try await notificationRepository.requestPermissions()
                }
                
                try await feedRepository.toggleNotifications(feed.url)
                
                guard await notificationRepository.notificationsAuthorized(),
                      feed.notificationsEnabled else { return }
                    try await notificationRepository.checkForNewItems()
            } catch {
                state = .error(ErrorUtils.toAppError(error))
            }
        }
    }
    
    func toggleFavorite(_ feed: Feed) {
        favoritesTask?.cancel()
        
        favoritesTask = Task { @MainActor in
            do {
                try await feedRepository.toggleFavorite(feed.url)
            } catch {
                state = .error(ErrorUtils.toAppError(error))
            }
        }
    }
    
    func removeFeed(at indexSet: IndexSet, fromFavorites: Bool = false) {
        let feedsToModify = fromFavorites ? favoriteFeeds : feeds
        
        deleteTask?.cancel()
        deleteTask = Task { @MainActor in
            do {
                for index in indexSet {
                    let feed = feedsToModify[index]
                    
                    if fromFavorites {
                        try await feedRepository.toggleFavorite(feed.url)
                    } else {
                        try await feedRepository.delete(feed.url)
                    }
                }
                state = feedsToModify.isEmpty ? .empty : .content(feedsToModify)
            } catch {
                state = .error(ErrorUtils.toAppError(error))
            }
        }
    }
    
    func displayedFeeds(showOnlyFavorites: Bool) -> [Feed] {
        return showOnlyFavorites ? favoriteFeeds : feeds
    }
    
    func navigationTitle(showOnlyFavorites: Bool) -> String {
        showOnlyFavorites ?
        LocalizedStrings.FeedList.favoriteFeeds :
        LocalizedStrings.FeedList.rssFeeds
    }
    
    func listAccessibilityId(showOnlyFavorites: Bool) -> String {
        showOnlyFavorites ?
        AccessibilityIdentifier.FeedList.favoritesList :
        AccessibilityIdentifier.FeedList.feedsList
    }
    
    func emptyStateTitle(showOnlyFavorites: Bool) -> String {
        showOnlyFavorites ?
        LocalizedStrings.FeedList.noFavorites :
        LocalizedStrings.FeedList.noFeeds
    }
    
    func emptyStateDescription(showOnlyFavorites: Bool) -> String {
        showOnlyFavorites ?
        LocalizedStrings.FeedList.noFavoritesDescription :
        LocalizedStrings.FeedList.noFeedsDescription
    }
    
    func makeFeedItemsViewModel(for feed: Feed) -> FeedItemsViewModel {
        FeedItemsViewModel(
            feedURL: feed.url,
            feedTitle: feed.title ?? LocalizedStrings.FeedList.unnamedFeed
        )
    }
    
    func notificationIcon(for feed: Feed) -> String {
        let isEnabled = feeds.first(where: { $0.url == feed.url })?.notificationsEnabled ?? feed.notificationsEnabled
        let icon = isEnabled ? Constants.Images.notificationEnabledIcon : Constants.Images.notificationDisabledIcon
        return icon
    }
    
    func favoriteIcon(for feed: Feed) -> String {
        let isFavorite = feeds.first(where: { $0.url == feed.url })?.isFavorite ?? feed.isFavorite
        let icon = isFavorite ? Constants.Images.isFavoriteIcon : Constants.Images.isNotFavoriteIcon
        return icon
    }
}

#if DEBUG
extension FeedListViewModel {
    @MainActor
    func waitForLoadToFinish() async {
        await feedStreamTask?.value
    }
}
#endif
