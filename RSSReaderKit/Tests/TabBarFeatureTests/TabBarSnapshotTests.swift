//
//  TabBarSnapshotTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 30.04.25.
//

import Testing
import SnapshotTesting
import SwiftUI
import Common

@testable import TabBarFeature

@MainActor
@Suite struct TabBarSnapshotTests {
    @Test("TabBarView shows correct tabs")
    func testTabBarView() async throws {
        let tabBarView = TabBarView()
            .frame(width: 375, height: 600)
        
        assertSnapshot(of: tabBarView, as: .image)
    }
    
    @Test("TabBarView with selected Explore tab")
    func testTabBarViewSelectedExplore() async throws {
        let tabBarView = TestableTabBarView(selectedTab: .explore)
            .frame(width: 375, height: 600)
        
        assertSnapshot(of: tabBarView, as: .image)
    }
    
    @Test("TabBarView with selected Favorites tab")
    func testTabBarViewSelectedFavorites() async throws {
        let tabBarView = TestableTabBarView(selectedTab: .favorites)
            .frame(width: 375, height: 600)
        
        assertSnapshot(of: tabBarView, as: .image)
    }
    
    @Test("TabBarView with selected Debug tab")
    func testTabBarViewSelectedDebug() async throws {
        let tabBarView = TestableTabBarView(selectedTab: .debug)
            .frame(width: 375, height: 600)
        
        assertSnapshot(of: tabBarView, as: .image)
    }
}

struct TestableTabBarView: View {
    @State private var selectedTab: TabItem
    
    init(selectedTab: TabItem) {
        self._selectedTab = State(initialValue: selectedTab)
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                Text("Mock \(tab.title) Content")
                    .tabItem {
                        Label(
                            tab.title,
                            systemImage: tab.icon
                        )
                        .accessibilityIdentifier("tab\(tab.title)")
                    }
                    .tag(tab)
            }
        }
        .testId(AccessibilityIdentifier.TabBar.navigationTabs)
    }
}
