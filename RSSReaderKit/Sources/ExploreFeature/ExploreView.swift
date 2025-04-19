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
                ProgressView()
                    .testId(AccessibilityIdentifier.Explore.loadingView)

            case .loaded(let feeds):
                if feeds.isEmpty {
                    EmptyStateView(
                        title: "No Feeds Found",
                        systemImage: Constants.Images.noItemsIcon,
                        description: "No feeds available"
                    )
                    .testId(AccessibilityIdentifier.Explore.emptyView)
                } else {
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

            case .error(let error):
                ErrorStateView(error: error) {
                    viewModel.loadExploreFeeds()
                }
                .testId(AccessibilityIdentifier.Explore.errorView)
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
}
