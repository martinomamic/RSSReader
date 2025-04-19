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

    public var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                loadingView
            case .loaded:
                if displayedFeeds.isEmpty {
                    emptyFavoritesView
                } else {
                    loadedView
                }
            case .empty:
                emptyView
            case .error(let error):
                errorView(error: error)
            }
        }
        .navigationTitle(showOnlyFavorites ? "Favorite Feeds" : "RSS Feeds")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: FeedViewModel.self) { feed in
            FeedItemsView(
                viewModel: FeedItemsViewModel(
                    feedURL: feed.url,
                    feedTitle: feed.feed.title ?? "Unnamed feed"
                )
            )
        }
        .toolbar {
            toolbarContent
        }
        .sheet(isPresented: $showingAddFeed) {
            AddFeedView(feeds: .constant(viewModel.allFeeds))
        }
        .task {
            viewModel.loadFeeds()
        }
    }
    
    private var displayedFeeds: [FeedViewModel] {
        showOnlyFavorites ? viewModel.favoriteFeeds : viewModel.allFeeds
    }
    
    private var loadingView: some View {
        ProgressView()
            .testId(AccessibilityIdentifier.FeedList.loadingView)
    }
    
    private var loadedView: some View {
        List {
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
    }
    
    private var emptyView: some View {
        EmptyStateView(
            title: "No Feeds",
            message: "Add an RSS feed to get started",
            icon: Constants.Images.noItemsIcon,
            actionTitle: "Add Feed",
            action: { showingAddFeed = true }
        )
    }
    
    private var emptyFavoritesView: some View {
        EmptyStateView(
            title: "No Favorites",
            message: "Add feeds to favorites from the Feeds tab",
            icon: Constants.Images.noItemsIcon
        )
    }
    
    private func errorView(error: RSSViewError) -> some View {
        ErrorView(
            message: error.errorDescription,
            retryAction: viewModel.loadFeeds
        )
        .testId(AccessibilityIdentifier.FeedList.errorView)
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                showingAddFeed = true
            } label: {
                Label("Add Feed", systemImage: Constants.Images.addIcon)
            }
            .testId(AccessibilityIdentifier.FeedList.addFeedButton)
        }
        
        if case .loaded = viewModel.state, !viewModel.allFeeds.isEmpty {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
                    .testId(AccessibilityIdentifier.FeedList.editButton)
            }
        }
    }
}
