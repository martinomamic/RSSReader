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
            
            if let description = item.description {
                Text(description)
                    .font(.subheadline)
                    .lineLimit(Constants.UI.feedItemDescriptionLineLimit)
            }
            
            if let pubDate = item.pubDate {
                Text(pubDate, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, Constants.UI.feedItemVerticalPadding)
    }
}
