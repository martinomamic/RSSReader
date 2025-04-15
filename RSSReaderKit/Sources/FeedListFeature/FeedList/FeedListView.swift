//
//  FeedListView.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 13.04.25.
//

import Common
import FeedItemsFeature
import RSSClient
import SharedModels
import SwiftUI

public struct FeedListView: View {
    @State private var viewModel = FeedListViewModel()
    @State private var showingAddFeed = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.feeds) { feed in
                    NavigationLink(value: feed) {
                        FeedView(viewModel: feed)
                    }
                }
                .onDelete { indexSet in
                    viewModel.removeFeed(at: indexSet)
                }
            }
            .navigationTitle("RSS Feeds")
            .navigationDestination(for: FeedViewModel.self) { feed in
                FeedItemsView(
                    viewModel: FeedItemsViewModel(
                        feedURL: feed.url,
                        feedTitle: feed.feed.title ?? "Unnamed feed"
                    )
                )
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddFeed = true
                    } label: {
                        Label("Add Feed", systemImage: Constants.Images.addIcon)
                    }
                }
                if !viewModel.feeds.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                }
            }
            .sheet(isPresented: $showingAddFeed) {
                AddFeedView(feeds: $viewModel.feeds)
            }
            .overlay {
                if viewModel.feeds.isEmpty {
                    ContentUnavailableView {
                        Label("No Feeds", systemImage: Constants.Images.noItemsIcon)
                    } description: {
                        Text("Add an RSS feed to get started")
                    } actions: {
                        Button {
                            showingAddFeed = true
                        } label: {
                            Label("Add Feed", systemImage: Constants.Images.addIcon)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
    }
}
