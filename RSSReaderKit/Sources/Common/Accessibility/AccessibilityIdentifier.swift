import SwiftUI

public enum AccessibilityIdentifier {
    public enum TabBar {
        public static let navigationTabs = "navigationTabs"
        public static let feedsTab = "feedsTab"
        public static let favoritesTab = "favoritesTab"
        public static let exploreTab = "exploreTab"
        public static let debugTab = "debugTab"
    }
    
    public enum FeedList {
        public static let addFeedButton = "addFeedButton"
        public static let editButton = "editButton"
        public static let feedsList = "feedsList"
        public static let favoritesList = "favoritesList"
    }
    
    public enum FeedView {
        public static let loadingView = "loadingFeedView"
        public static let feedTitle = "feedTitle"
        public static let feedDescription = "feedDescription"
        public static let notificationsButton = "notificationsButton"
        public static let favoriteButton = "favoriteButton"
        public static let errorView = "feedErrorView"
    }
    
    public enum AddFeed {
        public static let urlTextField = "feedUrlTextField"
        public static let bbcExampleButton = "bbcExampleButton"
        public static let nbcExampleButton = "nbcExampleButton"
        public static let cancelButton = "cancelButton"
        public static let addButton = "addButton"
    }
    
    public enum FeedItems {
        public static let itemTitle = "feedItemTitle"
        public static let itemDescription = "itemDescription"
        public static let itemDate = "itemDate"
        public static let loadingView = "loadingItemsView"
        public static let itemsList = "feedItemsList"
        public static let errorView = "feedItemsErrorView"
        public static let emptyView = "feedItemsEmptyView"
    }
    
    public enum Explore {
        public static let addButton = "addExploreFeedButton"
        public static let loadingView = "loadingExploreView"
        public static let emptyView = "exploreEmptyView"
        public static let errorView = "exploreErrorView"
        public static let feedsList = "exploreFeedsList"
        public static let feedRow = "exploreFeedRow"
    }
    
    public enum Debug {
        public static let statusButton = "debugStatusButton"
        public static let permissionsButton = "debugPermissionsButton"
        public static let delayedNotificationButton = "debugDelayedNotificationButton"
        public static let refreshButton = "debugRefreshButton"
        public static let parseButton = "debugParseButton"
    }
}
