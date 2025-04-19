//
//  ExploreView.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 18.04.25.
//

import SwiftUI
import Common
import SharedModels

public struct ExploreView: View {
    @State var viewModel = ExploreViewModel()

    public init() {}

    public var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                loadingView
            case .loaded(let feeds):
                if feeds.isEmpty {
                    emptyView
                } else {
                    loadedView(feeds: feeds)
                }
            case .error(let error):
                errorView(error: error)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Explore Feeds")
        .alert(item: .init(
            get: { viewModel.feedError },
            set: { if $0 == nil { viewModel.clearError() } }
        )) { error in
            Alert(
                title: Text("Error Adding Feed"),
                message: Text(error.errorDescription),
                dismissButton: .default(Text("OK")) {
                    viewModel.clearError()
                }
            )
        }
        .overlay {
            if viewModel.isAddingFeed {
                ProgressView()
            }
        }
        .task {
            viewModel.loadExploreFeeds()
        }
    }
    
    private var loadingView: some View {
        ProgressView()
            .testId(AccessibilityIdentifier.Explore.loadingView)
    }
    
    private func loadedView(feeds: [ExploreFeed]) -> some View {
        List {
            ForEach(feeds) { feed in
                ExploreFeedRow(
                    feed: feed,
                    isAdded: viewModel.isFeedAdded(feed),
                    onAddTapped: {
                        viewModel.addFeed(feed)
                    }
                )
            }
        }
        .testId(AccessibilityIdentifier.Explore.feedsList)
    }
    
    private var emptyView: some View {
        EmptyStateView(
            title: "No Feeds Found",
            message: "No feeds available",
            icon: Constants.Images.noItemsIcon
        )
        .testId(AccessibilityIdentifier.Explore.emptyView)
    }
    
    private func errorView(error: RSSViewError) -> some View {
        ErrorView(
            message: error.errorDescription,
            retryAction: viewModel.loadExploreFeeds
        )
        .testId(AccessibilityIdentifier.Explore.errorView)
    }
}
