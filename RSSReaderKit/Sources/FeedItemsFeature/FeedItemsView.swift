//
//  FeedItemsView.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 14.04.25.
//

import Common
import RSSClient
import SharedModels
import SharedUI
import SwiftUI

public struct FeedItemsView: View {
    @State var viewModel: FeedItemsViewModel

    public init(viewModel: FeedItemsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack {
            switch viewModel.state {
            case .loading:
                ProgressView(LocalizedStrings.LoadingStates.loading)
                    .testId(AccessibilityIdentifier.FeedItems.loadingView)

            case .content(let items):
                List {
                    ForEach(items) { item in
                        Button {
                            viewModel.openLink(for: item)
                        } label: {
                            FeedItemRow(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .testId(AccessibilityIdentifier.FeedItems.itemsList)

            case .error(let error):
                ErrorStateView(error: error) {
                    viewModel.loadItems()
                }
                .testId(AccessibilityIdentifier.FeedItems.errorView)

            case .empty:
                EmptyStateView(
                    title: LocalizedStrings.FeedItems.noItemsTitle,
                    systemImage: Constants.Images.noItemsIcon,
                    description: LocalizedStrings.FeedItems.noItemsDescription
                )
                .testId(AccessibilityIdentifier.FeedItems.emptyView)
            }
        }
        .navigationTitle(viewModel.feedTitle)
        .task {
            viewModel.loadItems()
        }
    }
}


#if DEBUG
import Dependencies

private extension FeedItem {
    static var preview: FeedItem {
        FeedItem(
            feedID: UUID(),
            title: "Example News Story",
            link: URL(string: Constants.URLs.bbcNews)!,
            pubDate: Date(),
            description: "This is an example news story with all the details you might expect.",
            imageURL: URL(string: Constants.URLs.bbcNews)
        )
    }

    static var previewNoImage: FeedItem {
        FeedItem(
            feedID: UUID(),
            title: "Text-Only Story",
            link: URL(string: Constants.URLs.nbcNews)!,
            pubDate: Date().addingTimeInterval(-3600),
            description: "This is a text-only story without an image."
        )
    }
}

#Preview("With Items") {
    withDependencies {
        $0.rssClient.fetchFeedItems = { _ in
            return [.preview, .previewNoImage]
        }
    } operation: {
        NavigationStack {
            FeedItemsView(
                viewModel: FeedItemsViewModel(
                    feedURL: URL(string: Constants.URLs.bbcNews)!,
                    feedTitle: "BBC News"
                )
            )
        }
    }
}

#Preview("Empty") {
    withDependencies {
        $0.rssClient.fetchFeedItems = { _ in
            return []
        }
    } operation: {
        NavigationStack {
            FeedItemsView(
                viewModel: FeedItemsViewModel(
                    feedURL: URL(string: Constants.URLs.bbcNews)!,
                    feedTitle: "BBC News"
                )
            )
        }
    }
}

#Preview("Error") {
    withDependencies {
        $0.rssClient.fetchFeedItems = { _ in
            throw RSSError.networkError(NSError(domain: "test", code: -1))
        }
    } operation: {
        NavigationStack {
            FeedItemsView(
                viewModel: FeedItemsViewModel(
                    feedURL: URL(string: Constants.URLs.bbcNews)!,
                    feedTitle: "BBC News"
                )
            )
        }
    }
}
#endif
