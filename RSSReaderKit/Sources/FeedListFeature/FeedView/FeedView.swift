//
//  FeedRow.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 13.04.25.
//

import Common
import SwiftUI
import SharedModels

struct FeedView: View {
    let viewModel: FeedViewModel

    var body: some View {
        HStack(spacing: Constants.UI.feedRowSpacing) {
            switch viewModel.state {
            case .loading:
                Image(systemName: Constants.Images.loadingIcon)
                    .font(.title2)
                    .frame(width: Constants.UI.feedIconSize, height: Constants.UI.feedIconSize)

                VStack(alignment: .leading) {
                    Text(viewModel.url.absoluteString)
                        .font(.headline)
                        .lineLimit(Constants.UI.feedTitleLineLimit)
                    Text("Loading feed details...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

            case .loaded(let feed):
                if let imageURL = feed.imageURL {
                    AsyncImage(url: imageURL) { image in
                        image.resizable().aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Image(systemName: Constants.Images.placeholderImage)
                    }
                    .frame(width: Constants.UI.feedIconSize, height: Constants.UI.feedIconSize)
                    .cornerRadius(Constants.UI.cornerRadius)
                } else {
                    Image(systemName: Constants.Images.placeholderFeedIcon)
                        .font(.title2)
                        .frame(width: Constants.UI.feedIconSize, height: Constants.UI.feedIconSize)
                        .foregroundStyle(.blue)
                }

                VStack(alignment: .leading, spacing: Constants.UI.verticalPadding) {
                    Text(feed.title ?? "Unnamed Feed")
                        .font(.headline)

                    if let description = feed.description {
                        Text(description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(Constants.UI.feedDescriptionLineLimit)
                    }
                    HStack {
                        Spacer()

                        Button {
                            viewModel.toggleNotifications()
                        } label: {
                            Image(systemName: viewModel.feed.notificationsEnabled ? Constants.Images.notificationEnabledIcon : Constants.Images.notificationDisabledIcon)
                                .font(.title2)
                                .foregroundColor(viewModel.feed.notificationsEnabled ? .blue : .gray)
                        }
                        .buttonStyle(BorderlessButtonStyle())

                        Button {
                            viewModel.toggleFavorite()
                        } label: {
                            Image(systemName: viewModel.feed.isFavorite ? "star.fill" : "star")
                                .font(.title2)
                                .foregroundColor(viewModel.feed.isFavorite ? .yellow : .gray)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }

            case .error(let error):
                Image(systemName: Constants.Images.errorIcon)
                    .font(.title2)
                    .frame(width: Constants.UI.feedIconSize, height: Constants.UI.feedIconSize)
                    .foregroundStyle(.red)

                VStack(alignment: .leading) {
                    Text(viewModel.url.absoluteString)
                        .font(.headline)
                        .lineLimit(Constants.UI.feedTitleLineLimit)
                    Text("Failed to load feed: \(error.errorDescription)")
                        .font(.caption)
                        .foregroundStyle(.red)
                }

            case .empty:
                Text("No feed data available")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, Constants.UI.verticalPadding)
    }
}
