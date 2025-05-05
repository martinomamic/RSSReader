//
//  ExploreView.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 18.04.25.
//

import Common
import SharedModels
import SharedUI
import SwiftUI

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
                        title: LocalizedStrings.Explore.noFeedsTitle,
                        systemImage: Constants.Images.noItemsIcon,
                        description: LocalizedStrings.Explore.noFeedsDescription
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
        .navigationTitle(LocalizedStrings.Explore.title)
        .alert(item: .init(
            get: { viewModel.feedError },
            set: { if $0 == nil { viewModel.clearError() } }
        )) { error in
            Alert(
                title: Text(LocalizedStrings.Explore.errorAddingFeed),
                message: Text(error.errorDescription),
                dismissButton: .default(Text(LocalizedStrings.General.ok)) {
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
