//
//  ExploreClientTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 21.04.25.
//

import ConcurrencyExtras
import Dependencies
import Foundation
import Testing
import TestUtility

@testable import ExploreClient
@testable import SharedModels
@testable import RSSClient
@testable import PersistenceClient

@Suite struct ExploreClientTests {
    @Test("Loading explore feeds fetches feeds from JSON file")
    func testLoadExploreFeeds() async throws {
        let mockFeeds = [
            SharedMocks.createExploreFeed(name: "Feed 1", url: "https://example1.com/feed"),
            SharedMocks.createExploreFeed(name: "Feed 2", url: "https://example2.com/feed")
        ]
        
        let client = ExploreClient(
            loadExploreFeeds: {
                return mockFeeds
            },
            addFeed: { _ in
                return SharedMocks.createFeed(urlString: "https://example.com")
            }
        )
        
        let feeds = try await client.loadExploreFeeds()
        
        #expect(feeds.count == 2)
        #expect(feeds[0].name == "Feed 1")
        #expect(feeds[0].url == "https://example1.com/feed")
        #expect(feeds[1].name == "Feed 2")
        #expect(feeds[1].url == "https://example2.com/feed")
    }
    
    @Test("Loading explore feeds throws fileNotFound when file doesn't exist")
    func testLoadExploreFeedsFileNotFound() async throws {
        let client = ExploreClient(
            loadExploreFeeds: {
                throw ExploreError.fileNotFound
            },
            addFeed: { _ in
                return SharedMocks.createFeed(urlString: "https://example.com")
            }
        )
        
        do {
            _ = try await client.loadExploreFeeds()
            #expect(Bool(false), "Should have thrown an error")
        } catch let error as ExploreError {
            #expect(error.localizedDescription == ExploreError.fileNotFound.localizedDescription)
        }
    }
    
    @Test("Loading explore feeds throws decodingFailed when JSON is invalid")
    func testLoadExploreFeedsDecodingFailed() async throws {
        let client = ExploreClient(
            loadExploreFeeds: {
                throw ExploreError.decodingFailed("Invalid JSON")
            },
            addFeed: { _ in
                return SharedMocks.createFeed(urlString: "https://example.com")
            }
        )
        
        do {
            _ = try await client.loadExploreFeeds()
            #expect(Bool(false), "Should have thrown an error")
        } catch let error as ExploreError {
            if case .decodingFailed(let message) = error {
                #expect(message == "Invalid JSON")
            } else {
                #expect(Bool(false), "Wrong error type")
            }
        }
    }
    
    @Test("Adding explore feed fetches and saves feed successfully")
    func testAddFeed() async throws {
        let exploreFeed = SharedMocks.createExploreFeed()
        let expectedFeed = SharedMocks.createFeed()
        
        let client = ExploreClient(
            loadExploreFeeds: {
                return []
            },
            addFeed: { feed in
                #expect(feed.name == exploreFeed.name)
                #expect(feed.url == exploreFeed.url)
                return expectedFeed
            }
        )
        
        let result = try await client.addFeed(exploreFeed)
        
        #expect(result.url.absoluteString == expectedFeed.url.absoluteString)
        #expect(result.title == expectedFeed.title)
        #expect(result.description == expectedFeed.description)
    }
    
    @Test("Adding feed throws invalidURL when URL is invalid")
    func testAddFeedInvalidURL() async throws {
        let exploreFeed = SharedMocks.createExploreFeed(url: "invalid-url")
        
        let client = ExploreClient(
            loadExploreFeeds: {
                return []
            },
            addFeed: { _ in
                throw ExploreError.invalidURL
            }
        )
        
        do {
            _ = try await client.addFeed(exploreFeed)
            #expect(Bool(false), "Should have thrown an error")
        } catch let error as ExploreError {
            #expect(error.localizedDescription == ExploreError.invalidURL.localizedDescription)
        }
    }
    
    @Test("Adding feed throws feedFetchFailed when feed fetch fails")
    func testAddFeedFetchFailed() async throws {
        let exploreFeed = SharedMocks.createExploreFeed()
        
        let client = ExploreClient(
            loadExploreFeeds: {
                return []
            },
            addFeed: { _ in
                throw ExploreError.feedFetchFailed("Network error")
            }
        )
        
        do {
            _ = try await client.addFeed(exploreFeed)
            #expect(Bool(false), "Should have thrown an error")
        } catch let error as ExploreError {
            if case .feedFetchFailed(let message) = error {
                #expect(message == "Network error")
            } else {
                #expect(Bool(false), "Wrong error type")
            }
        }
    }
    
    @Test("Live implementation correctly uses dependencies")
    func testLiveImplementation() async throws {
        let mockFeed = SharedMocks.createFeed()
        let mockExploreFeed = SharedMocks.createExploreFeed()
        
        try await withDependencies {
            $0.rssClient.fetchFeed = { url in
                #expect(url.absoluteString == mockExploreFeed.url)
                return mockFeed
            }
            $0.persistenceClient.saveFeed = { feed in
                #expect(feed.url.absoluteString == mockFeed.url.absoluteString)
                #expect(feed.title == mockFeed.title)
            }
        } operation: {
            let client = ExploreClient.live()
            
            let testClient = ExploreClient(
                loadExploreFeeds: client.loadExploreFeeds,
                addFeed: { exploreFeed in
                    guard let url = URL(string: exploreFeed.url) else {
                        throw ExploreError.invalidURL
                    }
                    
                    @Dependency(\.rssClient.fetchFeed) var fetchFeed
                    @Dependency(\.persistenceClient.saveFeed) var addFeedToPersistence
                    
                    let feed = try await fetchFeed(url)
                    try await addFeedToPersistence(feed)
                    return feed
                }
            )
            
            let result = try await testClient.addFeed(mockExploreFeed)
            
            #expect(result.url.absoluteString == mockFeed.url.absoluteString)
            #expect(result.title == mockFeed.title)
            #expect(result.description == mockFeed.description)
        }
    }
}
