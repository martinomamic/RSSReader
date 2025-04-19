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
                loadingView
            case .loaded(let feed):
                loadedView(feed: feed)
            case .error(let error):
                errorView(error: error)
            case .empty:
                emptyView
            }
        }
        .padding(.vertical, Constants.UI.verticalPadding)
    }
    
    private var loadingView: some View {
        Group {
            Image(systemName: Constants.Images.loadingIcon)
                .font(.title2)
                .frame(width: Constants.UI.feedIconSize, height: Constants.UI.feedIconSize)
                .testId(AccessibilityIdentifier.FeedView.loadingView)

            VStack(alignment: .leading) {
                Text(viewModel.url.absoluteString)
                    .font(.headline)
                    .lineLimit(Constants.UI.feedTitleLineLimit)
                Text("Loading feed details...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func loadedView(feed: Feed) -> some View {
        Group {
            feedIcon(imageURL: feed.imageURL)
            
            VStack(alignment: .leading, spacing: Constants.UI.verticalPadding) {
                Text(feed.title ?? "Unnamed Feed")
                    .font(.headline)
                    .testId(AccessibilityIdentifier.FeedView.feedTitle)

                if let description = feed.description {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(Constants.UI.feedDescriptionLineLimit)
                        .testId(AccessibilityIdentifier.FeedView.feedDescription)
                }
                
                actionButtons
            }
        }
    }
    
    private func feedIcon(imageURL: URL?) -> some View {
        Group {
            if let imageURL = imageURL {
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
        }
    }
    
    private var actionButtons: some View {
        HStack {
            Spacer()

            Button(action: viewModel.toggleNotifications) {
                Image(systemName: viewModel.feed.notificationsEnabled ? Constants.Images.notificationEnabledIcon : Constants.Images.notificationDisabledIcon)
                    .font(.title2)
                    .foregroundColor(viewModel.feed.notificationsEnabled ? .blue : .gray)
            }
            .buttonStyle(BorderlessButtonStyle())
            .testId(AccessibilityIdentifier.FeedView.notificationsButton)

            Button {
                viewModel.toggleFavorite()
            } label: {
                Image(systemName: viewModel.feed.isFavorite ? "star.fill" : "star")
                    .font(.title2)
                    .foregroundColor(viewModel.feed.isFavorite ? .yellow : .gray)
            }
            .buttonStyle(BorderlessButtonStyle())
            .testId(AccessibilityIdentifier.FeedView.favoriteButton)
        }
    }
    
    private func errorView(error: RSSViewError) -> some View {
        Group {
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
            .testId(AccessibilityIdentifier.FeedView.errorView)
        }
    }
    
    private var emptyView: some View {
        Text("No feed data available")
            .foregroundStyle(.secondary)
    }
}
