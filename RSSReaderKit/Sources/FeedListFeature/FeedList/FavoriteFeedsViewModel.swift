//
//  FavoriteFeedsViewModel.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 06.05.25.
//

import Common
import Dependencies
import FeedItemsFeature
import FeedRepository
import Foundation
import NotificationRepository
import Observation
import SharedModels

@MainActor @Observable
public class FavoriteFeedsViewModel: FeedListViewModelProtocol {
    @ObservationIgnored
    @Dependency(\.feedRepository) private var feedRepository
    @ObservationIgnored
    @Dependency(\.notificationRepository) private var notificationRepository
    
    public private(set) var feeds: [Feed] = []
    public var state: ViewState<[Feed]> = .loading

    private var feedStreamTask: Task<Void, Never>?
    private var favoritesTask: Task<Void, Never>?
    private var notificationsTask: Task<Void, Never>?
    
    public var showEditButton: Bool { false }
    public var showAddButton: Bool { false }
    public var navigationTitle: String { LocalizedStrings.FeedList.favoriteFeeds }
    public var listAccessibilityId: String { AccessibilityIdentifier.FeedList.favoritesList }
    public var emptyStateTitle: String { LocalizedStrings.FeedList.noFavorites }
    public var emptyStateDescription: String { LocalizedStrings.FeedList.noFavoritesDescription }
    public var primaryActionLabel: String? { nil }

    public init() {
        setupFeeds()
    }
    
    public func setupFeeds() {
        feedStreamTask?.cancel()
        
        feedStreamTask = Task { @MainActor in
            do {
                try await feedRepository.loadInitialFeeds()
                for await favoriteFeeds in feedRepository.favoriteFeedsStream {
                    self.feeds = favoriteFeeds
                    self.state = favoriteFeeds.isEmpty ? .empty : .content(favoriteFeeds)
                }
            } catch {
                state = .error(ErrorUtils.toAppError(error))
            }
        }
    }
    
    public func toggleNotifications(_ feed: Feed) {
        notificationsTask?.cancel()
        notificationsTask = Task { @MainActor in
            do {
                if await !self.notificationRepository.notificationsAuthorized() {
                    try await self.notificationRepository.requestPermissions()
                }
                
                try await self.feedRepository.toggleNotifications(feed.url)
            
                guard await self.notificationRepository.notificationsAuthorized(),
                      let updatedFeed = self.feeds.first(where: { $0.url == feed.url }),
                      updatedFeed.notificationsEnabled else { return }
                try await self.notificationRepository.checkForNewItems()
            } catch {
                self.state = .error(ErrorUtils.toAppError(error))
            }
        }
    }
    
    public func toggleFavorite(_ feed: Feed) {
        favoritesTask?.cancel()
        favoritesTask = Task { @MainActor in
            do {
                try await self.feedRepository.toggleFavorite(feed.url)
            } catch {
                self.state = .error(ErrorUtils.toAppError(error))
            }
        }
    }

    public func removeFeed(at indexSet: IndexSet) {
        favoritesTask?.cancel()
        favoritesTask = Task { @MainActor in
            do {
                guard let feed = indexSet.map({ feeds[$0] }).first else { return }
                
                try await feedRepository.toggleFavorite(feed.url)
            } catch {
                self.state = .error(ErrorUtils.toAppError(error))
            }
        }
    }
}
