//
//  FeedViewModelTests.swift
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
import NotificationClient
import Common
import ConcurrencyExtras

@testable import FeedListFeature

@MainActor
@Suite struct FeedViewModelTests {
    func createTestFeed(
        url: String = "https://example.com",
        title: String? = "Test Feed",
        description: String? = "Test Description",
        isFavorite: Bool = false,
        notificationsEnabled: Bool = false
    ) -> Feed {
        Feed(
            url: URL(string: url)!,
            title: title,
            description: description,
            imageURL: nil,
            isFavorite: isFavorite,
            notificationsEnabled: notificationsEnabled
        )
    }
    
    func createViewModel(feed: Feed) -> FeedViewModel {
        return FeedViewModel(url: feed.url, feed: feed)
    }
    
    @Test("Load feed details successfully")
    func testLoadFeedDetails() async throws {
        let initialFeed = createTestFeed(title: nil, description: nil)
        
        let completeFeed = Feed(
            url: URL(string: "https://example.com")!,
            title: "Complete Feed",
            description: "Complete feed description",
            imageURL: URL(string: "https://example.com/image.jpg")
        )
        
        let viewModel = createViewModel(feed: initialFeed)
        
        withDependencies {
            $0.rssClient.fetchFeed = { _ in completeFeed }
        } operation: {
            viewModel.loadFeedDetails()
            
            if case .loaded(let feed) = viewModel.state {
                #expect(feed.title == "Complete Feed")
                #expect(feed.description == "Complete feed description")
                #expect(feed.imageURL == URL(string: "https://example.com/image.jpg"))
            }
        }
    }
    
    @Test("Handle feed loading error")
    func testLoadFeedError() async throws {
        let feed = createTestFeed()
        let viewModel = createViewModel(feed: feed)
        
        withDependencies {
            $0.rssClient.fetchFeed = { _ in
                throw RSSError.networkError(NSError(domain: "test", code: -1, userInfo: nil))
            }
        } operation: {
            viewModel.loadFeedDetails()
            
            if case .error(let error) = viewModel.state {
                #expect(error.errorDescription.contains("Network error"))
            }
        }
    }
    
    @Test("Toggle favorite successfully")
    func testToggleFavorite() async throws {
        let feed = createTestFeed(isFavorite: false)
        let viewModel = createViewModel(feed: feed)
        let updatedFeed = LockIsolated<Feed>(feed)
        
        await withDependencies {
            $0.persistenceClient.updateFeed = { feed in
                updatedFeed.withValue { $0 = feed }
            }
        } operation: {
            viewModel.toggleFavorite()
            await viewModel.waitForFavoritesToggleToFinish()
            #expect(viewModel.feed.isFavorite == true)
            #expect(updatedFeed.value.isFavorite == true)
            
            viewModel.toggleFavorite()
            await viewModel.waitForFavoritesToggleToFinish()
            #expect(viewModel.feed.isFavorite == false)
            #expect(updatedFeed.value.isFavorite == false)
        }
    }
    
    @Test("Toggle notifications successfully")
    func testToggleNotifications() async throws {
        let feed = createTestFeed(notificationsEnabled: false)
        let viewModel = createViewModel(feed: feed)
        let permissionsRequested = LockIsolated<Bool>(false)
        let notificationsChecked = LockIsolated<Bool>(false)
        let updatedFeed = LockIsolated<Feed>(feed)
        
        await withDependencies {
            $0.notificationClient.requestPermissions = {
                permissionsRequested.setValue(true)
            }
            $0.notificationClient.checkForNewItems = {
                notificationsChecked.setValue(true)
            }
            $0.persistenceClient.updateFeed = { feed in
                updatedFeed.setValue(feed)
            }
        } operation: {
            viewModel.toggleNotifications()
            await viewModel.waitForNotificationToggleToFinish()
            #expect(permissionsRequested.value == true)  // Was requested
            #expect(notificationsChecked.value == true)  // Was checked
            #expect(viewModel.feed.notificationsEnabled == true)
            #expect(updatedFeed.value.notificationsEnabled == true)
            
            viewModel.toggleNotifications()
            await viewModel.waitForNotificationToggleToFinish()
            #expect(viewModel.feed.notificationsEnabled == false)
            #expect(updatedFeed.value.notificationsEnabled == false)
        }
    }
    
    @Test("Handle notification permission error")
    func testNotificationPermissionError() async throws {
        let feed = createTestFeed(notificationsEnabled: false)
        let viewModel = createViewModel(feed: feed)
        
        withDependencies {
            $0.notificationClient.requestPermissions = {
                throw NotificationError.permissionDenied
            }
        } operation: {
            viewModel.toggleNotifications()
            
            #expect(viewModel.feed.notificationsEnabled == false, "Should revert to original state")
            
            if case .error(let error) = viewModel.state {
                #expect(error.errorDescription.contains("Permission"))
            }
        }
    }
}
