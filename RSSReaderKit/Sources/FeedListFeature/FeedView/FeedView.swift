//
//  FeedRow.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 13.04.25.
//

import Common
import SwiftUI
import SharedModels

struct FeedView: View {
    let viewModel: FeedViewModel

    var body: some View {
        HStack(spacing: Constants.UI.feedRowSpacing) {
            switch viewModel.state {
            case .loading:
                Image(systemName: Constants.Images.loadingIcon)
                    .font(.title2)
                    .frame(width: Constants.UI.feedIconSize, height: Constants.UI.feedIconSize)
                    .testId(AccessibilityIdentifier.FeedView.loadingView)

                VStack(alignment: .leading) {
                    Text(viewModel.url.absoluteString)
                        .font(.headline)
                        .lineLimit(Constants.UI.feedTitleLineLimit)
                    Text("Loading feed details...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

            case .loaded(let feed):
                FeedImageView(url: feed.imageURL)

                VStack(alignment: .leading, spacing: Constants.UI.verticalPadding) {
                    Text(feed.title ?? "Unnamed Feed")
                        .font(.headline)
                        .testId(AccessibilityIdentifier.FeedView.feedTitle)

                    if let description = feed.description {
                        Text(description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(Constants.UI.feedDescriptionLineLimit)
                            .testId(AccessibilityIdentifier.FeedView.feedDescription)
                    }
                    HStack {
                        Spacer()

                        ToggleButton(
                            action: viewModel.toggleNotifications,
                            systemImage: viewModel.feed.notificationsEnabled ? Constants.Images.notificationEnabledIcon : Constants.Images.notificationDisabledIcon,
                            isActive: viewModel.feed.notificationsEnabled,
                            testId: AccessibilityIdentifier.FeedView.notificationsButton
                        )

                        ToggleButton(
                            action: viewModel.toggleFavorite,
                            systemImage: viewModel.feed.isFavorite ? Constants.Images.isFavoriteIcon : Constants.Images.isNotFavoriteIcon,
                            isActive: viewModel.feed.isFavorite,
                            activeColor: .yellow,
                            testId: AccessibilityIdentifier.FeedView.favoriteButton
                        )
                    }
                }

            case .error(let error):
                Image(systemName: Constants.Images.errorIcon)
                    .font(.title2)
                    .frame(width: Constants.UI.feedIconSize, height: Constants.UI.feedIconSize)
                    .foregroundStyle(.red)

                VStack(alignment: .leading) {
                    Text(viewModel.url.absoluteString)
                        .font(.headline)
                        .lineLimit(Constants.UI.feedTitleLineLimit)
                    Text("Failed to load feed: \(error.errorDescription)")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                .testId(AccessibilityIdentifier.FeedView.errorView)

            case .empty:
                Text("No feed data available")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, Constants.UI.verticalPadding)
    }
}
