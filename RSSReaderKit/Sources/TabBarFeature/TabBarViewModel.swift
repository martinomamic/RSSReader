//
//  TabBarViewModel.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 16.04.25.
//


import SwiftUI
import Observation

@Observable
public class TabBarViewModel {
    public var selectedTab: TabItem = .feeds
    
    public var feedsPath = NavigationPath()
    public var favoritesPath = NavigationPath()
    
    public init() {}
    
    public func selectTab(_ tab: TabItem) {
        if selectedTab == tab {
            resetTab(tab)
        }
        selectedTab = tab
    }
    
    public func resetTab(_ tab: TabItem) {
        var path = navigationPath(for: tab)
        guard path.isEmpty else { return }
        path.removeLast(path.count)
    }
    
    public func resetAllTabs() {
        feedsPath.removeLast(feedsPath.count)
        favoritesPath.removeLast(favoritesPath.count)
    }
    
    public func navigationPath(for tab: TabItem) -> NavigationPath {
        switch tab {
        case .feeds:
            return feedsPath
        case .favorites:
            return favoritesPath
        }
    }
}
