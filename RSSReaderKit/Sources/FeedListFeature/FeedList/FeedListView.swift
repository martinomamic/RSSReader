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
    @State private var showingAddFeed = false
    @State private var localFeeds: [Feed] = []
    @State private var selectedFeed: Feed?
    
    let viewModel: FeedListViewModel
    private let showOnlyFavorites: Bool

    public init(viewModel: FeedListViewModel, showOnlyFavorites: Bool = false) {
        self.viewModel = viewModel
        self.showOnlyFavorites = showOnlyFavorites
    }

    public var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
            case .error(let error):
                Text(error.errorDescription)
            case .idle:
                feedsList
            }
        }
        .onChange(of: viewModel.feeds) { _, newFeeds in
            localFeeds = newFeeds
        }
        .onAppear {
            localFeeds = viewModel.feeds
        }
    }
    
    private var feedsList: some View {
        List {
            ForEach(
              viewModel.displayedFeeds(showOnlyFavorites: showOnlyFavorites),
              id: \.id
            ) { feed in
                    FeedRow(
                        feed: feed,
                        onFavoriteToggle: {
                            var updatedFeed = feed
                            updatedFeed.isFavorite.toggle()
                             viewModel.toggleFavorite(updatedFeed)
                        },
                        onNotificationsToggle: {
                            var updatedFeed = feed
                            updatedFeed.notificationsEnabled.toggle()
                            viewModel.toggleNotifications(updatedFeed)
                        },
                        notificationIcon: viewModel.notificationIcon(for: feed),
                        favoriteIcon: viewModel.favoriteIcon(for: feed)
                    ).background {
                        NavigationLink(value: feed) {}.opacity(0)
                    }
            }
            .onDelete { indexSet in
                viewModel.removeFeed(at: indexSet, fromFavorites: showOnlyFavorites)
            }
        }
        .testId(viewModel.listAccessibilityId(showOnlyFavorites: showOnlyFavorites))
        .navigationTitle(viewModel.navigationTitle(showOnlyFavorites: showOnlyFavorites))
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Feed.self) { feed in
            FeedItemsView(
                viewModel: viewModel.makeFeedItemsViewModel(for: feed)
            )
        }
        .toolbar {
            if viewModel.showEditButton {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                        .testId(AccessibilityIdentifier.FeedList.editButton)
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddFeed = true
                } label: {
                    Label(LocalizedStrings.FeedList.addFeed,
                          systemImage: Constants.Images.addIcon)
                }
                .testId(AccessibilityIdentifier.FeedList.addFeedButton)
            }
        }
        .sheet(isPresented: $showingAddFeed) {
            AddFeedView()
        }
        .overlay {
            if viewModel.isEmptyState(showOnlyFavorites: showOnlyFavorites) {
                EmptyStateView(
                    title: viewModel.emptyStateTitle(showOnlyFavorites: showOnlyFavorites),
                    systemImage: Constants.Images.noItemsIcon,
                    description: viewModel.emptyStateDescription(showOnlyFavorites: showOnlyFavorites),
                    primaryAction: showOnlyFavorites ? nil : { showingAddFeed = true },
                    primaryActionLabel: showOnlyFavorites ? nil : LocalizedStrings.FeedList.addFeed
                )
            }
        }
    }
}
