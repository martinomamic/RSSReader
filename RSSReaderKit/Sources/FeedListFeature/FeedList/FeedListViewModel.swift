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
import NotificationClient
import Observation
import SharedModels

enum FeedListState: Equatable {
    case idle
    case loading
    case error(AppError)
}

@MainActor @Observable
public class FeedListViewModel {
    @ObservationIgnored
    @Dependency(\.feedRepository) private var feedRepository
    @ObservationIgnored
    @Dependency(\.notificationClient) private var notificationClient
    
    private(set) var feeds: [Feed] = []
    var state: FeedListState = .loading
    
    private var feedStreamTask: Task<Void, Never>?
    private var deleteTask: Task<Void, Never>?
    private var favoritesTask: Task<Void, Never>?
    private var notificationsTask: Task<Void, Never>?

    var favoriteFeeds: [Feed] {
        feeds.filter { $0.isFavorite }
    }

    var showEditButton: Bool {
        !feeds.isEmpty
    }

    public init() {
        setupFeeds()
    }

    private func setupFeeds() {
        feedStreamTask?.cancel()
        
        feedStreamTask = Task { @MainActor in
            do {
                try await feedRepository.loadInitialFeeds()
                
                for await updatedFeeds in feedRepository.feedsStream {
                    self.feeds = updatedFeeds
                    self.state = .idle
                }
            } catch {
                state = .error(ErrorUtils.toAppError(error))
            }
        }
    }

    private func updateFeedInPlace(_ url: URL, transform: (inout Feed) -> Void) {
        if let index = feeds.firstIndex(where: { $0.url == url }) {
            var updatedFeed = feeds[index]
            transform(&updatedFeed)
            feeds[index] = updatedFeed
        }
    }

    func toggleNotifications(_ feed: Feed) {
        notificationsTask?.cancel()

        notificationsTask = Task { @MainActor in
            do {
                if await !NotificationClient.notificationsAuthorized() {
                    try await notificationClient.requestPermissions()
                }

                try await feedRepository.toggleNotifications(feed.url)
                
                guard await NotificationClient.notificationsAuthorized() else {
                    return
                }

                if feed.notificationsEnabled {
                    BackgroundRefreshClient.shared.scheduleAppRefresh()
                    try await notificationClient.checkForNewItems()
                }
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

    func isEmptyState(showOnlyFavorites: Bool) -> Bool {
        state == .idle && displayedFeeds(showOnlyFavorites: showOnlyFavorites).isEmpty
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
