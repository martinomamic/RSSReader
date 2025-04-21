//
//  ExploreViewSnapshotTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 21.04.25.
//

import Testing
import SnapshotTesting
import SwiftUI
import Dependencies
import SharedModels
import Common

@testable import ExploreFeature
@testable import ExploreClient

@MainActor
@Suite struct ExploreViewSnapshotTests {
    private func createExploreFeed(
        name: String = "Test Feed",
        url: String = "https://example.com/feed"
    ) -> ExploreFeed {
        ExploreFeed(name: name, url: url)
    }
    
    @Test("ExploreView with feeds")
    func testExploreViewWithFeeds() async throws {
        let feeds = [
            createExploreFeed(name: "BBC News", url: "https://feeds.bbci.co.uk/news/world/rss.xml"),
            createExploreFeed(name: "NBC News", url: "https://feeds.nbcnews.com/nbcnews/public/news"),
            createExploreFeed(name: "Reuters World News", url: "https://feeds.reuters.com/reuters/worldnews")
        ]
        
        withDependencies {
            $0.exploreClient.loadExploreFeeds = { feeds }
            $0.persistenceClient.loadFeeds = { [] }
        } operation: {
            let view = ExploreView()
                .frame(width: 375, height: 600)
            
            assertSnapshot(of: view, as: .image)
        }
    }
    
    @Test("ExploreView with empty state")
    func testExploreViewEmpty() async throws {
        withDependencies {
            $0.exploreClient.loadExploreFeeds = { [] }
        } operation: {
            let view = ExploreView()
                .frame(width: 375, height: 600)
            
            assertSnapshot(of: view, as: .image)
        }
    }
    
    @Test("ExploreView with error state")
    func testExploreViewError() async throws {
        withDependencies {
            $0.exploreClient.loadExploreFeeds = { throw ExploreError.fileNotFound }
        } operation: {
            let view = ExploreView()
                .frame(width: 375, height: 600)
            
            assertSnapshot(of: view, as: .image)
        }
    }
    
    @Test("ExploreFeedRow")
    func testExploreFeedRow() throws {
        let feed = createExploreFeed(name: "BBC News", url: "https://feeds.bbci.co.uk/news/world/rss.xml")
        
        let view = ExploreFeedRow(
            feed: feed,
            isAdded: false,
            onAddTapped: {}
        )
        .frame(width: 375)
        
        assertSnapshot(of: view, as: .image)
    }
    
    @Test("ExploreFeedRow added state")
    func testExploreFeedRowAdded() throws {
        let feed = createExploreFeed(name: "BBC News", url: "https://feeds.bbci.co.uk/news/world/rss.xml")
        
        let view = ExploreFeedRow(
            feed: feed,
            isAdded: true,
            onAddTapped: {}
        )
        .frame(width: 375)
        
        assertSnapshot(of: view, as: .image)
    }
}
