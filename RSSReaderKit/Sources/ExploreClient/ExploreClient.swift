//
//  ExploreClient.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 18.04.25.
//

import Foundation
import Dependencies

public struct ExploreClient: Sendable {
    public var loadExploreFeeds: @Sendable () async throws -> [ExploreFeed]
    
    public init(
        loadExploreFeeds: @escaping @Sendable () async throws -> [ExploreFeed]
    ) {
        self.loadExploreFeeds = loadExploreFeeds
    }
}
