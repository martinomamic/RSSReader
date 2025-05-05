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
import SharedUI
import UIKit

@MainActor @Observable
public class FeedItemsViewModel: Identifiable {
    @ObservationIgnored
    @Dependency(\.openURL) private var openURL
    @ObservationIgnored
    @Dependency(\.rssClient.fetchFeedItems) private var fetchFeedItems

    public let feedTitle: String
    public let feedURL: URL

    var state: ViewState<[FeedItem]> = .loading

    var loadTask: Task<Void, Never>?

    public init(feedURL: URL, feedTitle: String) {
        self.feedURL = feedURL
        self.feedTitle = feedTitle
    }

    func loadItems() {
        loadTask?.cancel()
        state = .loading

        loadTask = Task {
            do {
                let items = try await fetchFeedItems(feedURL)

                if items.isEmpty {
                    state = .empty
                } else {
                    state = .content(items)
                }
            } catch {
                state = .error(ErrorUtils.toAppError(error))
            }
        }
    }

    func openLink(for item: FeedItem) {
        Task {
            await openURL(item.link)
        }
    }
}

#if DEBUG
extension FeedItemsViewModel {
    @MainActor
    func waitForLoadToFinish() async {
        await loadTask?.value
    }
}
#endif
