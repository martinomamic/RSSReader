//
//  SharedModelsTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 29.04.25.
//

import Testing
import Foundation

@testable import SharedModels

@Suite struct SharedModelsTests {
    @Test("Feed init sets properties correctly")
    func testFeedInit() {
        let url = URL(string: "https://example.com/feed")!
        let title = "Test Feed"
        let description = "Test Description"
        let imageURL = URL(string: "https://example.com/image.jpg")
        let isFavorite = true
        let notificationsEnabled = true
        
        let feed = Feed(
            url: url,
            title: title,
            description: description,
            imageURL: imageURL,
            isFavorite: isFavorite,
            notificationsEnabled: notificationsEnabled
        )
        
        #expect(feed.url == url)
        #expect(feed.title == title)
        #expect(feed.description == description)
        #expect(feed.imageURL == imageURL)
        #expect(feed.isFavorite == isFavorite)
        #expect(feed.notificationsEnabled == notificationsEnabled)
    }
    
    @Test("Feed ID is unique based on properties")
    func testFeedID() {
        let url = URL(string: "https://example.com/feed")!
        
        let feed1 = Feed(url: url, isFavorite: false, notificationsEnabled: false)
        let feed2 = Feed(url: url, isFavorite: true, notificationsEnabled: false)
        let feed3 = Feed(url: url, isFavorite: false, notificationsEnabled: true)
        let feed4 = Feed(url: url, isFavorite: true, notificationsEnabled: true)
        
        // IDs should be different when properties change
        #expect(feed1.id != feed2.id)
        #expect(feed1.id != feed3.id)
        #expect(feed1.id != feed4.id)
        #expect(feed2.id != feed3.id)
        #expect(feed2.id != feed4.id)
        #expect(feed3.id != feed4.id)
        
        // ID should be consistent for the same object
        #expect(feed1.id == feed1.id)
    }
    
    @Test("FeedItem init sets properties correctly")
    func testFeedItemInit() {
        let id = UUID()
        let feedID = UUID()
        let title = "Test Item"
        let link = URL(string: "https://example.com/item")!
        let pubDate = Date()
        let description = "Test Description"
        let imageURL = URL(string: "https://example.com/image.jpg")
        
        let item = FeedItem(
            id: id,
            feedID: feedID,
            title: title,
            link: link,
            pubDate: pubDate,
            description: description,
            imageURL: imageURL
        )
        
        #expect(item.id == id)
        #expect(item.feedID == feedID)
        #expect(item.title == title)
        #expect(item.link == link)
        #expect(item.pubDate == pubDate)
        #expect(item.description == description)
        #expect(item.imageURL == imageURL)
    }
    
    @Test("FeedItem generates new ID when not provided")
    func testFeedItemIDGeneration() {
        let feedID = UUID()
        let title = "Test Item"
        let link = URL(string: "https://example.com/item")!
        
        let item = FeedItem(
            feedID: feedID,
            title: title,
            link: link
        )
        
        #expect(item.id != UUID())
    }
    
    @Test("FeedItem equality works correctly")
    func testFeedItemEquality() {
        let id1 = UUID()
        let id2 = UUID()
        let feedID = UUID()
        
        let item1 = FeedItem(id: id1, feedID: feedID, title: "Test", link: URL(string: "https://example.com")!)
        let item2 = FeedItem(id: id1, feedID: feedID, title: "Test", link: URL(string: "https://example.com")!)
        let item3 = FeedItem(id: id2, feedID: feedID, title: "Test", link: URL(string: "https://example.com")!)
        
        // Same ID should be equal
        #expect(item1 == item2)
        
        // Different ID should not be equal
        #expect(item1 != item3)
    }
    
    @Test("FeedItem optional properties can be nil")
    func testFeedItemOptionalProperties() {
        let feedID = UUID()
        let title = "Test Item"
        let link = URL(string: "https://example.com/item")!
        
        let item = FeedItem(
            feedID: feedID,
            title: title,
            link: link
        )
        
        #expect(item.pubDate == nil)
        #expect(item.description == nil)
        #expect(item.imageURL == nil)
    }
}
