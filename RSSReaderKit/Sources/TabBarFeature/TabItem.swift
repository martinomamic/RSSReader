//
//  TabItem.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 16.04.25.
//

import SwiftUI

public enum TabItem: Int, Hashable, CaseIterable {
    case feeds
    case explore
    case favorites
    case debug
    
    public var title: String {
        switch self {
        case .feeds:
            return "Feeds"
        case .explore:
            return "Explore"
        case .favorites:
            return "Favorites"
        case .debug:
            return "Debug"
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
    
    public var selectedIcon: String {
        switch self {
        case .feeds:
            return "newspaper.fill"
        case .explore:
            return "globe.fill"
        case .favorites:
            return "star.fill"
        case .debug:
            return "ladybug.fill"
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
