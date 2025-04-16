//
//  TabItem.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 16.04.25.
//

import SwiftUI

public enum TabItem: Int, Hashable, CaseIterable {
    case feeds
    case favorites
    
    public var title: String {
        switch self {
        case .feeds:
            return "Feeds"
        case .favorites:
            return "Favorites"
        }
    }
    
    public var icon: String {
        switch self {
        case .feeds:
            return "newspaper"
        case .favorites:
            return "star"
        }
    }
    
    public var selectedIcon: String {
        switch self {
        case .feeds:
            return "newspaper.fill"
        case .favorites:
            return "star.fill"
        }
    }
}
