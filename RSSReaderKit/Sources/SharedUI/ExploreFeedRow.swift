//
//  ExploreFeedRow.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 18.04.25.
//

import Common
import SharedModels
import SwiftUI

public struct ExploreFeedRow: View {
    public let feed: ExploreFeed
    public let isAdded: Bool
    public let onAddTapped: () -> Void
    
    public init(
        feed: ExploreFeed,
        isAdded: Bool,
        onAddTapped: @escaping () -> Void
    ) {
        self.feed = feed
        self.isAdded = isAdded
        self.onAddTapped = onAddTapped
    }

    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Constants.UI.exploreFeedRowSpacing) {
                Text(feed.name)
                    .font(.headline)

                Text(feed.url)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(Constants.UI.exploreFeedUrlLineLimit)
            }

            Spacer()

            RoundedButton(
                title: isAdded ? LocalizedStrings.ExploreFeed.added : LocalizedStrings.ExploreFeed.add,
                action: onAddTapped,
                backgroundColor: isAdded ? .green : .blue,
                isDisabled: isAdded
            )
        }
        .padding(.vertical, Constants.UI.verticalPadding)
        .testId(AccessibilityIdentifier.Explore.feedRow)
    }
}

#Preview("Not Added") {
    ExploreFeedRow(
        feed: ExploreFeed(
            name: "BBC News",
            url: "https://feeds.bbci.co.uk/news/world/rss.xml"
        ),
        isAdded: false,
        onAddTapped: {}
    )
    .padding()
}

#Preview("Added") {
    ExploreFeedRow(
        feed: ExploreFeed(
            name: "BBC News",
            url: "https://feeds.bbci.co.uk/news/world/rss.xml"
        ),
        isAdded: true,
        onAddTapped: {}
    )
    .padding()
}
