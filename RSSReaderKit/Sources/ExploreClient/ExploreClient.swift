//
//  ExploreClient.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 18.04.25.
//

import Foundation
import Dependencies
import SharedModels

public struct ExploreClient: Sendable {
    public var loadExploreFeeds: @Sendable () async throws -> [ExploreFeed]
    public var addFeed: @Sendable (ExploreFeed) async throws -> Feed

    public init(
        loadExploreFeeds: @escaping @Sendable () async throws -> [ExploreFeed],
        addFeed: @escaping @Sendable (ExploreFeed) async throws -> Feed
    ) {
        self.loadExploreFeeds = loadExploreFeeds
        self.addFeed = addFeed
    }
}
