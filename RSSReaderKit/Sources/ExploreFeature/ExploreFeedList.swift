//
//  ExploreFeedList.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 18.04.25.
//

public struct ExploreFeedList: Codable {
    public let feeds: [ExploreFeed]
    
    public init(feeds: [ExploreFeed]) {
        self.feeds = feeds
    }
}
