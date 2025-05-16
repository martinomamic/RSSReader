//
//  RSSClientTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 12.04.25.
//

import Testing
import TestUtility
import Foundation
import Dependencies
import SharedModels

@testable import RSSClient

@Suite struct RSSClientTests {
    @Test("RSSClient fetchFeed handles successful case")
    func testFetchFeedSuccess() async throws {
        let expectedFeed = SharedMocks.createFeed(
            urlString: "https://example.com/feed",
            title: "Test Feed",
            description: "Test Description",
            imageURL: URL(string: "https://example.com/image.jpg")
        )

        let client = RSSClient(
            fetchFeed: { _ in expectedFeed },
            fetchFeedItems: { _ in [] }
        )

        let result = try await client.fetchFeed(URL(string: "https://example.com/feed")!)

        #expect(result.url == expectedFeed.url)
        #expect(result.title == expectedFeed.title)
        #expect(result.description == expectedFeed.description)
        #expect(result.imageURL == expectedFeed.imageURL)
    }

    @Test("RSSClient fetchFeed handles error case")
    func testFetchFeedError() async throws {
        let client = RSSClient(
            fetchFeed: { _ in throw RSSError.invalidURL },
            fetchFeedItems: { _ in [] }
        )

        do {
            _ = try await client.fetchFeed(URL(string: "invalid")!)
            #expect(Bool(false), "Expected error")
        } catch let error as RSSError {
            #expect(error.localizedDescription == RSSError.invalidURL.localizedDescription)
        } catch {
            #expect(Bool(false), "Unexpected error type: \(error)")
        }
    }

    @Test("RSSClient fetchFeedItems handles successful case")
    func testFetchFeedItemsSuccess() async throws {
        let feedIDForItems = UUID()
        let expectedItems = [
            SharedMocks.createFeedItem(
                feedID: feedIDForItems,
                title: "Item 1",
                linkString: "https://example.com/item1",
                pubDate: Date(),
                description: "Description 1"
            ),
            SharedMocks.createFeedItem(
                feedID: feedIDForItems,
                title: "Item 2",
                linkString: "https://example.com/item2",
                pubDate: Date(),
                description: "Description 2"
            )
        ]

        let client = RSSClient(
            fetchFeed: { url in SharedMocks.createFeed(url: url) },
            fetchFeedItems: { _ in expectedItems }
        )

        let result = try await client.fetchFeedItems(URL(string: "https://example.com/feed")!)

        #expect(result.count == 2)
        #expect(result[0].title == "Item 1")
        #expect(result[1].title == "Item 2")
    }

    @Test("RSSClient fetchFeedItems handles error case")
    func testFetchFeedItemsError() async throws {
        let networkError = NSError(domain: "test", code: -1)

        let client = RSSClient(
            fetchFeed: { url in Feed(url: url) },
            fetchFeedItems: { _ in throw RSSError.networkError(networkError) }
        )

        do {
            _ = try await client.fetchFeedItems(URL(string: "https://example.com/feed")!)
            #expect(Bool(false), "Expected error")
        } catch let error as RSSError {
            if case .networkError(let underlyingError) = error {
                #expect(underlyingError as NSError == networkError)
            } else {
                #expect(Bool(false), "Expected network error")
            }
        } catch {
            #expect(Bool(false), "Unexpected error type: \(error)")
        }
    }

    @Test("RSSClient testValue provides realistic mock implementation")
    func testDefaultTestValue() async throws {
        let client = RSSClient.testValue

        let testURL = URL(string: "https://custom.example.com")!
        let feed = try await client.fetchFeed(testURL)

        #expect(feed.url == testURL)
        #expect(feed.title == "Test Feed")
        #expect(feed.description == "This is a test feed for unit testing")
        #expect(feed.imageURL == URL(string: "https://test.example.com/image.jpg"))
        #expect(feed.isFavorite == false)
        #expect(feed.notificationsEnabled == false)

        let items = try await client.fetchFeedItems(testURL)

        #expect(items.count == 2)
        #expect(items[0].title == "Test Item 1")
        #expect(items[0].link == URL(string: "https://test.example.com/item1")!)
        #expect(items[0].description == "This is test item 1")
        #expect(items[0].imageURL == URL(string: "https://test.example.com/item1.jpg"))

        #expect(items[1].title == "Test Item 2")
        #expect(items[1].link == URL(string: "https://test.example.com/item2")!)
        #expect(items[1].description == "This is test item 2")
        #expect(items[1].imageURL == nil)
    }
}
