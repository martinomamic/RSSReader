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
    @State var viewModel = FeedListViewModel()
    @State private var showingAddFeed = false
    
    private let showOnlyFavorites: Bool

    public init(showOnlyFavorites: Bool = false) {
        self.showOnlyFavorites = showOnlyFavorites
    }

    public var body: some View {
        List {
            ForEach(viewModel.displayedFeeds(showOnlyFavorites: showOnlyFavorites)) { feed in
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
        .testId(viewModel.listAccessibilityId(showOnlyFavorites: showOnlyFavorites))
        .navigationTitle(viewModel.navigationTitle(showOnlyFavorites: showOnlyFavorites))
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: FeedViewModel.self) { feed in
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
            if viewModel.displayedFeeds(showOnlyFavorites: showOnlyFavorites).isEmpty {
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
