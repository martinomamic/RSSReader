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
import TestUtility

@testable import PersistenceClient
@testable import SharedModels

@Suite struct PersistenceClientTests {
    @Dependency(\.persistenceClient) var client

    @Test("Save and load feeds")
    func testSaveAndLoadFeeds() async throws {
        try await withDependencies { _ in
        } operation: {
            let feed1 = SharedMocks.createFeed()
            let feed2 = SharedMocks.createFeed(urlString: "https://example.com/feed2", title: "Test Feed 2")

            try await client.saveFeed(feed1)
            try await client.saveFeed(feed2)

            let loadedFeeds = try await client.loadFeeds()

            #expect(loadedFeeds.count == 2)
            #expect(loadedFeeds.contains(where: { $0.url == feed1.url }))
            #expect(loadedFeeds.contains(where: { $0.url == feed2.url }))
            #expect(loadedFeeds.first(where: { $0.url == feed1.url })?.title == feed1.title)
            #expect(loadedFeeds.first(where: { $0.url == feed2.url })?.title == feed2.title)
        }
    }

    @Test("Update feed")
    func testUpdateFeed() async throws {
        try await withDependencies { _ in }
        operation: {
            let feed = SharedMocks.createFeed(isFavorite: false)
            try await client.saveFeed(feed)

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
            let feed1 = SharedMocks.createFeed()
            let feed2 = SharedMocks.createFeed(urlString: "https://example.com/feed2", title: "Test Feed 2")

            try await client.saveFeed(feed1)
            try await client.saveFeed(feed2)

            var loadedFeeds = try await client.loadFeeds()
            #expect(loadedFeeds.count == 2)

            try await client.deleteFeed(feed1.url)

            loadedFeeds = try await client.loadFeeds()
            #expect(loadedFeeds.count == 1)
            #expect(loadedFeeds[0].url == feed2.url)
        }
    }
}
