//
//  TabBarView.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 16.04.25.
//

import SwiftUI
import FeedListFeature

public struct TabBarView: View {
    @State private var viewModel = TabBarViewModel()
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                tabContent(for: tab)
                    .tabItem {
                        Label(
                            viewModel.getTitle(for: tab),
                            systemImage: viewModel.getIcon(for: tab)
                        )
                    }
                    .tag(tab)
            }
        }
    }
    
    @ViewBuilder
    private func tabContent(for tab: TabItem) -> some View {
        NavigationStack {
            switch tab {
            case .feeds:
                FeedListView()
            case .favorites:
                Text("Favorites Coming Soon")
            }
        }
    }
}
