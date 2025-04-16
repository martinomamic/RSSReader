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
import WebViewFeature

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
                            viewModel.selectItem(item)
                        } label: {
                            FeedItemRow(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .sheet(isPresented: $viewModel.showItemDetail) {
                    if let selectedItem = viewModel.selectedItem {
                        WebContentView(url: selectedItem.link, title: selectedItem.title)
                    }
                }
                
            case .error(let error):
                ContentUnavailableView {
                    Label("Failed to Load", systemImage: Constants.Images.failedToLoadIcon)
                } description: {
                    Text(error.errorDescription)
                } actions: {
                    Button {
                        viewModel.loadItems()
                    } label: {
                        Text("Try Again")
                    }
                    .buttonStyle(.bordered)
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
        .task {
            viewModel.loadItems()
        }
    }
}
