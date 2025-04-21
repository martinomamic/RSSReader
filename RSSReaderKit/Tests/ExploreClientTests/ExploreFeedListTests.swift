//
//  ExploreFeedListTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 21.04.25.
//

import Testing
import Foundation

@testable import SharedModels

@Suite struct ExploreFeedListTests {
    
    @Test("ExploreFeedList can be encoded and decoded")
    func testExploreFeedListCoding() throws {
        let feeds = [
            ExploreFeed(name: "Feed 1", url: "https://example1.com/feed"),
            ExploreFeed(name: "Feed 2", url: "https://example2.com/feed")
        ]
        
        let feedList = ExploreFeedList(feeds: feeds)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(feedList)
        
        let decoder = JSONDecoder()
        let decodedFeedList = try decoder.decode(ExploreFeedList.self, from: data)
        
        #expect(decodedFeedList.feeds.count == 2)
        #expect(decodedFeedList.feeds[0].name == "Feed 1")
        #expect(decodedFeedList.feeds[0].url == "https://example1.com/feed")
        #expect(decodedFeedList.feeds[1].name == "Feed 2")
        #expect(decodedFeedList.feeds[1].url == "https://example2.com/feed")
    }
    
    @Test("ExploreFeed identifiable property works correctly")
    func testExploreFeedIdentifiable() {
        let feed = ExploreFeed(name: "Test Feed", url: "https://example.com/feed")
        
        #expect(feed.id == "https://example.com/feed")
    }
    
    @Test("ExploreFeedList initialization works properly")
    func testExploreFeedListInitialization() {
        let feeds = [
            ExploreFeed(name: "Feed 1", url: "https://example1.com/feed"),
            ExploreFeed(name: "Feed 2", url: "https://example2.com/feed")
        ]
        
        let feedList = ExploreFeedList(feeds: feeds)
        
        #expect(feedList.feeds.count == 2)
        #expect(feedList.feeds[0].name == "Feed 1")
        #expect(feedList.feeds[1].name == "Feed 2")
    }
    
    @Test("ExploreFeedList with empty feeds array works properly")
    func testExploreFeedListEmpty() {
        let feedList = ExploreFeedList(feeds: [])
        
        #expect(feedList.feeds.isEmpty)
    }
}
