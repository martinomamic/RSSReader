//
//  Constants.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 14.04.25.
//

import SwiftUI

public enum Constants {
    public enum UI {
        // Feed row
        public static let feedIconSize: CGFloat = 50
        public static let feedRowSpacing: CGFloat = 12
        public static let feedDescriptionLineLimit: Int = 2
        public static let cornerRadius: CGFloat = 6
        public static let verticalPadding: CGFloat = 4
        
        // Feed list
        public static let feedListItemSpacing: CGFloat = 8
        
        // Add feed view
        public static let footerSpacing: CGFloat = 10
        public static let exampleButtonSpacing: CGFloat = 8
        
        // Feed item row
        public static let feedItemSpacing: CGFloat = 8
        public static let feedItemImageHeight: CGFloat = 160
        public static let feedItemCornerRadius: CGFloat = 8
        public static let feedItemVerticalPadding: CGFloat = 6
        public static let feedItemDescriptionLineLimit: Int = 3
    }
    
    public enum URLs {
        public static let bbcNews = "https://feeds.bbci.co.uk/news/world/rss.xml"
        public static let nbcNews = "https://feeds.nbcnews.com/nbcnews/public/news"
    }
    
    public enum Images {
        public static let placeholderFeedIcon = "newspaper.fill"
        public static let loadingIcon = "ellipsis.circle"
        public static let errorIcon = "exclamationmark.triangle"
        public static let placeholderImage = "photo"
        public static let addIcon = "plus"
        public static let noItemsIcon = "tray.fill"
        public static let failedToLoadIcon = "exclamationmark.triangle"
    }
}
