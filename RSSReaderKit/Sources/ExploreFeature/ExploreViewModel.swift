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

@MainActor @Observable
class ExploreViewModel {
    @ObservationIgnored
    @Dependency(\.feedRepository) private var feedRepository

    var state: ViewState<[ExploreFeed]> = .loading
    var isAddingFeed = false
    var selectedFeed: ExploreFeed?
    var feedError: AppError?
    var addedFeedURLs: Set<String> = []

    private var addTask: Task<Void, Never>?
    private var loadTask: Task<Void, Never>?
    private var setupStreamTask: Task<Void, Never>?

    public init() {
        loadExploreFeeds()
    }

    func loadExploreFeeds() {
        loadTask?.cancel()
        state = .loading

        loadTask = Task {
            do {
                let exploreFeeds = try await feedRepository.loadExploreFeeds()
                
                let currentFeeds = try await feedRepository.getCurrentFeeds()
                self.addedFeedURLs = Set(currentFeeds.map { $0.url.absoluteString })
                
                if exploreFeeds.isEmpty {
                    self.state = .empty
                } else {
                    self.state = .loaded(exploreFeeds)
                }
            } catch {
                state = .error(ErrorUtils.toAppError(error))
            }
        }
    }

    func addFeed(_ exploreFeed: ExploreFeed) {
        isAddingFeed = true
        feedError = nil

        addTask?.cancel()
        addTask = Task {
            do {
                _ = try await feedRepository.addExploreFeed(exploreFeed)
                addedFeedURLs.insert(exploreFeed.url)
                isAddingFeed = false
            } catch {
                isAddingFeed = false
                feedError = ErrorUtils.toAppError(error)
            }
        }
    }

    func isFeedAdded(_ feed: ExploreFeed) -> Bool {
        return addedFeedURLs.contains(feed.url)
    }

    func selectFeed(_ feed: ExploreFeed) {
        selectedFeed = feed
    }

    func clearSelectedFeed() {
        selectedFeed = nil
    }

    func addSelectedFeed() {
        guard let feed = selectedFeed else { return }
        addFeed(feed)
    }

    func clearError() {
        feedError = nil
    }
}
