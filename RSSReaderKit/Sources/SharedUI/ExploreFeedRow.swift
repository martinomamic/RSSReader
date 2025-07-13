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
    public let isProcessing: Bool
    public let onTapped: () -> Void
    
    @State private var showProgress = false
    
    public init(
        feed: ExploreFeed,
        isAdded: Bool,
        isProcessing: Bool = false,
        onTapped: @escaping () -> Void
    ) {
        self.feed = feed
        self.isAdded = isAdded
        self.isProcessing = isProcessing
        self.onTapped = onTapped
    }

    public var body: some View {
        Button(action: onTapped) {
            HStack {
                VStack(alignment: .leading, spacing: Constants.UI.exploreFeedRowSpacing) {
                    Text(feed.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(feed.url)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(Constants.UI.exploreFeedUrlLineLimit)
                }

                Spacer()

                HStack(spacing: 6) {
                    if showProgress {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.7)
                    }
                    
                    Text(isAdded ? LocalizedStrings.ExploreFeed.remove : LocalizedStrings.ExploreFeed.add)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .onChange(of: isProcessing) { _, newValue in
                    if newValue {
                        Task {
                            try? await Task.sleep(for: .seconds(0.5))
                            showProgress = true
                        }
                    } else {
                        showProgress = false
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isAdded ? .green : .blue)
                .foregroundStyle(.white)
                .clipShape(Capsule())
            }
            .padding(.vertical, Constants.UI.verticalPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
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
