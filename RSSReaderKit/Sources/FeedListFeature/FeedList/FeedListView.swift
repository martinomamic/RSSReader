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
    
    let viewModel: FeedListViewModel
    private let showOnlyFavorites: Bool

    public init(viewModel: FeedListViewModel, showOnlyFavorites: Bool = false) {
        self.viewModel = viewModel
        self.showOnlyFavorites = showOnlyFavorites
        print("DEBUG: FeedListView init - showOnlyFavorites: \(showOnlyFavorites)")
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
        .onChange(of: viewModel.feeds) { oldFeeds, newFeeds in
            verifyUIState(oldFeeds: oldFeeds, newFeeds: newFeeds)
        }
        .onAppear {
            localFeeds = viewModel.feeds
            print("DEBUG: FeedListView appeared - showOnlyFavorites: \(showOnlyFavorites)")
            print("DEBUG: Current feeds state:")
            for feed in viewModel.feeds {
                print("DEBUG: Feed: \(feed.url)")
                print("  - isFavorite: \(feed.isFavorite)")
                print("  - notificationsEnabled: \(feed.notificationsEnabled)")
                print("  - isVisible: \(viewModel.displayedFeeds(showOnlyFavorites: showOnlyFavorites).contains(feed))")
            }
        }
    }
    
    private func verifyUIState(oldFeeds: [Feed], newFeeds: [Feed]) {
        print("DEBUG: UI State Change - \(showOnlyFavorites ? "Favorites" : "All Feeds")")
        print("DEBUG: Old feeds count: \(oldFeeds.count), favorites: \(oldFeeds.filter(\.isFavorite).count)")
        print("DEBUG: New feeds count: \(newFeeds.count), favorites: \(newFeeds.filter(\.isFavorite).count)")
        
        // Check for specific changes
        let oldFavorites = Set(oldFeeds.filter(\.isFavorite).map(\.url))
        let newFavorites = Set(newFeeds.filter(\.isFavorite).map(\.url))
        
        if oldFavorites != newFavorites {
            print("DEBUG: Favorites changed:")
            print("DEBUG: Removed from favorites: \(oldFavorites.subtracting(newFavorites).map { $0.absoluteString })")
            print("DEBUG: Added to favorites: \(newFavorites.subtracting(oldFavorites).map { $0.absoluteString })")
        }
        
        let oldNotifications = Set(oldFeeds.filter(\.notificationsEnabled).map(\.url))
        let newNotifications = Set(newFeeds.filter(\.notificationsEnabled).map(\.url))
        
        if oldNotifications != newNotifications {
            print("DEBUG: Notifications changed:")
            print("DEBUG: Disabled notifications: \(oldNotifications.subtracting(newNotifications).map { $0.absoluteString })")
            print("DEBUG: Enabled notifications: \(newNotifications.subtracting(oldNotifications).map { $0.absoluteString })")
        }
        localFeeds = newFeeds
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
                        let currentState = viewModel.feeds.first(where: { $0.url == feed.url })?.isFavorite ?? feed.isFavorite
                        print("DEBUG: UI Action - Toggle favorite for \(feed.url)")
                        print("DEBUG: Current repository state - isFavorite: \(currentState)")
                        print("DEBUG: Feed visible in: \(showOnlyFavorites ? "favorites" : "all feeds")")
                        
                        // Perform update
                        var updatedFeed = feed
                        updatedFeed.isFavorite.toggle()
                         viewModel.toggleFavorite(updatedFeed)
                    },
                    onNotificationsToggle: {
                        let currentState = viewModel.feeds.first(where: { $0.url == feed.url })?.notificationsEnabled ?? feed.notificationsEnabled
                        print("DEBUG: UI Action - Toggle notifications for \(feed.url)")
                        print("DEBUG: Current repository state - notificationsEnabled: \(currentState)")
                        
                        // Perform update
                        var updatedFeed = feed
                        updatedFeed.notificationsEnabled.toggle()
                        viewModel.toggleNotifications(updatedFeed)
                        
                    },
                    notificationIcon: viewModel.notificationIcon(for: feed),
                    favoriteIcon: viewModel.favoriteIcon(for: feed)
                )
            }
            .onDelete { indexSet in
                let feeds = viewModel.displayedFeeds(showOnlyFavorites: showOnlyFavorites)
                print("DEBUG: UI Action - Delete/Unfavorite feeds:")
                indexSet.forEach { index in
                    print("DEBUG: - \(feeds[index].url), favorite: \(feeds[index].isFavorite)")
                    print("DEBUG: - visible in: \(showOnlyFavorites ? "favorites" : "all feeds")")
                }
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
