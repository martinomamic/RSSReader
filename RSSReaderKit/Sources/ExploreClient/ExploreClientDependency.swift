//
//  ExploreClientDependency.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 18.04.25.
//

import Dependencies

extension ExploreClient: DependencyKey {
    public static var liveValue: ExploreClient { .live() }
    
    public static var testValue: ExploreClient {
        ExploreClient(loadExploreFeeds: {
            [
                ExploreFeed(name: "Test Feed", url: "https://example.com/feed", category: "Test"),
                ExploreFeed(name: "Another Feed", url: "https://example.org/rss", category: "Test")
            ]
        })
    }
}

extension DependencyValues {
    public var ExploreClient: ExploreClient {
        get { self[ExploreClient.self] }
        set { self[ExploreClient.self] = newValue }
    }
}
