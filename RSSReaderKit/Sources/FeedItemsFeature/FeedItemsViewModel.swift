//
//  FeedItemsViewModel.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 14.04.25.
//

import Common
import Dependencies
import Foundation
import RSSClient
import SharedModels
import UIKit

@Observable @MainActor
public class FeedItemsViewModel: Identifiable {
    @ObservationIgnored
    @Dependency(\.rssClient) private var rssClient
    @ObservationIgnored
    @Dependency(\.openURL) private var openURL
    
    let feedURL: URL
    let feedTitle: String
    
    var state: FeedItemsState = .loading
    
    private var loadTask: Task<Void, Never>?
    
    public init(feedURL: URL, feedTitle: String) {
        self.feedURL = feedURL
        self.feedTitle = feedTitle
    }
    
    func loadItems() {
        loadTask?.cancel()
        state = .loading
        
        loadTask = Task {
            do {
                let items = try await rssClient.fetchFeedItems(feedURL)
                
                if items.isEmpty {
                    state = .empty
                } else {
                    state = .loaded(items)
                }
            } catch {
                state = .error(RSSErrorMapper.mapToViewError(error))
            }
        }
    }
    
    func openLink(for item: FeedItem) {
        Task {
            await openURL(item.link)
        }
    }
}
