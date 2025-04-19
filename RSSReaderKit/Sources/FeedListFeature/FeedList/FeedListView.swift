//
//  FeedListView.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 13.04.25.
//

import Common
import FeedItemsFeature
import RSSClient
import SharedModels
import SwiftUI

public struct FeedListView: View {
    @State private var viewModel = FeedListViewModel()
    @State private var showingAddFeed = false
    private let showOnlyFavorites: Bool

    public init(showOnlyFavorites: Bool = false) {
        self.showOnlyFavorites = showOnlyFavorites
    }

    var displayedFeeds: [FeedViewModel] {
        showOnlyFavorites ? viewModel.favoriteFeeds : viewModel.feeds
    }

    public var body: some View {
        List {
            let displayedFeeds = showOnlyFavorites ? viewModel.favoriteFeeds : viewModel.feeds

            ForEach(displayedFeeds) { feed in
                FeedView(viewModel: feed)
                    .background {
                        NavigationLink(value: feed) {}
                            .opacity(0)
                    }
            }
            .onDelete { indexSet in
                viewModel.removeFeed(at: indexSet, fromFavorites: showOnlyFavorites)
            }
        }
        .testId(showOnlyFavorites ?
            AccessibilityIdentifier.FeedList.favoritesList :
            AccessibilityIdentifier.FeedList.feedsList)
        .onAppear {
            viewModel.loadFeeds()
        }
        .navigationTitle(showOnlyFavorites ? 
            LocalizedStrings.FeedList.favoriteFeeds :
            LocalizedStrings.FeedList.rssFeeds)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: FeedViewModel.self) { feed in
            FeedItemsView(
                viewModel: FeedItemsViewModel(
                    feedURL: feed.url,
                    feedTitle: feed.feed.title ?? LocalizedStrings.FeedList.unnamedFeed
                )
            )
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddFeed = true
                } label: {
                    Label(LocalizedStrings.FeedList.addFeed,
                          systemImage: Constants.Images.addIcon)
                }
                .testId(AccessibilityIdentifier.FeedList.addFeedButton)
            }
            if !viewModel.feeds.isEmpty {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                        .testId(AccessibilityIdentifier.FeedList.editButton)
                }
            }
        }
        .sheet(isPresented: $showingAddFeed) {
            AddFeedView(feeds: $viewModel.feeds)
        }
        .overlay {
            if displayedFeeds.isEmpty {
                EmptyStateView(
                    title: showOnlyFavorites ?
                        LocalizedStrings.FeedList.noFavorites :
                        LocalizedStrings.FeedList.noFeeds,
                    systemImage: Constants.Images.noItemsIcon,
                    description: showOnlyFavorites ?
                        LocalizedStrings.FeedList.noFavoritesDescription :
                        LocalizedStrings.FeedList.noFeedsDescription,
                    primaryAction: showOnlyFavorites ? nil : { showingAddFeed = true },
                    primaryActionLabel: showOnlyFavorites ? nil : LocalizedStrings.FeedList.addFeed
                )
            }
        }
    }
}
