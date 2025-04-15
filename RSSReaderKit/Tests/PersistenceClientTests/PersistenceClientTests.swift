//
//  PersistenceClientTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 15.04.25.
//

import ConcurrencyExtras
import Foundation
import Testing
@testable import PersistenceClient
@testable import SharedModels

@Suite struct PersistenceClientTests {
    @Test("Save and load feeds")
    func testSaveAndLoadFeeds() async throws {
        let feedStore = LockIsolated<[Feed]>([])
        
        let testClient = PersistenceClient(
            saveFeeds: { feeds in
                feedStore.setValue(feeds)
            },
            loadFeeds: {
                return feedStore.value
            }
        )
        
        let feed1 = Feed(
            url: URL(string: "https://example.com/feed1")!,
            title: "Test Feed 1",
            description: "Description 1"
        )
        
        let feed2 = Feed(
            url: URL(string: "https://example.com/feed2")!,
            title: "Test Feed 2",
            description: "Description 2"
        )
        
        try await testClient.saveFeeds([feed1, feed2])
        
        let loadedFeeds = try await testClient.loadFeeds()
        
        #expect(loadedFeeds.count == 2)
        #expect(loadedFeeds[0].title == "Test Feed 1")
        #expect(loadedFeeds[1].title == "Test Feed 2")
    }
    
    @Test("Delete feed")
    func testDeleteFeed() async throws {
        let feed1 = Feed(
            id: UUID(),
            url: URL(string: "https://example.com/feed1")!,
            title: "Test Feed 1"
        )
        
        let feed2 = Feed(
            id: UUID(),
            url: URL(string: "https://example.com/feed2")!,
            title: "Test Feed 2"
        )
        
        let feedStore = LockIsolated<[Feed]>([feed1, feed2])
        
        let testClient = PersistenceClient(
            saveFeeds: { feeds in
                feedStore.setValue(feeds)
            },
            loadFeeds: {
                return feedStore.value
            }
        )
        
        var loadedFeeds = try await testClient.loadFeeds()
        #expect(loadedFeeds.count == 2)
        
        loadedFeeds.removeAll(where: { $0.id == feed1.id })
        try await testClient.saveFeeds(loadedFeeds)
        
        let remainingFeeds = try await testClient.loadFeeds()
        #expect(remainingFeeds.count == 1)
        #expect(remainingFeeds[0].id == feed2.id)
    }
}
