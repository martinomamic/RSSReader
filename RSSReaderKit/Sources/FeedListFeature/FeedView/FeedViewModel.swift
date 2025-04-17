//
//  FeedViewModel.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 13.04.25.
//

import Common
import Dependencies
import Foundation
import PersistenceClient
import RSSClient
import SharedModels

enum FeedViewState: Equatable {
    case loading
    case loaded(Feed)
    case error(RSSViewError)
    case empty
    
    static func == (lhs: FeedViewState, rhs: FeedViewState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading), (.empty, .empty):
            return true
        case (.loaded(let lhsFeed), .loaded(let rhsFeed)):
            return lhsFeed.id == rhsFeed.id
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

@MainActor
@Observable class FeedViewModel: Identifiable {
    @ObservationIgnored
    @Dependency(\.rssClient) private var rssClient
    @ObservationIgnored
    @Dependency(\.persistenceClient.updateFeed) private var updateFeed
    
    let url: URL
    var feed: Feed
    var state: FeedViewState = .loading
    
    private var toggleFavoriteTask: Task<Void, Never>?
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
                let fetchedFeed = try await rssClient.fetchFeed(url)
                state = .loaded(fetchedFeed)
            } catch let error {
                state = .error(RSSErrorMapper.mapToViewError(error))
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
                state = .error(RSSErrorMapper.mapToViewError(error))
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
