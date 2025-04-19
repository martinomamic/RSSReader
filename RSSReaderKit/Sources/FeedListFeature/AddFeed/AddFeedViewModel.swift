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

enum ExampleURL {
    case bbc
    case nbc
}

@MainActor @Observable
class AddFeedViewModel {
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

    var isAddButtonDisabled: Bool {
        !isValidURL || state == .adding
    }

    var isLoading: Bool {
        state == .adding
    }

    var shouldDismiss: Bool {
        state == .success
    }

    var errorMessage: String? {
        if case .error(let error) = state {
            return error.errorDescription
        }
        return nil
    }

    var errorAlertBinding: Binding<Bool> {
        .init(
            get: { if case .error = self.state { return true } else { return false } },
            set: { show in if !show { self.dismissError() } }
        )
    }

    private var isValidURL: Bool {
        guard !urlString.isEmpty else { return false }
        return URL(string: urlString) != nil
    }

    func setExampleURL(_ example: ExampleURL) {
        switch example {
        case .bbc:
            urlString = Constants.URLs.bbcNews
        case .nbc:
            urlString = Constants.URLs.nbcNews
        }
    }

    func dismissError() {
        state = .idle
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
                try await persistenceClient.addFeed(feed)
                state = .success
            } catch {
                state = .error(RSSErrorMapper.map(error))
            }
        }
    }
}
