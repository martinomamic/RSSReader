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
    
    public var title: String {
        switch self {
        case .feeds:
            return "Feeds"
        case .explore:
            return "Explore"
        case .favorites:
            return "Favorites"
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
        }
    }
    
    public static var allCases: [TabItem] {
        return [.feeds, .explore, .favorites]
    }
}
#Preview {
    ForEach(TabItem.allCases, id: \.self) { item in
        Text(item.title)
    }
}