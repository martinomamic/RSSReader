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
                    .accessibilityAddTraits(.isHeader)

                Text(feed.url)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(Constants.UI.exploreFeedUrlLineLimit)
                    .accessibilityLabel("Feed URL")
                    .accessibilityValue(feed.url)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(feed.name), Feed URL \(feed.url)")

            Spacer()

            if isAdded {
                Text("Added")
                    .font(.caption)
                    .padding(.horizontal, Constants.UI.exploreFeedButtonHorizontalPadding)
                    .padding(.vertical, Constants.UI.exploreFeedButtonVerticalPadding)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(Constants.UI.exploreFeedButtonCornerRadius)
                    .accessibilityLabel("Feed already added")
                    .accessibilityAddTraits(.isButton)
            } else {
                Button(action: onAddTapped) {
                    Text("Add to feeds")
                        .font(.caption)
                        .padding(.horizontal, Constants.UI.exploreFeedButtonHorizontalPadding)
                        .padding(.vertical, Constants.UI.exploreFeedButtonVerticalPadding)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(Constants.UI.exploreFeedButtonCornerRadius)
                }
                .accessibilityLabel("Add \(feed.name) feed")
                .accessibilityHint("Tap to add this feed to your feeds list")
            }
        }
        .padding(.vertical, Constants.UI.verticalPadding)
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
