//
//  AddFeedViewModel.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 13.04.25.
//

import Dependencies
import Foundation
import SwiftUI
import RSSClient
import SharedModels

@MainActor
@Observable class AddFeedViewModel {
    @ObservationIgnored
    @Dependency(\.rssClient) private var rssClient
    
    private var feeds: Binding<[FeedViewModel]>
    
    var urlString: String = ""
    var isAdding: Bool = false
    var error: Error? = nil
    var showError: Bool = false
    
    init(feeds: Binding<[FeedViewModel]>) {
        self.feeds = feeds
    }
    
    var isValidURL: Bool {
        guard !urlString.isEmpty else { return false }
        return URL(string: urlString) != nil
    }
    
    func addFeed() async -> Bool {
        guard let url = URL(string: urlString) else {
            showError = true
            error = NSError(domain: "Invalid URL", code: 400,
                           userInfo: [NSLocalizedDescriptionKey: "Please enter a valid URL"])
            return false
        }
        
        if feeds.wrappedValue.contains(where: { $0.url == url }) {
            showError = true
            error = NSError(domain: "Duplicate Feed", code: 409,
                           userInfo: [NSLocalizedDescriptionKey: "This feed is already in your list"])
            return false
        }
        
        isAdding = true
        error = nil
        
        do {
            let feed = try await rssClient.fetchFeed(url)
            
            let feedViewModel = FeedViewModel(url: url)
            feedViewModel.state = .loaded(feed)
            
            feeds.wrappedValue.append(feedViewModel)
            
            isAdding = false
            return true
        } catch {
            self.error = error
            self.showError = true
            isAdding = false
            return false
        }
    }
    
    func reset() {
        urlString = ""
        isAdding = false
        error = nil
        showError = false
    }
}
