//
//  AddFeedViewModelTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 21.04.25.
//

import Testing
import Foundation
import Dependencies
import SharedModels
import PersistenceClient
import RSSClient
import Common
import SwiftUI

@testable import FeedListFeature

@Suite struct AddFeedViewModelTests {
    @MainActor
    func createViewModel(
        with feeds: [FeedViewModel] = [],
        urlString: String = Constants.URLs.bbcNews,
        state: AddFeedState = .idle) -> AddFeedViewModel {
            let viewModel = AddFeedViewModel(feeds: Binding.constant(feeds))
            viewModel.urlString = urlString
            viewModel.state = state
            return viewModel
        }
    
    @Test("Test add button disabled with empty URL")
    func testAddButtonDisabled() async throws {
        var viewModel = await createViewModel()
        
        await #expect(viewModel.isAddButtonDisabled == false)
        
        viewModel = await createViewModel(urlString: "")
        await #expect(viewModel.isAddButtonDisabled == true)
    }
    
    @Test("Test example URL setting")
    func testSetExampleURL() async throws {
        let viewModel = await createViewModel()
        
        await viewModel.setExampleURL(.bbc)
        await #expect(viewModel.urlString == Constants.URLs.bbcNews)
        
        await viewModel.setExampleURL(.nbc)
        await #expect(viewModel.urlString == Constants.URLs.nbcNews)
    }
    
    @Test("Test duplicate feed error")
    func testAddDuplicateFeed() async throws {
        let mockFeed = Feed(
            url: URL(string: Constants.URLs.bbcNews)!,
            title: "BBC News",
            description: "Latest news from BBC"
        )
        
        let feeds = await [FeedViewModel(url: mockFeed.url, feed: mockFeed)]
        let viewModel = await createViewModel(with: feeds)
        
        if case .error(let error) = await viewModel.state {
            #expect(error == .duplicateFeed)
        }
    }
    
    @Test("Test invalid URL error")
    func testAddInvalidURL() async throws {
        let viewModel = await createViewModel(urlString: "invalid-url")
        
        await withDependencies {
            $0.rssClient.fetchFeed = { _ in throw RSSError.invalidURL }
        } operation: {
            await viewModel.addFeed()
            
            if case .error(let error) = await viewModel.state {
                #expect(error == .invalidURL)
            }
        }
    }
    
    @Test("Test network error handling")
    func testNetworkError() async throws {
        let viewModel = await createViewModel(urlString: "https://example.com")
        
        await withDependencies {
            $0.rssClient.fetchFeed = { _ in
                throw RSSError.networkError(NSError(domain: "test", code: -1, userInfo: nil))
            }
        } operation: {
            await viewModel.addFeed()
            
            if case .error(let error) = await viewModel.state {
                #expect(error.errorDescription.contains("Network error"))
            }
        }
    }
}
