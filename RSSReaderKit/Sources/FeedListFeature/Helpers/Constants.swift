//
//  Constants.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 14.04.25.
//

import SwiftUI

enum Constants {
    enum UI {
        // Feed view
        static let feedIconSize: CGFloat = 50
        static let feedRowSpacing: CGFloat = 12
        static let feedDescriptionLineLimit: Int = 2
        static let cornerRadius: CGFloat = 6
        static let verticalPadding: CGFloat = 4
        
        // Feed list
        static let feedListItemSpacing: CGFloat = 8
        
        // Add feed view
        static let footerSpacing: CGFloat = 10
        static let exampleButtonSpacing: CGFloat = 8
    }
    
    enum URLs {
        static let bbcNews = "https://feeds.bbci.co.uk/news/world/rss.xml"
        static let nbcNews = "https://feeds.nbcnews.com/nbcnews/public/news"
    }
    
    enum Images {
        static let defaultFeedIcon = "newspaper.fill"
        static let loadingIcon = "ellipsis.circle"
        static let errorIcon = "exclamationmark.triangle"
        static let placeholderImage = "photo"
        static let addIcon = "plus"
    }
}
