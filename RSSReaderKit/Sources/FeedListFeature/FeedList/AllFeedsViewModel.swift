//
//  AllFeedsViewModel.swift
//  RSSReaderKit
//
//  Created by Martino Mamic on 06.05.25.
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
        // Only set up stream-task ONCE per VM instance!
        guard feedStreamTask == nil else { return }
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
    
    public func setupFeeds() {
        feedStreamTask?.cancel()
        
        feedStreamTask = Task { @MainActor in
            do {
                try await feedRepository.loadInitialFeeds()
                
                for await updatedFeeds in feedRepository.feedsStream {
                    self.feeds = updatedFeeds
                    
                    if updatedFeeds.isEmpty {
                        self.state = .empty
                    } else {
                        self.state = .content(updatedFeeds)
                    }
                }
            } catch {
                state = .error(ErrorUtils.toAppError(error))
            }
        }
    }
    
    public var showEditButton: Bool { !feeds.isEmpty }
    
    public var navigationTitle: String { LocalizedStrings.FeedList.rssFeeds }
    
    public var listAccessibilityId: String { AccessibilityIdentifier.FeedList.feedsList }
    
    public var emptyStateTitle: String { LocalizedStrings.FeedList.noFeeds }
    
    public var emptyStateDescription: String { LocalizedStrings.FeedList.noFeedsDescription }
    
    public var shouldShowAddFeedButton: Bool { true }
    
    public var primaryActionLabel: String? { LocalizedStrings.FeedList.addFeed }
    
    public func toggleNotifications(_ feed: Feed) {
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
    
    public func toggleFavorite(_ feed: Feed) {
        favoritesTask?.cancel()
        
        favoritesTask = Task { @MainActor in
            do {
                try await feedRepository.toggleFavorite(feed.url)
            } catch {
                state = .error(ErrorUtils.toAppError(error))
            }
        }
    }

    public func removeFeed(at indexSet: IndexSet) {
        deleteTask?.cancel()
        deleteTask = Task { @MainActor in
            do {
                let toDelete = indexSet.map { feeds[$0] }
                for feed in toDelete {
                    try await feedRepository.delete(feed.url)
                }
            } catch {
                self.state = .error(ErrorUtils.toAppError(error))
            }
        }
    }
}
