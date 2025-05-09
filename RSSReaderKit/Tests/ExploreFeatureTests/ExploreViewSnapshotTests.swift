//
//  ExploreViewSnapshotTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 21.04.25.
//

import Testing
import SnapshotTestUtility
import SwiftUI
import Dependencies
import SharedModels
import Common

@testable import ExploreFeature

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
            let viewModel = ExploreViewModel()
            viewModel.state = .content(feeds)
            
            let view = ExploreView()
            
            assertSnapshot(
                view: view,
                named: "ExploreWithFeeds"
            )
            
            assertSnapshot(
                view: view,
                accessibility: .XXXL,
                named: "ExploreWithFeeds"
            )
        }
    }
    
    @Test("ExploreView with empty state")
    func testExploreViewEmpty() async throws {
        withDependencies {
            $0.exploreClient.loadExploreFeeds = { [] }
        } operation: {
            let viewModel = ExploreViewModel()
            viewModel.state = .empty
            
            let view = ExploreView()
            
            assertSnapshot(
                view: view,
                named: "ExploreEmpty"
            )
        }
    }
    
    @Test("ExploreView with error state")
    func testExploreViewError() async throws {
        withDependencies {
            $0.exploreClient.loadExploreFeeds = { throw AppError.unknown("File not found") }
        } operation: {
            let viewModel = ExploreViewModel()
            viewModel.state = .error(AppError.general)
            
            let view = ExploreView()
            
            assertSnapshot(
                view: view,
                named: "ExploreError"
            )
        }
    }
    
    @Test("ExploreView in loading state")
    func testExploreViewLoading() async throws {
        withDependencies {
            $0.exploreClient = .testValue
        } operation: {
            let viewModel = ExploreViewModel()
            viewModel.state = .loading
            
            let view = ExploreView()
            
            assertSnapshot(
                view: view,
                named: "ExploreLoading"
            )
        }
    }
}
