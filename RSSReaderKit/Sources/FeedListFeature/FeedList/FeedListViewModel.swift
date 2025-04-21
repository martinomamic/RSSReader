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
import RSSClient
import SharedModels
import Dependencies
import Observation
import NotificationClient

enum FeedListState: Equatable {
    case idle
    case loading
    case error(RSSViewError)
}

// Main ViewModel for feeds, also now owns notification toggle logic
@MainActor @Observable
public class FeedListViewModel {
    @ObservationIgnored
    @Dependency(\.rssClient) private var rssClient

    @ObservationIgnored
    @Dependency(\.persistenceClient) private var persistenceClient

    @ObservationIgnored
    @Dependency(\.notificationClient) private var notificationClient

    var feeds: [FeedViewModel] = []
    var state: FeedListState = .idle

    var favoriteFeeds: [FeedViewModel] {
        feeds.filter { $0.feed.isFavorite }
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
                // Ensure BGTask scheduling is correct on launch/load
                refreshBackgroundTaskSchedulingIfNeeded()
            } catch {
                state = .error(RSSErrorMapper.map(error))
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
            // Check if scheduling should change after removal
            refreshBackgroundTaskSchedulingIfNeeded()
        }
    }

    private func toggleFavorite(_ feedViewModel: FeedViewModel) {
        updateTask?.cancel()
        updateTask = Task {
            do {
                try await persistenceClient.updateFeed(feedViewModel.feed)
            } catch {
                state = .error(RSSErrorMapper.map(error))
            }
        }
    }

    private func deleteFeed(_ feedViewModel: FeedViewModel) {
        deleteTask?.cancel()
        deleteTask = Task {
            do {
                try await persistenceClient.deleteFeed(feedViewModel.url)
                // After actual delete, refresh scheduling
                refreshBackgroundTaskSchedulingIfNeeded()
            } catch {
                state = .error(RSSErrorMapper.map(error))
            }
        }
    }

    // --- CENTRALIZED NOTIFICATION TOGGLE LOGIC ---
    func toggleNotifications(for feedViewModel: FeedViewModel) async {
        updateTask?.cancel()
        updateTask = Task {
            do {
                // Only request permissions if turning on notifications
                if !feedViewModel.feed.notificationsEnabled {
                    let authorizationStatus = await notificationClient.checkAuthorizationStatus()
                    
                    if authorizationStatus == .notDetermined {
                        try await notificationClient.requestPermissions()
                        let newAuthorizationStatus = await notificationClient.checkAuthorizationStatus()
                        guard newAuthorizationStatus == .authorized else {
                            state = .error(.notificationPermissionDenied)
                            return
                        }
                    } else if authorizationStatus != .authorized {
                        state = .error(.notificationPermissionDenied)
                        return
                    }
                    
                    feedViewModel.feed.lastFetchDate = Date()
                }

                feedViewModel.feed.notificationsEnabled.toggle()
                try await persistenceClient.updateFeed(feedViewModel.feed)
                
                refreshBackgroundTaskSchedulingIfNeeded()
            } catch {
                state = .error(RSSErrorMapper.map(error))
            }
        }
    }

    // --- SINGLE SOURCE OF TRUTH FOR BGTask SCHEDULING ---
    func refreshBackgroundTaskSchedulingIfNeeded() {
        Task {
            @Dependency(\.persistenceClient.loadFeeds) var loadFeeds
            do {
                let feeds = try await loadFeeds()
                let enabledFeeds = feeds.filter(\.notificationsEnabled)
                if enabledFeeds.isEmpty {
                    BackgroundRefreshClient.shared.cancelScheduledRefresh()
                } else {
                    BackgroundRefreshClient.shared.scheduleAppRefresh()
                }
            } catch {
                print("[FeedListViewModel] Failed to update BGTask scheduling: \(error)")
            }
        }
    }
}
