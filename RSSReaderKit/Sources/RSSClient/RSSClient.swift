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
