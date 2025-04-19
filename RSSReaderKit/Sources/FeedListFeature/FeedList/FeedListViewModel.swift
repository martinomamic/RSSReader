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
    case loading
    case loaded([Feed])
    case error(RSSViewError)
    case empty
}

@MainActor @Observable
public class FeedListViewModel {
    @ObservationIgnored
    @Dependency(\.rssClient) private var rssClient

    @ObservationIgnored
    @Dependency(\.persistenceClient) private var persistenceClient

    var state: FeedListState = .loading
    
    var favoriteFeeds: [FeedViewModel] {
        guard case .loaded(let feeds) = state else { return [] }
        return feeds
            .filter { $0.isFavorite }
            .map { FeedViewModel(url: $0.url, feed: $0) }
    }
    
    var allFeeds: [FeedViewModel] {
        guard case .loaded(let feeds) = state else { return [] }
        return feeds.map { FeedViewModel(url: $0.url, feed: $0) }
    }

    private var loadTask: Task<Void, Never>?
    private var updateTask: Task<Void, Never>?
    private var deleteTask: Task<Void, Never>?

    public init() {}

    func loadFeeds() {
        state = .loading
        loadTask?.cancel()
        loadTask = Task {
            do {
                let savedFeeds = try await persistenceClient.loadFeeds()
                if savedFeeds.isEmpty {
                    state = .empty
                } else {
                    state = .loaded(savedFeeds)
                }
            } catch {
                state = .error(RSSErrorMapper.map(error))
            }
        }
    }

    func removeFeed(at indexSet: IndexSet, fromFavorites: Bool = false) {
        guard case .loaded(var feeds) = state else { return }
        
        if fromFavorites {
            let feedsToUpdate = indexSet.map { favoriteFeeds[$0] }
            for feedVM in feedsToUpdate {
                if let index = feeds.firstIndex(where: { $0.url == feedVM.url }) {
                    feeds[index].isFavorite = false
                    updateFeed(feeds[index])
                }
            }
        } else {
            let feedsToDelete = indexSet.map { allFeeds[$0] }
            for feedVM in feedsToDelete {
                deleteFeed(feedVM.url)
                if let index = feeds.firstIndex(where: { $0.url == feedVM.url }) {
                    feeds.remove(at: index)
                }
            }
        }
        
        if feeds.isEmpty {
            state = .empty
        } else {
            state = .loaded(feeds)
        }
    }

    private func updateFeed(_ feed: Feed) {
        updateTask?.cancel()
        updateTask = Task {
            do {
                try await persistenceClient.updateFeed(feed)
            } catch {
                state = .error(RSSErrorMapper.map(error))
            }
        }
    }

    private func deleteFeed(_ url: URL) {
        deleteTask?.cancel()
        deleteTask = Task {
            do {
                try await persistenceClient.deleteFeed(url)
            } catch {
                state = .error(RSSErrorMapper.map(error))
            }
        }
    }
}
