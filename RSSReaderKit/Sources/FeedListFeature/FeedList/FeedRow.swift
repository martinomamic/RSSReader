//
//  FeedRow.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 28.04.25.
//

import Common
import SharedModels
import SharedUI
import SwiftUI

struct FeedRow: View, Equatable {
    let feed: Feed
    let onFavoriteToggle: () -> Void
    let onNotificationsToggle: () -> Void
    let notificationIcon: String
    let favoriteIcon: String

    nonisolated static func == (lhs: FeedRow, rhs: FeedRow) -> Bool {
        lhs.feed.url == rhs.feed.url &&
        lhs.feed.isFavorite == rhs.feed.isFavorite &&
        lhs.feed.notificationsEnabled == rhs.feed.notificationsEnabled
    }

    var body: some View {
        HStack(spacing: Constants.UI.feedRowSpacing) {
            FeedImageView(url: feed.imageURL)
                .id(feed.url)

            VStack(alignment: .leading, spacing: Constants.UI.verticalPadding) {
                Text(feed.title ?? LocalizedStrings.Feed.unnamedFeed)
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
                        action: onNotificationsToggle,
                        systemImage: notificationIcon,
                        isActive: feed.notificationsEnabled,
                        testId: AccessibilityIdentifier.FeedView.notificationsButton
                    )

                    ToggleButton(
                        action: onFavoriteToggle,
                        systemImage: favoriteIcon,
                        isActive: feed.isFavorite,
                        activeColor: .yellow,
                        testId: AccessibilityIdentifier.FeedView.favoriteButton
                    )
                }
            }
        }
        .padding(.vertical, Constants.UI.verticalPadding)
    }
}
