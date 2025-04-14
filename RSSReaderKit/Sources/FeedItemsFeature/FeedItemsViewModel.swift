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
    
    let feedURL: URL
    let feedTitle: String
    
    var state: FeedItemsState = .loading
    
    public init(feedURL: URL, feedTitle: String) {
        self.feedURL = feedURL
        self.feedTitle = feedTitle
    }
    
    @MainActor
    func loadItems() async {
        state = .loading
        
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
    
    @MainActor
    func openLink(for item: FeedItem) {
        UIApplication.shared.open(item.link)
    }
}
