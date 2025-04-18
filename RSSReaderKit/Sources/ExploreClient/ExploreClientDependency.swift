//
//  ExploreClientDependency.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 18.04.25.
//

import Dependencies
import Foundation
import SharedModels

extension ExploreClient: DependencyKey {
    public static var liveValue: ExploreClient { .live() }
    
    public static var testValue: ExploreClient {
        ExploreClient(
            loadExploreFeeds: {
                [
                    ExploreFeed(name: "Test Feed", url: "https://example.com/feed"),
                    ExploreFeed(name: "Another Feed", url: "https://example.org/rss")
                ]
            },
            addFeed: { exploreFeed in
                guard let url = URL(string: exploreFeed.url) else {
                    throw ExploreError.invalidURL
                }
                
                return Feed(
                    url: url,
                    title: exploreFeed.name,
                    description: "Test feed description"
                )
            }
        )
    }
}

extension DependencyValues {
    public var exploreClient: ExploreClient {
        get { self[ExploreClient.self] }
        set { self[ExploreClient.self] = newValue }
    }
}
