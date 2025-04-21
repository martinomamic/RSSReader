//
//  TabBarView.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 16.04.25.
//

import Common
import SwiftUI
import ExploreFeature
import FeedListFeature
import NotificationClient

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
                        .accessibilityIdentifier(accessibilityIdForTab(tab))
                    }
                    .tag(tab)
            }
        }
        .testId(AccessibilityIdentifier.TabBar.navigationTabs)
    }
    
    private func accessibilityIdForTab(_ tab: TabItem) -> String {
        switch tab {
        case .feeds:
            return AccessibilityIdentifier.TabBar.feedsTab
        case .favorites:
            return AccessibilityIdentifier.TabBar.favoritesTab
        case .explore:
            return AccessibilityIdentifier.TabBar.exploreTab
        case .debug:
            return AccessibilityIdentifier.TabBar.debugTab
        }
    }
    
    @ViewBuilder
    private func tabContent(for tab: TabItem) -> some View {
        NavigationStack {
            switch tab {
            case .feeds:
                FeedListView()
            case .favorites:
                FeedListView(showOnlyFavorites: true)
            case .explore:
                ExploreView()
            case .debug:
                NotificationDebugView()
            }
        }
    }
}
