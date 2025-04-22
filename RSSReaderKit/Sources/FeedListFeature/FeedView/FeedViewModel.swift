//
//  FeedViewModel.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 13.04.25.
//

import Common
import Dependencies
import Foundation
import NotificationClient
import PersistenceClient
import RSSClient
import SharedModels

enum FeedViewState: Equatable {
    case loading
    case loaded(Feed)
    case error(AppError)
    case empty
}

@MainActor @Observable
class FeedViewModel: Identifiable {
    @ObservationIgnored
    @Dependency(\.notificationClient) private var notificationClient
    @ObservationIgnored
    @Dependency(\.rssClient.fetchFeed) private var fetchFeed
    @ObservationIgnored
    @Dependency(\.persistenceClient.updateFeed) private var updateFeed

    let url: URL
    var feed: Feed
    var state: FeedViewState = .loading

    private var toggleFavoriteTask: Task<Void, Never>?
    private var toggleNotificationsTask: Task<Void, Never>?
    private var loadTask: Task<Void, Never>?

    init(url: URL, feed: Feed) {
        self.url = url
        self.feed = feed
    }

    func loadFeedDetails() {
        loadTask?.cancel()
        state = .loading

        loadTask = Task {
            do {
                let fetchedFeed = try await fetchFeed(url)
                state = .loaded(fetchedFeed)
            } catch let error {
                state = .error(ErrorUtils.toAppError(error))
            }
        }
    }

    func toggleFavorite() {
        toggleFavoriteTask?.cancel()
        feed.isFavorite.toggle()

        toggleFavoriteTask = Task {
            do {
                try await updateFeed(feed)
            } catch {
                state = .error(ErrorUtils.toAppError(error))
            }
        }
    }

    func toggleNotifications() {
        toggleNotificationsTask?.cancel()

        toggleNotificationsTask = Task {
            do {
                if !feed.notificationsEnabled {
                    try await notificationClient.requestPermissions()
                }

                feed.notificationsEnabled.toggle()
                try await updateFeed(feed)

                if feed.notificationsEnabled {
                    BackgroundRefreshClient.shared.scheduleAppRefresh()
                    try await notificationClient.checkForNewItems()
                }
            } catch {
                feed.notificationsEnabled.toggle()
                state = .error(ErrorUtils.toAppError(error))
            }
        }
    }
}

extension FeedViewModel: Hashable {
    nonisolated static func == (lhs: FeedViewModel, rhs: FeedViewModel) -> Bool {
        lhs.url == rhs.url
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}

#if DEBUG
extension FeedViewModel {
    @MainActor
    func waitForNotificationToggleToFinish() async {
        await toggleNotificationsTask?.value
    }
    
    @MainActor
    func waitForFavoritesToggleToFinish() async {
        await toggleFavoriteTask?.value
    }
}
#endif
