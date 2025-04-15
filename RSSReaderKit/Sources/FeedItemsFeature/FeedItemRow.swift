//
//  FeedItemRow.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 14.04.25.
//

import SwiftUI
import SharedModels

struct FeedItemRow: View {
    let item: FeedItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageURL = item.imageURL {
                AsyncImage(url: imageURL) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle().foregroundStyle(.gray.opacity(0.2))
                }
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            Text(item.title)
                .font(.headline)
            
            if let description = item.description {
                Text(description)
                    .font(.subheadline)
                    .lineLimit(3)
            }
            
            if let pubDate = item.pubDate {
                Text(pubDate, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}
