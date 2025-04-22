//
//  RssClientDependency.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 22.04.25.
//

import Dependencies
import Foundation
import SharedModels

extension RSSClient: DependencyKey {
    public static var liveValue: RSSClient { RSSClient.live() }

    public static var testValue: RSSClient {
        @Sendable
        func mockFeed(url: URL? = nil) -> Feed {
            return Feed(
                url: url ?? URL(string: "https://test.example.com/feed")!,
                title: "Test Feed",
                description: "This is a test feed for unit testing",
                imageURL: URL(string: "https://test.example.com/image.jpg"),
                isFavorite: false,
                notificationsEnabled: false
            )
        }
        
        let mockItems = [
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
        
        return RSSClient(
            fetchFeed: { url in
                return mockFeed(url: url)
            },
            fetchFeedItems: { _ in
                return mockItems
            }
        )
    }
}

extension DependencyValues {
    public var rssClient: RSSClient {
        get { self[RSSClient.self] }
        set { self[RSSClient.self] = newValue }
    }
}
