//
//  AddFeedViewModel.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 13.04.25.
//

import Common
import Dependencies
import Foundation
import SharedModels
import SwiftUI

@MainActor @Observable
class AddFeedViewModel {
    @ObservationIgnored
    @Dependency(\.feedRepository) private var feedRepository
    @ObservationIgnored
    @Dependency(\.exploreClient) private var exploreClient
    
    private var addFeedTask: Task<Void, Never>?
    private var loadExploreTask: Task<Void, Never>?
    
    var urlString: String = ""
    var state: ViewState<Bool> = .idle
    var exploreFeeds: [ExploreFeed] = []
    var addedFeedURLs: Set<String> = []
    
    init() {
        loadExploreFeeds()
    }
    
    var isAddButtonDisabled: Bool {
        !isValidURL
    }
    
    var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }
    
    var shouldDismiss: Bool {
        if case .content(true) = state { return true }
        return false
    }
    
    private var isValidURL: Bool {
        guard !urlString.isEmpty,
              let url = URL(string: urlString) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    func addFeed() {
        guard let url = URL(string: urlString) else {
            state = .error(AppError.invalidURL)
            return
        }
        
        addFeedTask?.cancel()
        state = .loading
        
        addFeedTask = Task {
            do {
                try await feedRepository.add(url)
                loadExploreFeeds()
                state = .content(true)
            } catch {
                state = .error(ErrorUtils.toAppError(error))
            }
        }
    }
    
    func addExploreFeed(_ exploreFeed: ExploreFeed) {
        addFeedTask?.cancel()
        state = .loading
        
        addFeedTask = Task {
            do {
                _ = try await feedRepository.addExploreFeed(exploreFeed)
                loadExploreFeeds()
                state = .content(true)
            } catch {
                state = .error(ErrorUtils.toAppError(error))
            }
        }
    }
    
    func loadExploreFeeds() {
        loadExploreTask?.cancel()
        
        loadExploreTask = Task {
            do {
                let allExploreFeeds = try await exploreClient.loadExploreFeeds()
                let currentFeeds = try await feedRepository.getCurrentFeeds()
                
                addedFeedURLs = Set(currentFeeds.map { $0.url.absoluteString })
                
                exploreFeeds = allExploreFeeds
                    .filter { !addedFeedURLs.contains($0.url) }
                    .prefix(10)
                    .map { $0 }
            } catch {
                exploreFeeds = []
            }
        }
    }
    
    func isFeedAdded(_ feed: ExploreFeed) -> Bool {
        addedFeedURLs.contains(feed.url)
    }
}

#if DEBUG
extension AddFeedViewModel {
    @MainActor
    func waitForAddToFinish() async {
        await addFeedTask?.value
    }
}
#endif
