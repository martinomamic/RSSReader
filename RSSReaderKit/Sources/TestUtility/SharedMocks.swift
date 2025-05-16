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
        let finalURL = url ?? URL(string: urlString)!
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
    
    public static var feedItems: [FeedItem] {
        [
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
}
