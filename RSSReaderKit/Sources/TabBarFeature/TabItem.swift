//
//  TabItem.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 16.04.25.
//

import SwiftUI
import Common

public enum TabItem: Int, Hashable, CaseIterable {
    case feeds
    case explore
    case favorites
    case debug

    public var title: String {
        switch self {
        case .feeds:
            return LocalizedStrings.TabBar.feeds
        case .explore:
            return LocalizedStrings.TabBar.explore
        case .favorites:
            return LocalizedStrings.TabBar.favorites
        case .debug:
            return LocalizedStrings.TabBar.debug
        }
    }

    public var icon: String {
        switch self {
        case .feeds:
            return "newspaper"
        case .explore:
            return "globe"
        case .favorites:
            return "star"
        case .debug:
            return "ladybug"
        }
    }

    public static var allCases: [TabItem] {
        #if DEBUG
        return [.feeds, .favorites, .explore, .debug]
        #else
        return [.feeds, .favorites, .explore]
        #endif
    }
}

#Preview {
    ForEach(TabItem.allCases, id: \.self) { item in
        Text(item.title)
    }
}
