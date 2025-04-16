//
//  TabBarView.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 16.04.25.
//

import FeedListFeature
import SwiftUI

public struct TabBarView: View {
    @State private var viewModel = TabBarViewModel()
    
    private var selection: Binding<TabItem> {
        Binding(
            get: { viewModel.selectedTab },
            set: { viewModel.selectTab($0) }
        )
    }
    
    private func createTabView<T: View>(
        for tab: TabItem,
        content: @escaping () -> T
    ) -> some View {
        NavigationStack(path: Binding(
            get: { viewModel.navigationPath(for: tab) },
            set: { newPath in
                switch tab {
                case .feeds:
                    viewModel.feedsPath = newPath
                case .favorites:
                    viewModel.favoritesPath = newPath
                }
            }
        )) {
            content()
        }
        .tabItem {
            Label(
                tab.title,
                systemImage: viewModel.selectedTab == tab ? tab.selectedIcon : tab.icon
            )
        }
        .tag(tab)
    }
    
    public init() {}
    
    public var body: some View {
        TabView(selection: selection) {
            createTabView(for: .feeds) {
                FeedListView()
                    .environment(\.resetTriggerValue, viewModel.resetTrigger(for: .feeds))
            }
            
            createTabView(for: .favorites) {
                Text("Favorites Coming Soon")
                    .environment(\.resetTriggerValue, viewModel.resetTrigger(for: .favorites))
            }
        }
        .environment(\.tabBarViewModel, viewModel)
    }
}
