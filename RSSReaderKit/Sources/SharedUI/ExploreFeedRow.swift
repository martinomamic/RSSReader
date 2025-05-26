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
    public let onTapped: () -> Void
    
    public init(
        feed: ExploreFeed,
        isAdded: Bool,
        onTapped: @escaping () -> Void
    ) {
        self.feed = feed
        self.isAdded = isAdded
        self.onTapped = onTapped
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
                title: isAdded ? LocalizedStrings.ExploreFeed.remove : LocalizedStrings.ExploreFeed.add,
                action: onTapped,
                backgroundColor: isAdded ? .green : .blue
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
        onTapped: {}
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
        onTapped: {}
    )
    .padding()
}
