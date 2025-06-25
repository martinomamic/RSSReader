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
import ToastFeature

public struct ExploreView: View {
    @State var viewModel = ExploreViewModel()

    public init() {}

    public var body: some View {
        VStack {
            Picker("Filter", selection: $viewModel.selectedFilter) {
                ForEach(ExploreFeedFilter.allCases) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top)
            .onChange(of: viewModel.selectedFilter) { _, _ in
                viewModel.filterFeeds()
            }
            .testId(AccessibilityIdentifier.Explore.filterPicker)

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
                            onTapped: {
                                viewModel.handleFeed(feed)
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
                    title: viewModel.selectedFilter == .notAdded ? LocalizedStrings.Explore.noFeedsTitle : LocalizedStrings.Explore.noAddedFeedsTitle,
                    systemImage: Constants.Images.noItemsIcon,
                    description: viewModel.selectedFilter == .notAdded ? LocalizedStrings.Explore.noFeedsDescription : LocalizedStrings.Explore.noAddedFeedsDescription
                )
                .testId(AccessibilityIdentifier.Explore.emptyView)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(LocalizedStrings.Explore.title)
        .task {
            viewModel.loadExploreFeeds()
        }
        .toastOverlay(viewModel.toastService)
    }
}

extension AccessibilityIdentifier.Explore {
    static let filterPicker = "explore_filter_picker"
}
