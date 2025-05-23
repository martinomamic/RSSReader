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
import NotificationRepository

public struct TabBarView: View {
    @State private var selectedTab: TabItem = .feeds
    @State private var favoriteFeedsViewModel = FavoriteFeedsViewModel()
    @State private var allFeedsViewModel = AllFeedsViewModel()
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                tabContent(for: tab)
                    .tabItem {
                        Label(
                            tab.title,
                            systemImage: tab.icon
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
                FeedListView(viewModel: allFeedsViewModel)
            case .favorites:
                FeedListView(viewModel: favoriteFeedsViewModel)
            case .explore:
                ExploreView()
            case .debug:
                NotificationDebugView()
            }
        }
    }
}
