//
//  FeedItemsView.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 14.04.25.
//

import Common
import RSSClient
import SharedModels
import SwiftUI

public struct FeedItemsView: View {
    @State var viewModel: FeedItemsViewModel
    
    public init(viewModel: FeedItemsViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
                
            case .loaded(let items):
                List {
                    ForEach(items) { item in
                        Button {
                            viewModel.openLink(for: item)
                        } label: {
                            FeedItemRow(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
            case .error(let error):
                ContentUnavailableView {
                    Label("Failed to Load", systemImage: Constants.Images.failedToLoadIcon)
                } description: {
                    Text(error.localizedDescription)
                }
                
            case .empty:
                ContentUnavailableView {
                    Label("No Items", systemImage: Constants.Images.noItemsIcon)
                } description: {
                    Text("This feed contains no items")
                }
            }
        }
        .navigationTitle(viewModel.feedTitle)
        .refreshable {
            await viewModel.loadItems()
        }
        .task {
            await viewModel.loadItems()
        }
    }
}
