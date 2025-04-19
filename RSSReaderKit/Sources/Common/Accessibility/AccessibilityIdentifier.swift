import SwiftUI

public enum AccessibilityIdentifier {
    public enum TabBar {
        public static let navigationTabs = "navigationTabs"
    }
    
    public enum FeedList {
        public static let addFeedButton = "addFeedButton"
    }
    
    public enum FeedView {
        public static let loadingView = "loadingFeedView"
    }
    
    public enum AddFeed {
        public static let urlTextField = "feedUrlTextField"
    }
    
    public enum FeedItems {
        public static let itemTitle = "feedItemTitle"
        public static let loadingView = "loadingItemsView"
    }
    
    public enum Explore {
        public static let addButton = "addExploreFeedButton"
        public static let loadingView = "loadingExploreView"
    }
}
