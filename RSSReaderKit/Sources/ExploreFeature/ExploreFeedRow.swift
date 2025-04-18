//
//  ExploreFeedRow.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 18.04.25.
//

import SwiftUI
import SharedModels

struct ExploreFeedRow: View {
    let feed: ExploreFeed
    let isAdded: Bool
    let onAddTapped: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(feed.name)
                    .font(.headline)
                
                Text(feed.url)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if isAdded {
                Text("Added")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            } else {
                Button(action: onAddTapped) {
                    Text("Add")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
