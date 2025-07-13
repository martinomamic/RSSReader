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
    case notAdded = "notAdded"
    case added = "added"

    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .notAdded:
            return LocalizedStrings.Explore.filterNotAdded
        case .added:
            return LocalizedStrings.Explore.filterAdded
        }
    }
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
    
    var processingFeedURLs: Set<String> = []
    
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
                    state = .error(ErrorUtils.toAppError(error))
                } else {
                    toastService.showError(LocalizedStrings.Explore.errorRefreshExplore)
                    filterFeeds()
                }
            }
        }
    }

    func addFeed(_ exploreFeed: ExploreFeed) {
        addTask?.cancel()
        processingFeedURLs.insert(exploreFeed.url)
        
        addTask = Task {
            defer {
                processingFeedURLs.remove(exploreFeed.url)
            }
            
            do {
                _ = try await feedRepository.addExploreFeed(exploreFeed)
                feeds = try await feedRepository.loadExploreFeeds()
                addedFeedURLs.insert(exploreFeed.url)
                filterFeeds()
                
                toastService.showSuccess(String(format: LocalizedStrings.Explore.successAdd, exploreFeed.name))
            } catch {
                toastService.showError(String(format: LocalizedStrings.Explore.errorAdd, exploreFeed.name))
            }
        }
    }

    func removeFeed(_ exploreFeed: ExploreFeed) {
        removeTask?.cancel()
        processingFeedURLs.insert(exploreFeed.url)
        
        removeTask = Task {
            defer {
                processingFeedURLs.remove(exploreFeed.url)
            }
            
            do {
                guard let feedURLToRemove = URL(string: exploreFeed.url) else {
                    toastService.showError(LocalizedStrings.Explore.invalidFeedURL)
                    return
                }
                try await feedRepository.delete(feedURLToRemove)

                feeds = try await feedRepository.loadExploreFeeds()
                addedFeedURLs.remove(exploreFeed.url)
                filterFeeds()
                
                toastService.showSuccess(String(format: LocalizedStrings.Explore.successRemove, exploreFeed.name))
            } catch {
                toastService.showError(String(format: LocalizedStrings.Explore.errorRemove, exploreFeed.name))
            }
        }
    }

    func isFeedAdded(_ feed: ExploreFeed) -> Bool {
        addedFeedURLs.contains(feed.url)
    }
    
    func isFeedProcessing(_ feed: ExploreFeed) -> Bool {
        processingFeedURLs.contains(feed.url)
    }
    
    func handleFeed(_ feed: ExploreFeed) {
        guard !processingFeedURLs.contains(feed.url) else { return }
        
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
