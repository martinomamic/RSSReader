//
//  FeedListViewModel.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 13.04.25.
//

import Common
import Foundation
import SwiftUI
import PersistenceClient
import SharedModels
import Dependencies
import Observation
import FeedItemsFeature

enum FeedListState: Equatable {
    case idle
    case loading
    case error(AppError)
}

@MainActor @Observable
public class FeedListViewModel {
    @ObservationIgnored
    @Dependency(\.persistenceClient) private var persistenceClient

    var feeds: [FeedViewModel] = []
    var favoriteFeeds: [FeedViewModel] {
        feeds.filter { $0.feed.isFavorite }
    }
    var state: FeedListState = .idle

    var isEmptyState: Bool {
        displayedFeeds(showOnlyFavorites: false).isEmpty
    }
    
    var showEditButton: Bool {
        !feeds.isEmpty
    }
    
    private var loadTask: Task<Void, Never>?
    private var updateTask: Task<Void, Never>?
    private var deleteTask: Task<Void, Never>?

    public init() {}

    func loadFeeds() {
        feeds.removeAll()
        state = .loading
        loadTask?.cancel()
        loadTask = Task {
            do {
                let savedFeeds = try await persistenceClient.loadFeeds()
                feeds = savedFeeds.map { feed in
                    let viewModel = FeedViewModel(url: feed.url, feed: feed)
                    viewModel.state = .loaded(feed)
                    return viewModel
                }
                state = .idle
            } catch {
                state = .error(ErrorUtils.toAppError(error))
            }
        }
    }

    func removeFeed(at indexSet: IndexSet, fromFavorites: Bool = false) {
        if fromFavorites {
            let feedsToRemoveFromFavorites = indexSet.map { favoriteFeeds[$0] }
            for feed in feedsToRemoveFromFavorites {
                if let index = feeds.firstIndex(where: { $0.url == feed.url }) {
                    feeds[index].feed.isFavorite = false
                    toggleFavorite(feeds[index])
                }
            }
        } else {
            let feedsToDelete = indexSet.map { feeds[$0] }
            for feed in feedsToDelete {
                deleteFeed(feed)
            }
            feeds.remove(atOffsets: indexSet)
        }
    }

    private func toggleFavorite(_ feedViewModel: FeedViewModel) {
        updateTask?.cancel()
        updateTask = Task {
            do {
                try await persistenceClient.updateFeed(feedViewModel.feed)
            } catch {
                state = .error(ErrorUtils.toAppError(error))
            }
        }
    }

    private func deleteFeed(_ feedViewModel: FeedViewModel) {
        deleteTask?.cancel()
        deleteTask = Task {
            do {
                try await persistenceClient.deleteFeed(feedViewModel.url)
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
        await loadTask?.value
    }
    
    @MainActor
    func waitForUpdateToFinish() async {
        await updateTask?.value
    }
    
    @MainActor
    func waitForDeleteToFinish() async {
        await deleteTask?.value
    }
}
#endif
