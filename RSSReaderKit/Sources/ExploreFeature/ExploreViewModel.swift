//
//  ExploreViewModel.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 18.04.25.
//

import Foundation
import Dependencies
import SharedModels
import Common
import ExploreClient
import PersistenceClient
import Observation

@MainActor
@Observable public class ExploreViewModel {
    @ObservationIgnored
    @Dependency(\.exploreClient) private var exploreClient
    
    @ObservationIgnored
    @Dependency(\.persistenceClient) private var persistenceClient
    
    enum State: Equatable {
        case loading
        case loaded([ExploreFeed])
        case error(RSSViewError)
    }
    
    var state: State = .loading
    var isAddingFeed = false
    var selectedFeed: ExploreFeed?
    var feedError: RSSViewError?
    var addedFeedURLs: Set<String> = []
    
    private var loadTask: Task<Void, Never>?
    private var addTask: Task<Void, Never>?
    
    public init() {}
    
    func loadExploreFeeds() {
        loadTask?.cancel()
        state = .loading
        
        loadTask = Task {
            do {
                // Load feeds from JSON
                let feeds = try await exploreClient.loadExploreFeeds()
                
                // Load saved feeds to check which ones are already added
                let savedFeeds = try await persistenceClient.loadFeeds()
                let savedURLs = Set(savedFeeds.map { $0.url.absoluteString })
                
                self.addedFeedURLs = savedURLs
                self.state = .loaded(feeds)
            } catch {
                state = .error(RSSErrorMapper.mapToViewError(error))
            }
        }
    }
    
    func isFeedAdded(_ feed: ExploreFeed) -> Bool {
        return addedFeedURLs.contains(feed.url)
    }
    
    func selectFeed(_ feed: ExploreFeed) {
        selectedFeed = feed
    }
    
    func clearSelectedFeed() {
        selectedFeed = nil
    }
    
    func addSelectedFeed() {
        guard let feed = selectedFeed else { return }
        addFeed(feed)
    }
    
    func addFeed(_ exploreFeed: ExploreFeed) {
        isAddingFeed = true
        feedError = nil
        
        addTask?.cancel()
        addTask = Task {
            do {
                _ = try await exploreClient.addFeed(exploreFeed)
                isAddingFeed = false
                // Mark this feed as added
                addedFeedURLs.insert(exploreFeed.url)
            } catch let error as RSSViewError {
                isAddingFeed = false
                feedError = error
            } catch {
                isAddingFeed = false
                feedError = .unknown(error.localizedDescription)
            }
        }
    }
    
    func clearError() {
        feedError = nil
    }
}
