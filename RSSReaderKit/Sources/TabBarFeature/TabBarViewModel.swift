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
    
    private var resetFeedsTrigger = false
    private var resetFavoritesTrigger = false
    
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
        if !path.isEmpty {
            path.removeLast(path.count)
        } else {
            toggleResetTrigger(for: tab)
        }
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
    
    public func resetTrigger(for tab: TabItem) -> Bool {
        switch tab {
        case .feeds:
            return resetFeedsTrigger
        case .favorites:
            return resetFavoritesTrigger
        }
    }
    
    private func toggleResetTrigger(for tab: TabItem) {
        switch tab {
        case .feeds:
            resetFeedsTrigger.toggle()
        case .favorites:
            resetFavoritesTrigger.toggle()
        }
    }
}
