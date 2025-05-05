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
        VStack {
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .testId(AccessibilityIdentifier.Explore.loadingView)

            case .content(let feeds):
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

            case .error(let error):
                ErrorStateView(error: error) {
                    viewModel.loadExploreFeeds()
                }
                .testId(AccessibilityIdentifier.Explore.errorView)
                
            case .empty:
                EmptyStateView(
                    title: LocalizedStrings.Explore.noFeedsTitle,
                    systemImage: Constants.Images.noItemsIcon,
                    description: LocalizedStrings.Explore.noFeedsDescription
                )
                .testId(AccessibilityIdentifier.Explore.emptyView)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(LocalizedStrings.Explore.title)
        .task {
            viewModel.loadExploreFeeds()
        }
    }
}
