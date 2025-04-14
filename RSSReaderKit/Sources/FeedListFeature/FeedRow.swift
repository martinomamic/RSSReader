//
//  FeedRow.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 13.04.25.
//

import SwiftUI
import SharedModels

struct FeedRow: View {
    let viewModel: FeedViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            switch viewModel.state {
            case .loading:
                Image(systemName: "ellipsis.circle")
                    .font(.title2)
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading) {
                    Text(viewModel.url.absoluteString)
                        .font(.headline)
                        .lineLimit(1)
                    Text("Loading feed details...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
            case .loaded(let feed):
                if let imageURL = feed.imageURL {
                    AsyncImage(url: imageURL) { image in
                        image.resizable().aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Image(systemName: "photo")
                    }
                    .frame(width: 50, height: 50)
                    .cornerRadius(6)
                } else {
                    Image(systemName: "newspaper.fill")
                        .font(.title2)
                        .frame(width: 50, height: 50)
                        .foregroundStyle(.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(feed.title ?? "Unnamed Feed")
                        .font(.headline)
                    
                    if let description = feed.description {
                        Text(description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                
            case .error:
                Image(systemName: "exclamationmark.triangle")
                    .font(.title2)
                    .frame(width: 50, height: 50)
                    .foregroundStyle(.red)
                
                VStack(alignment: .leading) {
                    Text(viewModel.url.absoluteString)
                        .font(.headline)
                        .lineLimit(1)
                    Text("Failed to load feed")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                
            case .empty:
                Text("No feed data available")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
