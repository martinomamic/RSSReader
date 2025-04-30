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

enum ExploreState: Equatable {
    case loading
    case loaded([ExploreFeed])
    case error(AppError)
}

@MainActor @Observable
class ExploreViewModel {
    @ObservationIgnored
    @Dependency(\.feedRepository) private var feedRepository

    var state: ExploreState = .loading
    var isAddingFeed = false
    var selectedFeed: ExploreFeed?
    var feedError: AppError?
    var addedFeedURLs: Set<String> = []

    private var loadTask: Task<Void, Never>?
    private var addTask: Task<Void, Never>?

    public init() {}

    func loadExploreFeeds() {
        loadTask?.cancel()
        state = .loading

        loadTask = Task {
            do {
                let feeds = try await feedRepository.loadExploreFeeds()

//                let savedFeeds = try await feedRepository.loadFeeds()
//                let savedURLs = Set(savedFeeds.map { $0.url.absoluteString })
//
//                self.addedFeedURLs = savedURLs
                self.state = .loaded(feeds)
            } catch {
                state = .error(ErrorUtils.toAppError(error))
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

    func addFeed(_ exploreFeed: ExploreFeed) {
        isAddingFeed = true
        feedError = nil

        addTask?.cancel()
        addTask = Task {
            do {
                _ = try await feedRepository.addExploreFeed(exploreFeed)
                isAddingFeed = false
                addedFeedURLs.insert(exploreFeed.url)
            } catch {
                isAddingFeed = false
                feedError = ErrorUtils.toAppError(error)
            }
        }
    }

    func clearError() {
        feedError = nil
    }
}
