//
//  FeedViewModel.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 13.04.25.
//

import Dependencies
import Foundation
import RSSClient
import SharedModels

enum FeedViewState {
    case loading
    case loaded(Feed)
    case error(Error)
    case empty
}

@MainActor
@Observable class FeedViewModel: Identifiable {
    @ObservationIgnored
    @Dependency(\.rssClient) private var rssClient
    
    let url: URL
    var state: FeedViewState = .loading
    
    init(url: URL) {
        self.url = url
    }
    
    func loadFeedDetails() async {
        state = .loading
        
        do {
            let fetchedFeed = try await rssClient.fetchFeed(url)
            state = .loaded(fetchedFeed)
        } catch let error {
            state = .error(error)
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
