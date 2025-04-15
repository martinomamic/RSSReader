//
//  AddFeedViewModel.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 13.04.25.
//

import Common
import Dependencies
import Foundation
import RSSClient
import SharedModels
import SwiftUI

enum AddFeedState: Equatable {
    case idle
    case adding
    case error(RSSViewError)
    case success
}

@MainActor
@Observable class AddFeedViewModel {
    @ObservationIgnored
    @Dependency(\.rssClient) private var rssClient
    
    private var feeds: Binding<[FeedViewModel]>
    
    var urlString: String = ""
    var state: AddFeedState = .idle
    
    init(feeds: Binding<[FeedViewModel]>) {
        self.feeds = feeds
    }
    
    var isValidURL: Bool {
        guard !urlString.isEmpty else { return false }
        return URL(string: urlString) != nil
    }
    
    func addFeed() async -> Bool {
        guard let url = URL(string: urlString) else {
            state = .error(.invalidURL)
            return false
        }
        
        if feeds.wrappedValue.contains(where: { $0.url == url }) {
            state = .error(.duplicateFeed)
            return false
        }
        
        state = .adding
        
        do {
            let feed = try await rssClient.fetchFeed(url)
            
            let feedViewModel = FeedViewModel(url: url, feed: feed)
            feedViewModel.state = .loaded(feed)
            
            feeds.wrappedValue.append(feedViewModel)
            
            state = .success
            return true
        } catch {
            state = .error(RSSErrorMapper.mapToViewError(error))
            return false
        }
    }
    
    func reset() {
        urlString = ""
        state = .idle
    }
}
