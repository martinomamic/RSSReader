//
//  FeedViewModel.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 13.04.25.
//

import Common
import Dependencies
import Foundation
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
    
    let url: URL
    let feed: Feed
    var state: FeedViewState = .loading
    
    init(url: URL, feed: Feed) {
        self.url = url
        self.feed = feed
    }
    
    func loadFeedDetails() async {
        state = .loading
        
        do {
            let fetchedFeed = try await rssClient.fetchFeed(url)
            state = .loaded(fetchedFeed)
        } catch let error {
            state = .error(RSSErrorMapper.mapToViewError(error))
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
