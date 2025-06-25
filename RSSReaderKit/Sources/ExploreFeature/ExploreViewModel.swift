//
//  ExploreViewModel.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 18.04.25.
//

import Common
import Dependencies
import FeedRepository
import Foundation
import Observation
import SharedModels
import SharedUI
import ToastFeature

enum ExploreFeedFilter: String, CaseIterable, Identifiable {
    case notAdded = "Not Added"
    case added = "Added"

    var id: String { self.rawValue }
}

@MainActor @Observable
class ExploreViewModel {
    @ObservationIgnored
    @Dependency(\.feedRepository) private var feedRepository

    var state: ViewState<[ExploreFeed]> = .loading
    var selectedFeed: ExploreFeed?
    var addedFeedURLs: Set<String> = []
    var selectedFilter: ExploreFeedFilter = .notAdded
    var feeds: [ExploreFeed] = []
    
    let toastService = ToastService()

    var addTask: Task<Void, Never>?
    var loadTask: Task<Void, Never>?
    var removeTask: Task<Void, Never>?

    var filteredFeeds: [ExploreFeed] {
        switch selectedFilter {
        case .notAdded:
            return feeds.filter { !addedFeedURLs.contains($0.url) }
        case .added:
            return feeds.filter { addedFeedURLs.contains($0.url) }
        }
    }

    public func loadExploreFeeds() {
        loadTask?.cancel()
        state = .loading

        loadTask = Task {
            do {
                let exploreFeeds = try await feedRepository.loadExploreFeeds()
                feeds = exploreFeeds
                
                let currentFeeds = try await feedRepository.getCurrentFeeds()
                addedFeedURLs = Set(currentFeeds.map { $0.url.absoluteString })
                
                filterFeeds()
            } catch {
                if feeds.isEmpty {
                    // First time loading failed - show error state with retry
                    state = .error(ErrorUtils.toAppError(error))
                } else {
                    // Refresh failed but we have cached data - show toast instead
                    toastService.showError("Failed to refresh explore feeds")
                    filterFeeds()
                }
            }
        }
    }

    func addFeed(_ exploreFeed: ExploreFeed) {
        addTask?.cancel()
        addTask = Task {
            do {
                _ = try await feedRepository.addExploreFeed(exploreFeed)
                feeds = try await feedRepository.loadExploreFeeds()
                addedFeedURLs.insert(exploreFeed.url)
                filterFeeds()
                
                toastService.showSuccess("Added \(exploreFeed.name)")
            } catch {
                toastService.showError("Failed to add \(exploreFeed.name)")
            }
        }
    }

    func removeFeed(_ exploreFeed: ExploreFeed) {
        removeTask?.cancel()
        removeTask = Task {
            do {
                guard let feedURLToRemove = URL(string: exploreFeed.url) else {
                    toastService.showError("Invalid feed URL")
                    return
                }
                try await feedRepository.delete(feedURLToRemove)

                feeds = try await feedRepository.loadExploreFeeds()
                
                addedFeedURLs.remove(exploreFeed.url)
                filterFeeds()
                
                toastService.showSuccess("Removed \(exploreFeed.name)")
            } catch {
                toastService.showError("Failed to remove \(exploreFeed.name)")
            }
        }
    }

    func isFeedAdded(_ feed: ExploreFeed) -> Bool {
        addedFeedURLs.contains(feed.url)
    }
    
    func handleFeed(_ feed: ExploreFeed) {
        if isFeedAdded(feed) {
            removeFeed(feed)
        } else {
            addFeed(feed)
        }
    }

    func filterFeeds() {
        if filteredFeeds.isEmpty {
            state = .empty
        } else {
            state = .content(filteredFeeds)
        }
    }
}
