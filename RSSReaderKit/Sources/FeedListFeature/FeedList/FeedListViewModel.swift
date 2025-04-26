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
import Observation
import SharedModels
import SwiftUI

enum FeedListState: Equatable {
    case idle
    case loading
    case error(AppError)
}

@MainActor @Observable
public class FeedListViewModel {
    @ObservationIgnored
    @Dependency(\.feedRepository) private var feedRepository
    
    private(set) var feeds: [FeedViewModel] = []
    
    var favoriteFeeds: [FeedViewModel] {
        feeds.filter { $0.feed.isFavorite }
    }
    var state: FeedListState = .idle
    
    private var feedStreamTask: Task<Void, Never>?

    var isEmptyState: Bool {
        displayedFeeds(showOnlyFavorites: false).isEmpty
    }
    
    var showEditButton: Bool {
        !feeds.isEmpty
    }

    public init() {
        Task {
            do {
                state = .loading
                // First ensure initial feeds are loaded
                try await feedRepository.loadInitialFeeds()
                state = .idle
                // Then setup stream for subsequent updates
                setupFeedStream()
            } catch {
                state = .error(ErrorUtils.toAppError(error))
            }
        }
    }
    
    private func setupFeedStream() {
        feedStreamTask?.cancel()
        feedStreamTask = Task {
            for await updatedFeeds in feedRepository.feedsStream {
                withAnimation {
                    self.feeds = updatedFeeds.map { feed in
                        let viewModel = FeedViewModel(url: feed.url, feed: feed)
                        viewModel.state = .loaded(feed)
                        return viewModel
                    }
                }
            }
        }
    }

    func removeFeed(at indexSet: IndexSet, fromFavorites: Bool = false) {
        if fromFavorites {
            let feedsToRemoveFromFavorites = indexSet.map { favoriteFeeds[$0] }
            for feed in feedsToRemoveFromFavorites {
                toggleFavorite(feed)
            }
        } else {
            let feedsToDelete = indexSet.map { feeds[$0] }
            for feed in feedsToDelete {
                Task {
                    do {
                        try await feedRepository.delete(feed.url)
                    } catch {
                        state = .error(ErrorUtils.toAppError(error))
                    }
                }
            }
        }
    }

    private func toggleFavorite(_ feedViewModel: FeedViewModel) {
        Task {
            do {
                try await feedRepository.toggleFavorite(feedViewModel.url)
            } catch {
                state = .error(ErrorUtils.toAppError(error))
            }
        }
    }
    
    func displayedFeeds(showOnlyFavorites: Bool) -> [FeedViewModel] {
        showOnlyFavorites ? favoriteFeeds : feeds
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
    
    func makeFeedItemsViewModel(for feed: FeedViewModel) -> FeedItemsViewModel {
        FeedItemsViewModel(
            feedURL: feed.url,
            feedTitle: feed.feed.title ?? LocalizedStrings.FeedList.unnamedFeed
        )
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
