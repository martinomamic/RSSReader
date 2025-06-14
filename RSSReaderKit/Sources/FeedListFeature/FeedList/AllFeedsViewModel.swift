//
//  AllFeedsViewModel.swift
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
public class AllFeedsViewModel: FeedListViewModelProtocol {
    @ObservationIgnored
    @Dependency(\.feedRepository) private var feedRepository
    @ObservationIgnored
    @Dependency(\.notificationRepository) private var notificationRepository
    
    public private(set) var feeds: [Feed] = []
    public var state: ViewState<[Feed]> = .loading
    
    private var feedStreamTask: Task<Void, Never>?
    private var deleteTask: Task<Void, Never>?
    private var favoritesTask: Task<Void, Never>?
    private var notificationsTask: Task<Void, Never>?
    
    public init() {
        setupFeeds()
    }
    
    public func setupFeeds() {
        feedStreamTask?.cancel()
        
        feedStreamTask = Task { @MainActor in
            do {
                try await feedRepository.loadInitialFeeds()
                for await updatedFeeds in feedRepository.feedsStream {
                    self.feeds = updatedFeeds
                    self.state = self.feeds.isEmpty ? .empty : .content(self.feeds)
                }
            } catch {
                self.state = .error(ErrorUtils.toAppError(error))
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
        deleteTask?.cancel()
        deleteTask = Task { @MainActor in
            do {
                guard let feed = indexSet.map({ self.feeds[$0] }).first else { return }
                try await self.feedRepository.delete(feed.url)
            } catch {
                self.state = .error(ErrorUtils.toAppError(error))
            }
        }
    }
}
