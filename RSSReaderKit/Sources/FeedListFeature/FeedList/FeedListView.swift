//
//  FeedListView.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 28.04.25.
//

import Common
import FeedItemsFeature
import RSSClient
import SharedModels
import SharedUI
import SwiftUI

public struct FeedListView<ViewModel: FeedListViewModelProtocol>: View {
    @State private var showingAddFeed = false
    var viewModel: ViewModel
    
    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            switch viewModel.state {
            case .loading:
                ProgressView()
                
            case .error(let error):
                ErrorStateView(error: error) {
                    viewModel.setupFeeds()
                }
                
            case .empty:
                EmptyStateView(
                    title: viewModel.emptyStateTitle,
                    systemImage: Constants.Images.noItemsIcon,
                    description: viewModel.emptyStateDescription,
                    primaryAction: viewModel.showAddButton ? { showingAddFeed = true } : nil,
                    primaryActionLabel: viewModel.primaryActionLabel
                )
                
            case .content:
                List {
                    ForEach(viewModel.feeds, id: \.id) { feed in
                        FeedRow(
                            feed: feed,
                            onFavoriteToggle: {
                                viewModel.toggleFavorite(feed)
                            },
                            onNotificationsToggle: {
                                viewModel.toggleNotifications(feed)
                            },
                            notificationIcon: viewModel.notificationIcon(for: feed),
                            favoriteIcon: viewModel.favoriteIcon(for: feed)
                        )
                        .background {
                            NavigationLink(value: feed) {}.opacity(0)
                        }
                    }
                    .onDelete { indexSet in
                        viewModel.removeFeed(at: indexSet)
                    }
                }
                .testId(viewModel.listAccessibilityId)
            }
        }
        .navigationTitle(viewModel.navigationTitle)
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
            
            if viewModel.showAddButton {
                addButton
            }
        }
        .sheet(isPresented: $showingAddFeed) {
            AddFeedView()
        }
    }
    
    private var addButton: ToolbarItem<(), some View> {
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
}
