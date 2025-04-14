//
//  FeedListView.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 13.04.25.
//

import SwiftUI
import RSSClient
import SharedModels

public struct FeedListView: View {
    @State private var viewModel = FeedListViewModel()
    @State private var showingAddFeed = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.feeds) { feed in
                    NavigationLink(value: feed) {
                        FeedRow(viewModel: feed)
                    }
                }
            }
            .navigationTitle("RSS Feeds")
            .navigationDestination(for: FeedViewModel.self) { feed in
                Text("Feed details")
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddFeed = true
                    } label: {
                        Label("Add Feed", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFeed) {
                AddFeedView(feeds: $viewModel.feeds)
            }
            .overlay {
                if viewModel.feeds.isEmpty {
                    ContentUnavailableView {
                        Label("No Feeds", systemImage: "tray.fill")
                    } description: {
                        Text("Add an RSS feed to get started")
                    } actions: {
                        Button {
                            showingAddFeed = true
                        } label: {
                            Label("Add Feed", systemImage: "plus")
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
    }
}
