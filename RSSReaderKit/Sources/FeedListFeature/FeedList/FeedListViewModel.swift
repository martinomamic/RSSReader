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

enum FeedListState: Equatable {
    case idle
    case loading
    case error(RSSViewError)
}

@MainActor
@Observable class FeedListViewModel {
    @ObservationIgnored
    @Dependency(\.rssClient) private var rssClient
    
    @ObservationIgnored
    @Dependency(\.persistenceClient) private var persistenceClient
    
    var feeds: [FeedViewModel] = []
    var state: FeedListState = .idle
    
    private var saveTask: Task<Void, Never>?
    private var loadTask: Task<Void, Never>?
    
    init() {
        loadFeeds()
    }
    
    func loadFeeds() {
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
            } catch {
                state = .error(RSSErrorMapper.mapToViewError(error))
            }
        }
    }
    
    func removeFeed(at indexSet: IndexSet) {
        feeds.remove(atOffsets: indexSet)
        saveFeeds()
    }
    
    func saveFeeds() {
        saveTask?.cancel()
        saveTask = Task {
            do {
                let feedsToSave = feeds.map { $0.feed }
                try await persistenceClient.saveFeeds(feedsToSave)
            } catch {
                state = .error(RSSErrorMapper.mapToViewError(error))
            }
        }
    }
}
