//
//  PersistenceClientTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 15.04.25.
//

import ConcurrencyExtras
import Dependencies
import Foundation
import Testing
@testable import PersistenceClient
@testable import SharedModels

@Suite struct PersistenceClientTests {
    @Dependency(\.persistenceClient) var client

    func createTestFeed(
        url: String = "https://example.com/feed",
        title: String = "Test Feed",
        description: String = "Test Description",
        isFavorite: Bool = false
    ) -> Feed {
        return Feed(
            url: URL(string: url)!,
            title: title,
            description: description,
            isFavorite: isFavorite
        )
    }

    @Test("Save and load feeds")
    func testSaveAndLoadFeeds() async throws {
        try await withDependencies { _ in
        } operation: {
            let feed1 = createTestFeed()
            let feed2 = createTestFeed(url: "https://example.com/feed2", title: "Test Feed 2")

            try await client.addFeed(feed1)
            try await client.addFeed(feed2)

            let loadedFeeds = try await client.loadFeeds()

            #expect(loadedFeeds.count == 2)
            #expect(loadedFeeds.contains(where: { $0.url == feed1.url }))
            #expect(loadedFeeds.contains(where: { $0.url == feed2.url }))
            #expect(loadedFeeds.first(where: { $0.url == feed1.url })?.title == "Test Feed")
            #expect(loadedFeeds.first(where: { $0.url == feed2.url })?.title == "Test Feed 2")
        }
    }

    @Test("Update feed")
    func testUpdateFeed() async throws {
        try await withDependencies { _ in }
        operation: {
            let feed = createTestFeed(isFavorite: false)
            try await client.addFeed(feed)

            var loadedFeeds = try await client.loadFeeds()
            #expect(loadedFeeds.count == 1)
            #expect(loadedFeeds[0].isFavorite == false)

            var updatedFeed = feed
            updatedFeed.isFavorite = true
            try await client.updateFeed(updatedFeed)

            loadedFeeds = try await client.loadFeeds()
            #expect(loadedFeeds.count == 1)
            #expect(loadedFeeds[0].isFavorite == true)
        }
    }

    @Test("Delete feed")
    func testDeleteFeed() async throws {
        try await withDependencies { _ in }
        operation: {
            let feed1 = createTestFeed()
            let feed2 = createTestFeed(url: "https://example.com/feed2", title: "Test Feed 2")

            try await client.addFeed(feed1)
            try await client.addFeed(feed2)

            var loadedFeeds = try await client.loadFeeds()
            #expect(loadedFeeds.count == 2)

            try await client.deleteFeed(feed1.url)

            loadedFeeds = try await client.loadFeeds()
            #expect(loadedFeeds.count == 1)
            #expect(loadedFeeds[0].url == feed2.url)
        }
    }
}
