//
//  LocalizedStrings.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 18.04.25.
//

public enum LocalizedStrings {
    public enum FeedItems {
        public static let noItemsTitle = String(localized: "feed_items_no_items_title")
        public static let noItemsDescription = String(localized: "feed_items_no_items_description")
    }
    
    public enum LoadingStates {
        public static let loading = String(localized: "loading")
    }
    
    public enum TabBar {
        public static let feeds = String(localized: "tab_feeds")
        public static let explore = String(localized: "tab_explore")
        public static let favorites = String(localized: "tab_favorites")
        public static let debug = String(localized: "tab_debug")
    }
    
    public enum Explore {
        public static let title = String(localized: "explore_title")
        public static let noFeedsTitle = String(localized: "explore_no_feeds_title")
        public static let noFeedsDescription = String(localized: "explore_no_feeds_description")
        public static let errorAddingFeed = String(localized: "explore_error_adding_feed")
    }
    
    public enum AddFeed {
        public static let title = String(localized: "add_feed_title")
        public static let urlPlaceholder = String(localized: "add_feed_url_placeholder")
        public static let urlHeader = String(localized: "add_feed_url_header")
        public static let examplesHeader = String(localized: "add_feed_examples_header")
        public static let bbcNews = String(localized: "add_feed_example_bbc")
        public static let nbcNews = String(localized: "add_feed_example_nbc")
        public static let errorTitle = String(localized: "add_feed_error_title")
    }

    public enum ExploreFeed {
        public static let add = String(localized: "explore_feed_add")
        public static let added = String(localized: "explore_feed_added")
    }

    public enum EmptyState {
        public static let defaultTitle = String(localized: "empty_state_default_title")
        public static let defaultDescription = String(localized: "empty_state_default_description")
        public static let defaultActionLabel = String(localized: "empty_state_default_action")
    }

    public enum ErrorState {
        public static let title = String(localized: "error_state_title")
        public static let tryAgain = String(localized: "error_state_try_again")
    }

    public enum Feed {
        public static let loadingDetails = String(localized: "feed_loading_details")
        public static let unnamedFeed = String(localized: "feed_unnamed")
        public static let failedToLoad = String(localized: "feed_failed_to_load")
        public static let noDataAvailable = String(localized: "feed_no_data_available")
    }

    public enum FeedList {
        public static let favoriteFeeds = String(localized: "feed_list_favorite_feeds")
        public static let rssFeeds = String(localized: "feed_list_rss_feeds")
        public static let addFeed = String(localized: "feed_list_add_feed")
        public static let edit = String(localized: "feed_list_edit")
        public static let noFavorites = String(localized: "feed_list_no_favorites_title")
        public static let noFeeds = String(localized: "feed_list_no_feeds_title")
        public static let noFavoritesDescription = String(localized: "feed_list_no_favorites_description")
        public static let noFeedsDescription = String(localized: "feed_list_no_feeds_description")
        public static let unnamedFeed = String(localized: "feed_list_unnamed_feed")
    }
    
    public enum General {
        public static let ok = String(localized: "general_ok")
        public static let cancel = String(localized: "general_cancel")
        public static let add = String(localized: "general_add")
    }
}
