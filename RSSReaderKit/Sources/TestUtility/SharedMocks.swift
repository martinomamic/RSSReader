//
//  SharedMocks.swift
//  RSSReaderKit
//
//  Created by Martino Mamic on 08.05.25.
//

import Foundation
import SharedModels

public enum SharedMocks {
    private static let defaultPubDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    public static func pubDate(from string: String = "09.05.2025") -> Date? {
        defaultPubDateFormatter.date(from: string)
    }
    
    public static func createFeed(
        url: URL? = nil,
        urlString: String = "https://default.example.com/feed",
        title: String = "Default Test Feed",
        description: String? = "Default test description.",
        imageURL: URL? = URL(string: "https://default.example.com/image.jpg"),
        isFavorite: Bool = false,
        notificationsEnabled: Bool = false
    ) -> Feed {
        let finalURL = url ?? URL(string: urlString) ?? URL(string: "https://fallback.example.com/feed")!
        return Feed(
            url: finalURL,
            title: title,
            description: description,
            imageURL: imageURL,
            isFavorite: isFavorite,
            notificationsEnabled: notificationsEnabled
        )
    }
    
    public static func createFeedItem(
        id: UUID = UUID(),
        feedID: UUID = UUID(),
        title: String = "Default Test Item",
        link: URL? = nil,
        linkString: String = "https://default.example.com/item",
        pubDate: Date? = Self.pubDate(),
        description: String? = "Default item description.",
        imageURL: URL? = nil,
        imageURLString: String? = nil
    ) -> FeedItem {
        let finalLink = link ?? URL(string: linkString)!
        let finalImageURL = imageURL ?? (imageURLString != nil ? URL(string: imageURLString!) : nil)
        return FeedItem(
            id: id,
            feedID: feedID,
            title: title,
            link: finalLink,
            pubDate: pubDate,
            description: description,
            imageURL: finalImageURL
        )
    }
    
    public static func createExploreFeed(
        name: String = "Default Explore Feed",
        url: String = "https://default.example.com/explore_feed"
    ) -> ExploreFeed {
        ExploreFeed(name: name, url: url)
    }
    
    public static let sampleExploreFeed1 = ExploreFeed(name: "BBC News", url: "https://feeds.bbci.co.uk/news/world/rss.xml")
    public static let sampleExploreFeed2 = ExploreFeed(name: "NBC News", url: "https://feeds.nbcnews.com/nbcnews/public/news")
    public static let sampleExploreFeed3 = ExploreFeed(name: "Reuters World News", url: "http://feeds.reuters.com/reuters/worldnews")
    
    public static let sampleFeed1: Feed = createFeed(
        urlString: sampleExploreFeed1.url,
        title: sampleExploreFeed1.name,
        description: "Latest news from BBC World."
    )
    
    public static let sampleFeed2: Feed = createFeed(
        urlString: sampleExploreFeed2.url,
        title: sampleExploreFeed2.name,
        description: "Breaking news and top stories from NBC News."
    )
    
    public static let sampleFeed3: Feed =
    createFeed(
        urlString: sampleExploreFeed3.url,
        title: sampleExploreFeed3.name,
        description: "World news from Reuters."
    )
    
    public static let sampleExploreFeeds: [ExploreFeed] = [
        sampleExploreFeed1,
        sampleExploreFeed2,
        sampleExploreFeed3
    ]
    
    public static let sampleFeeds: [Feed] = [
        sampleFeed1,
        sampleFeed2,
        sampleFeed3
    ]
    
    public static let feedItems: [FeedItem] = [
        FeedItem(
            feedID: UUID(),
            title: "Test Item 1",
            link: URL(string: "https://test.example.com/item1")!,
            pubDate: Date(),
            description: "This is test item 1",
            imageURL: URL(string: "https://test.example.com/item1.jpg")
        ),
        FeedItem(
            feedID: UUID(),
            title: "Test Item 2",
            link: URL(string: "https://test.example.com/item2")!,
            pubDate: Date().addingTimeInterval(-3600),
            description: "This is test item 2"
        )
    ]
}
