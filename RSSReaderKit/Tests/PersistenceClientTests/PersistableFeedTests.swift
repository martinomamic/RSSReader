//
//  PersistableFeedTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 29.04.25.
//

import Testing
import SwiftData
import Foundation

@testable import PersistenceClient
@testable import SharedModels

@Suite struct PersistableFeedTests {
    
    @Test("PersistableFeed init sets properties correctly")
    func testPersistableFeedInit() {
        let url = URL(string: "https://example.com/feed")!
        let title = "Test Feed"
        let description = "Test Description"
        let imageURLString = "https://example.com/image.jpg"
        let isFavorite = true
        let notificationsEnabled = true
        
        let persistableFeed = PersistableFeed(
            title: title,
            url: url,
            feedDescription: description,
            imageURLString: imageURLString,
            isFavorite: isFavorite,
            notificationsEnabled: notificationsEnabled
        )
        
        #expect(persistableFeed.url == url)
        #expect(persistableFeed.title == title)
        #expect(persistableFeed.feedDescription == description)
        #expect(persistableFeed.imageURLString == imageURLString)
        #expect(persistableFeed.isFavorite == isFavorite)
        #expect(persistableFeed.notificationsEnabled == notificationsEnabled)
    }
    
    @Test("PersistableFeed initializes from Feed")
    func testInitFromFeed() {
        let feed = Feed(
            url: URL(string: "https://example.com/feed")!,
            title: "Test Feed",
            description: "Test Description",
            imageURL: URL(string: "https://example.com/image.jpg"),
            isFavorite: true,
            notificationsEnabled: true
        )
        
        let persistableFeed = PersistableFeed(from: feed)
        
        #expect(persistableFeed.url == feed.url)
        #expect(persistableFeed.title == feed.title)
        #expect(persistableFeed.feedDescription == feed.description)
        #expect(persistableFeed.imageURLString == feed.imageURL?.absoluteString)
        #expect(persistableFeed.isFavorite == feed.isFavorite)
        #expect(persistableFeed.notificationsEnabled == feed.notificationsEnabled)
    }
    
    @Test("PersistableFeed converts to Feed correctly")
    func testToFeed() {
        let persistableFeed = PersistableFeed(
            title: "Test Feed",
            url: URL(string: "https://example.com/feed")!,
            feedDescription: "Test Description",
            imageURLString: "https://example.com/image.jpg",
            isFavorite: true,
            notificationsEnabled: true
        )
        
        let feed = persistableFeed.toFeed()
        
        #expect(feed.url == persistableFeed.url)
        #expect(feed.title == persistableFeed.title)
        #expect(feed.description == persistableFeed.feedDescription)
        #expect(feed.imageURL == URL(string: persistableFeed.imageURLString!))
        #expect(feed.isFavorite == persistableFeed.isFavorite)
        #expect(feed.notificationsEnabled == persistableFeed.notificationsEnabled)
    }
    
    @Test("PersistableFeed handles nil values correctly")
    func testNilValues() {
        let url = URL(string: "https://example.com/feed")!
        
        let persistableFeed = PersistableFeed(
            title: nil,
            url: url,
            feedDescription: nil,
            imageURLString: nil,
            isFavorite: false,
            notificationsEnabled: false
        )
        
        #expect(persistableFeed.title == nil)
        #expect(persistableFeed.feedDescription == nil)
        #expect(persistableFeed.imageURLString == nil)
        
        let feed = persistableFeed.toFeed()
        
        #expect(feed.title == nil)
        #expect(feed.description == nil)
        #expect(feed.imageURL == nil)
    }
    
    @Test("Round trip conversion preserves data")
    func testRoundTripConversion() {
        let originalFeed = Feed(
            url: URL(string: "https://example.com/feed")!,
            title: "Test Feed",
            description: "Test Description",
            imageURL: URL(string: "https://example.com/image.jpg"),
            isFavorite: true,
            notificationsEnabled: true
        )
        
        // Feed -> PersistableFeed -> Feed
        let persistableFeed = PersistableFeed(from: originalFeed)
        let roundTripFeed = persistableFeed.toFeed()
        
        #expect(roundTripFeed.url == originalFeed.url)
        #expect(roundTripFeed.title == originalFeed.title)
        #expect(roundTripFeed.description == originalFeed.description)
        #expect(roundTripFeed.imageURL == originalFeed.imageURL)
        #expect(roundTripFeed.isFavorite == originalFeed.isFavorite)
        #expect(roundTripFeed.notificationsEnabled == originalFeed.notificationsEnabled)
    }
}
