//
//  FeedItemRow.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 14.04.25.
//

import SwiftUI
import SharedModels
import Common

struct FeedItemRow: View {
    let item: FeedItem

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.UI.feedItemSpacing) {
            if let imageURL = item.imageURL {
                AsyncImage(url: imageURL) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle().foregroundStyle(.gray.opacity(0.2))
                }
                .frame(height: Constants.UI.feedItemImageHeight)
                .clipShape(RoundedRectangle(cornerRadius: Constants.UI.feedItemCornerRadius))
            }

            Text(item.title)
                .font(.headline)
                .testId(AccessibilityIdentifier.FeedItems.itemTitle)

            if let description = item.description {
                Text(description)
                    .font(.subheadline)
                    .lineLimit(Constants.UI.feedItemDescriptionLineLimit)
                    .testId(AccessibilityIdentifier.FeedItems.itemDescription)
            }

            if let pubDate = item.pubDate {
                Text(pubDate, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .testId(AccessibilityIdentifier.FeedItems.itemDate)
            }
        }
        .padding(.vertical, Constants.UI.feedItemVerticalPadding)
    }
}

#if DEBUG
// swiftlint:disable line_length force_unwrapping
#Preview("With Image") {
    FeedItemRow(
        item: FeedItem(
            feedID: UUID(),
            title: "Breaking News: Important Event",
            link: URL(string: "https://example.com")!,
            pubDate: Date(),
            description: "This is a detailed description of the important event that just occurred. It contains multiple lines of text to demonstrate how the layout handles longer content.",
            imageURL: URL(string: "https://picsum.photos/800/400")
        )
    )
    .padding()
}

#Preview("Without Image") {
    FeedItemRow(
        item: FeedItem(
            feedID: UUID(),
            title: "Text Only News Item",
            link: URL(string: "https://example.com")!,
            pubDate: Date(),
            description: "This is a news item without an image to show how the layout adapts."
        )
    )
    .padding()
}
// swiftlint:enable line_length force_unwrapping
#endif
