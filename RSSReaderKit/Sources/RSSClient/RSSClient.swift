//
//  RSSClient.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 12.04.25.
//

import Foundation
import SharedModels
import Dependencies

public struct RSSClient: Sendable {
    public var fetchFeed: @Sendable (URL) async throws -> Feed
    public var fetchFeedItems: @Sendable (URL) async throws -> [FeedItem]

    public init(
        fetchFeed: @escaping @Sendable (URL) async throws -> Feed,
        fetchFeedItems: @escaping @Sendable (URL) async throws -> [FeedItem]
    ) {
        self.fetchFeed = fetchFeed
        self.fetchFeedItems = fetchFeedItems
    }
}

extension RSSClient: DependencyKey {
    public static var liveValue: RSSClient { RSSClient.live() }

    public static var testValue: RSSClient {
        return RSSClient(
            fetchFeed: { url in
                return Feed(
                    url: url,
                    title: "",
                    description: ""
                )
            },
            fetchFeedItems: { _ in
                return [
                    FeedItem(
                        feedID: UUID(),
                        title: "",
                        link: URL(string: "")!,
                        description: ""
                    )
                ]
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
