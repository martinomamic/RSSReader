//
//  ExploreFeedRow.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 18.04.25.
//

import SwiftUI
import SharedModels
import Common

struct ExploreFeedRow: View {
    let feed: ExploreFeed
    let isAdded: Bool
    let onAddTapped: () -> Void

    var body: some View {
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
                isEnabled: !isAdded
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
