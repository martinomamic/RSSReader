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
    var selectedFeed: ExploreFeed?
    var addedFeedURLs: Set<String> = []

    private var addTask: Task<Void, Never>?
    private var loadTask: Task<Void, Never>?

    public func loadExploreFeeds() {
        loadTask?.cancel()
        state = .loading

        loadTask = Task {
            do {
                let exploreFeeds = try await feedRepository.loadExploreFeeds()
                
                let currentFeeds = try await feedRepository.getCurrentFeeds()
                addedFeedURLs = Set(currentFeeds.map { $0.url.absoluteString })
                
                state = exploreFeeds.isEmpty ? .empty : .content(exploreFeeds)
            } catch {
                state = .error(ErrorUtils.toAppError(error))
            }
        }
    }

    func addFeed(_ exploreFeed: ExploreFeed) {
        addTask?.cancel()
        addTask = Task {
            do {
                _ = try await feedRepository.addExploreFeed(exploreFeed)
                let exploreFeeds = try await feedRepository.loadExploreFeeds()
                addedFeedURLs.insert(exploreFeed.url)
                state = .content(exploreFeeds)
            } catch {
                state = .error(ErrorUtils.toAppError(error))
            }
        }
    }

    func isFeedAdded(_ feed: ExploreFeed) -> Bool {
        addedFeedURLs.contains(feed.url)
    }
}
