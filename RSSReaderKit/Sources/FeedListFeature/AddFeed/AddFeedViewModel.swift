//
//  AddFeedViewModel.swift
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
    @Dependency(\.persistenceClient) private var persistenceClient
    
    @ObservationIgnored
    @Dependency(\.rssClient) private var rssClient
    
    private var feeds: Binding<[FeedViewModel]>
    private var addFeedTask: Task<Void, Never>?
    
    var urlString: String = ""
    var state: AddFeedState = .idle
    
    init(feeds: Binding<[FeedViewModel]>) {
        self.feeds = feeds
    }
    
    var isValidURL: Bool {
        guard !urlString.isEmpty else { return false }
        return URL(string: urlString) != nil
    }
    
    func addFeed() {
        guard let url = URL(string: urlString) else {
            state = .error(.invalidURL)
            return
        }
        
        guard !feeds.wrappedValue.contains(where: { $0.url == url }) else {
            state = .error(.duplicateFeed)
            return
        }
        
        addFeedTask?.cancel()
        
        state = .adding
        
        addFeedTask = Task {
            do {
                let feed = try await rssClient.fetchFeed(url)
                
                let feedViewModel = FeedViewModel(url: url, feed: feed)
                feedViewModel.state = .loaded(feed)
                
                feeds.wrappedValue.insert(feedViewModel, at: 0) 
                
                let feedsToSave = feeds.wrappedValue.map { $0.feed }
                try await persistenceClient.saveFeeds(feedsToSave)
                
                state = .success
            } catch {
                state = .error(RSSErrorMapper.mapToViewError(error))
            }
        }
    }
}
