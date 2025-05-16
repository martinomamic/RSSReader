//
//  AddFeedViewModelTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 29.04.25.
//

import Common
import Dependencies
import FeedRepository
import Foundation
import SharedModels
import SwiftUI
import Testing

@testable import FeedListFeature

@MainActor
@Suite struct AddFeedViewModelTests {
    @Test("Initial state is idle")
    func testInitialState() {
        let viewModel = AddFeedViewModel()
        
        #expect(viewModel.state == .idle)
        #expect(viewModel.urlString == "")
        #expect(viewModel.isAddButtonDisabled == true)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.shouldDismiss == false)
    }
    
    @Test("URL validation works correctly")
    func testURLValidation() {
        let viewModel = AddFeedViewModel()
        
        viewModel.urlString = ""
        #expect(viewModel.isAddButtonDisabled == true)
        
        viewModel.urlString = "blob"
        #expect(viewModel.isAddButtonDisabled == true)
        
        viewModel.urlString = "https://google.com"
        #expect(viewModel.isAddButtonDisabled == true)
    }
    
    @Test("Adding feed successfully updates state")
    func testAddFeedSuccess() async throws {
        let testURL = URL(string: "https://example.com")!
        
        await withDependencies {
            $0.feedRepository.add = { url in
                #expect(url == testURL)
            }
        } operation: {
            let viewModel = AddFeedViewModel()
            viewModel.urlString = testURL.absoluteString
            
            #expect(viewModel.state == .idle)
            
            viewModel.addFeed()
            
            #expect(viewModel.state == .loading)
            
            await viewModel.waitForAddToFinish()
            
            #expect(viewModel.state == .content(true))
            #expect(viewModel.shouldDismiss == true)
        }
    }
     
    @Test("Invalid URL shows error")
    func testAddFeedInvalidURL() {
        let viewModel = AddFeedViewModel()
        viewModel.urlString = "invalid url"
        
        viewModel.addFeed()
        
        if case .error(let error) = viewModel.state {
            #expect(error == .invalidURL)
        }
    }
    
    @Test("Repository error is handled")
    func testAddFeedError() async throws {
        let testURL = URL(string: "https://example.com")!
        
        await withDependencies {
            $0.feedRepository.add = { _ in
                throw FeedRepositoryError.feedAlreadyExists
            }
        } operation: {
            let viewModel = AddFeedViewModel()
            viewModel.urlString = testURL.absoluteString
            
            viewModel.addFeed()
            
            await viewModel.waitForAddToFinish()
            
            if case .error(let error) = viewModel.state {
                #expect(error == .unknown("Feed already exists"))
            }
        }
    }
}
