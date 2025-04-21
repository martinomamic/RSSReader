//
//  TabBarViewModel.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 16.04.25.
//

import SwiftUI
import Observation

@MainActor
public class TabBarViewModel {
    public var selectedTab: TabItem = .feeds

    public init() {}

    public func getIcon(for tab: TabItem) -> String {
        tab == selectedTab ? tab.selectedIcon : tab.icon
    }

    public func getTitle(for tab: TabItem) -> String {
        return tab.title
    }
}
