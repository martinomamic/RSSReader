//
//  ExploreViewModelTests.swift
//  RSSReaderKitTests
//
//  Created by Martino Mamic on 19.05.25.
//

import Common
import Dependencies
import Foundation
import SharedModels
import Testing
import TestUtility

@testable import ExploreFeature

@MainActor
@Suite struct ExploreViewModelTests {
    @Test("Initial state is correct")
    func testInitialState() {
        let viewModel = ExploreViewModel()

        #expect(viewModel.state == .loading)
        #expect(viewModel.selectedFeed == nil)
        #expect(viewModel.addedFeedURLs.isEmpty)
        #expect(viewModel.selectedFilter == .notAdded)
        #expect(viewModel.filteredFeeds.isEmpty)
    }

    @Test("loadExploreFeeds successfully - no added feeds")
    func testLoadExploreFeedsSuccessNoAdded() async throws {
        let exploreFeedsToReturn: [ExploreFeed] = [SharedMocks.sampleExploreFeed1, SharedMocks.sampleExploreFeed2]
        await withDependencies {
            $0.feedRepository.loadExploreFeeds = { exploreFeedsToReturn }
            $0.feedRepository.getCurrentFeeds = { [] }
        } operation: {
            let viewModel = ExploreViewModel()
            viewModel.loadExploreFeeds()
            await viewModel.loadTask?.value

            #expect(viewModel.state == .content(exploreFeedsToReturn))
            #expect(viewModel.addedFeedURLs.isEmpty)
            #expect(viewModel.selectedFilter == .notAdded)
            #expect(viewModel.filteredFeeds.count == 2)
            #expect(viewModel.filteredFeeds.contains(where: { $0.url == SharedMocks.sampleExploreFeed1.url }))
            #expect(viewModel.filteredFeeds.contains(where: { $0.url == SharedMocks.sampleExploreFeed2.url }))
        }
    }

    @Test("loadExploreFeeds successfully - with added feeds")
    func testLoadExploreFeedsSuccessWithAdded() async throws {
        let exploreFeedsToReturn: [ExploreFeed] = SharedMocks.sampleExploreFeeds
        let currentFeedsToReturn: [Feed] = [SharedMocks.sampleFeed1]

        await withDependencies {
            $0.feedRepository.loadExploreFeeds = { exploreFeedsToReturn }
            $0.feedRepository.getCurrentFeeds = { currentFeedsToReturn }
        } operation: {
            let viewModel = ExploreViewModel()
            viewModel.loadExploreFeeds()
            await viewModel.loadTask?.value

            #expect(viewModel.addedFeedURLs.count == 1)
            #expect(viewModel.addedFeedURLs.contains(SharedMocks.sampleExploreFeed1.url))
            #expect(viewModel.selectedFilter == .notAdded)

            if case .content(let feeds) = viewModel.state {
                #expect(feeds.count == 2)
                #expect(feeds.contains(where: { $0.url == SharedMocks.sampleExploreFeed2.url }))
                #expect(feeds.contains(where: { $0.url == SharedMocks.sampleExploreFeed3.url }))
            } else {
                Issue.record("State should be .content")
            }
        }
    }

    @Test("loadExploreFeeds successfully - all feeds added")
    func testLoadExploreFeedsSuccessAllAdded() async throws {
        let exploreFeedsToReturn: [ExploreFeed] = [SharedMocks.sampleExploreFeed1, SharedMocks.sampleExploreFeed2]
        let currentFeedsToReturn: [Feed] = [SharedMocks.sampleFeed1, SharedMocks.sampleFeed2] // All are added

        await withDependencies {
            $0.feedRepository.loadExploreFeeds = { exploreFeedsToReturn }
            $0.feedRepository.getCurrentFeeds = { currentFeedsToReturn }
        } operation: {
            let viewModel = ExploreViewModel()
            viewModel.loadExploreFeeds()
            await viewModel.loadTask?.value

            #expect(viewModel.addedFeedURLs.count == 2)
            #expect(viewModel.selectedFilter == .notAdded)
            #expect(viewModel.state == .empty) // "Not Added" filter should result in empty
        }
    }
    
    @Test("loadExploreFeeds results in empty state")
    func testLoadExploreFeedsEmpty() async throws {
        await withDependencies {
            $0.feedRepository.loadExploreFeeds = { [] }
            $0.feedRepository.getCurrentFeeds = { [] }
        } operation: {
            let viewModel = ExploreViewModel()
            viewModel.loadExploreFeeds()
            await viewModel.loadTask?.value

            #expect(viewModel.state == .empty)
        }
    }

    @Test("loadExploreFeeds handles error")
    func testLoadExploreFeedsError() async throws {
        enum TestError: Error { case generic }
        await withDependencies {
            $0.feedRepository.loadExploreFeeds = { throw TestError.generic }
            $0.feedRepository.getCurrentFeeds = { [] }
        } operation: {
            let viewModel = ExploreViewModel()
            viewModel.loadExploreFeeds()
            await viewModel.loadTask?.value

            if case .error(let appError) = viewModel.state {
                #expect(appError.localizedDescription == ErrorUtils.toAppError(TestError.generic).localizedDescription)
            } else {
                Issue.record("State should be .error")
            }
        }
    }

    @Test("addFeed successfully")
    func testAddFeedSuccess() async throws {
        let feedToAdd = SharedMocks.sampleExploreFeed1
        let addedFeed = SharedMocks.sampleFeed1
        let initialExploreFeeds: [ExploreFeed] = [SharedMocks.sampleExploreFeed1, SharedMocks.sampleExploreFeed2]
        
        await withDependencies {
            $0.feedRepository.loadExploreFeeds = { initialExploreFeeds }
            $0.feedRepository.getCurrentFeeds = { [] }
            $0.feedRepository.addExploreFeed = { exploreFeed in
                #expect(exploreFeed.url == feedToAdd.url)
                return addedFeed
            }
        } operation: {
            let viewModel = ExploreViewModel()
            viewModel.loadExploreFeeds()
            await viewModel.loadTask?.value

            #expect(viewModel.isFeedAdded(feedToAdd) == false)
            
            viewModel.addFeed(feedToAdd)
            await viewModel.addTask?.value

            #expect(viewModel.isFeedAdded(feedToAdd) == true)
            #expect(viewModel.addedFeedURLs.contains(feedToAdd.url))

            if case .content(let feeds) = viewModel.state {
                 #expect(feeds.count == 1)
                 #expect(feeds.first?.url == SharedMocks.sampleExploreFeed2.url)
            } else {
                Issue.record("State should be .content, got \(viewModel.state)")
            }
        }
    }

    @Test("addFeed handles error")
    func testAddFeedError() async throws {
        enum TestError: Error { case addFailed }
        let feedToAdd = SharedMocks.sampleExploreFeed1
        let initialExploreFeeds: [ExploreFeed] = [SharedMocks.sampleExploreFeed1]
        
        await withDependencies {
            $0.feedRepository.loadExploreFeeds = { initialExploreFeeds }
            $0.feedRepository.getCurrentFeeds = { [] }
            $0.feedRepository.addExploreFeed = { _ in throw TestError.addFailed }
        } operation: {
            let viewModel = ExploreViewModel()
            viewModel.loadExploreFeeds()
            await viewModel.loadTask?.value

            viewModel.addFeed(feedToAdd)
            await viewModel.addTask?.value

            if case .error(let appError) = viewModel.state {
                #expect(appError.localizedDescription == ErrorUtils.toAppError(TestError.addFailed).localizedDescription)
            } else {
                Issue.record("State should be .error")
            }
            #expect(viewModel.isFeedAdded(feedToAdd) == false)
        }
    }

    @Test("removeFeed successfully")
    func testRemoveFeedSuccess() async throws {
        let feedToRemove = SharedMocks.sampleExploreFeed1
        let initialExploreFeeds: [ExploreFeed] = [SharedMocks.sampleExploreFeed1, SharedMocks.sampleExploreFeed2]
        let initialCurrentFeeds: [Feed] = [SharedMocks.sampleFeed1]
        
        await withDependencies {
            $0.feedRepository.loadExploreFeeds = { initialExploreFeeds }
            $0.feedRepository.getCurrentFeeds = { initialCurrentFeeds }
            $0.feedRepository.delete = { url in
                #expect(url.absoluteString == feedToRemove.url)
            }
        } operation: {
            let viewModel = ExploreViewModel()
            viewModel.loadExploreFeeds()
            await viewModel.loadTask?.value

            #expect(viewModel.isFeedAdded(feedToRemove) == true)
            
            viewModel.selectedFilter = .added
            viewModel.filterFeeds()
             if case .content(let feeds) = viewModel.state {
                 #expect(feeds.count == 1)
                 #expect(feeds.first?.url == feedToRemove.url)
            } else {
                Issue.record("State should be .content with 1 added feed")
            }

            viewModel.removeFeed(feedToRemove)
            await viewModel.removeTask?.value

            #expect(viewModel.isFeedAdded(feedToRemove) == false)
            #expect(viewModel.addedFeedURLs.isEmpty)
            #expect(viewModel.state == .empty)
        }
    }

    @Test("removeFeed handles error")
    func testRemoveFeedError() async throws {
        enum TestError: Error { case deleteFailed }
        let feedToRemove = SharedMocks.sampleExploreFeed1
        let initialExploreFeeds: [ExploreFeed] = [SharedMocks.sampleExploreFeed1]
        let initialCurrentFeeds: [Feed] = [SharedMocks.sampleFeed1]

        await withDependencies {
            $0.feedRepository.loadExploreFeeds = { initialExploreFeeds }
            $0.feedRepository.getCurrentFeeds = { initialCurrentFeeds }
            $0.feedRepository.delete = { _ in throw TestError.deleteFailed }
        } operation: {
            let viewModel = ExploreViewModel()
            viewModel.loadExploreFeeds()
            await viewModel.loadTask?.value

            #expect(viewModel.isFeedAdded(feedToRemove) == true)

            viewModel.removeFeed(feedToRemove)
            await viewModel.removeTask?.value
            
            if case .error(let appError) = viewModel.state {
                 #expect(appError.localizedDescription == ErrorUtils.toAppError(TestError.deleteFailed).localizedDescription)
            } else {
                Issue.record("State should be .error")
            }
            #expect(viewModel.isFeedAdded(feedToRemove) == true)
        }
    }

    @Test("isFeedAdded works correctly")
    func testIsFeedAdded() async throws {
        let exploreFeedsToReturn: [ExploreFeed] = [SharedMocks.sampleExploreFeed1, SharedMocks.sampleExploreFeed2]
        let currentFeedsToReturn: [Feed] = [SharedMocks.sampleFeed1]

        await withDependencies {
            $0.feedRepository.loadExploreFeeds = { exploreFeedsToReturn }
            $0.feedRepository.getCurrentFeeds = { currentFeedsToReturn }
        } operation: {
            let viewModel = ExploreViewModel()
            viewModel.loadExploreFeeds()
            await viewModel.loadTask?.value

            #expect(viewModel.isFeedAdded(SharedMocks.sampleExploreFeed1) == true)
            #expect(viewModel.isFeedAdded(SharedMocks.sampleExploreFeed2) == false)
        }
    }

    @Test("handleFeed calls addFeed when not added")
    func testHandleFeedAdds() async throws {
        let feedToHandle = SharedMocks.sampleExploreFeed1
        let addExploreFeedCalled = LockIsolated(false)
        let initialExploreFeeds: [ExploreFeed] = [SharedMocks.sampleExploreFeed1]
        
        await withDependencies {
            $0.feedRepository.loadExploreFeeds = { initialExploreFeeds }
            $0.feedRepository.getCurrentFeeds = { [] }
            $0.feedRepository.addExploreFeed = { _ in
                addExploreFeedCalled.setValue(true)
                return SharedMocks.sampleFeed1
            }
        } operation: {
            let viewModel = ExploreViewModel()
            viewModel.loadExploreFeeds()
            await viewModel.loadTask?.value

            #expect(viewModel.isFeedAdded(feedToHandle) == false)
            viewModel.handleFeed(feedToHandle)
            await viewModel.addTask?.value
            
            #expect(addExploreFeedCalled.value == true)
            #expect(viewModel.isFeedAdded(feedToHandle) == true)
        }
    }

    @Test("handleFeed calls removeFeed when added")
    func testHandleFeedRemoves() async throws {
        let feedToHandle = SharedMocks.sampleExploreFeed1
        let deleteCalled = LockIsolated(false)
        let initialExploreFeeds: [ExploreFeed] = [SharedMocks.sampleExploreFeed1]
        let initialCurrentFeeds: [Feed] = [SharedMocks.sampleFeed1]

        await withDependencies {
            $0.feedRepository.loadExploreFeeds = { initialExploreFeeds }
            $0.feedRepository.getCurrentFeeds = { initialCurrentFeeds }
            $0.feedRepository.delete = { _ in
                deleteCalled.setValue(true)
            }
        } operation: {
            let viewModel = ExploreViewModel()
            viewModel.loadExploreFeeds()
            await viewModel.loadTask?.value

            #expect(viewModel.isFeedAdded(feedToHandle) == true)
            viewModel.handleFeed(feedToHandle)
            await viewModel.removeTask?.value

            #expect(deleteCalled.value == true)
            #expect(viewModel.isFeedAdded(feedToHandle) == false)
        }
    }
    
    @Test("filterFeeds updates state - Not Added filter")
    func testFilterFeedsNotAdded() async throws {
        let exploreFeeds: [ExploreFeed] = [SharedMocks.sampleExploreFeed1, SharedMocks.sampleExploreFeed2, SharedMocks.sampleExploreFeed3]
        let currentFeeds: [Feed] = [SharedMocks.sampleFeed1]

        await withDependencies {
            $0.feedRepository.loadExploreFeeds = { exploreFeeds }
            $0.feedRepository.getCurrentFeeds = { currentFeeds }
        } operation: {
            let viewModel = ExploreViewModel()
            viewModel.loadExploreFeeds()
            await viewModel.loadTask?.value

            #expect(viewModel.selectedFilter == .notAdded)
            if case .content(let feeds) = viewModel.state {
                #expect(feeds.count == 2)
                #expect(feeds.contains(where: { $0.url == SharedMocks.sampleExploreFeed2.url }))
                #expect(feeds.contains(where: { $0.url == SharedMocks.sampleExploreFeed3.url }))
            } else {
                Issue.record("State should be .content")
            }
        }
    }
    
    @Test("filterFeeds updates state - Added filter")
    func testFilterFeedsAdded() async throws {
        let exploreFeeds: [ExploreFeed] = [SharedMocks.sampleExploreFeed1, SharedMocks.sampleExploreFeed2, SharedMocks.sampleExploreFeed3]
        let currentFeeds: [Feed] = [SharedMocks.sampleFeed1, SharedMocks.sampleFeed2]

        await withDependencies {
            $0.feedRepository.loadExploreFeeds = { exploreFeeds }
            $0.feedRepository.getCurrentFeeds = { currentFeeds }
        } operation: {
            let viewModel = ExploreViewModel()
            viewModel.loadExploreFeeds()
            await viewModel.loadTask?.value
            
            viewModel.selectedFilter = .added
            viewModel.filterFeeds()

            #expect(viewModel.selectedFilter == .added)
            if case .content(let feeds) = viewModel.state {
                #expect(feeds.count == 2)
                #expect(feeds.contains(where: { $0.url == SharedMocks.sampleExploreFeed1.url }))
                #expect(feeds.contains(where: { $0.url == SharedMocks.sampleExploreFeed2.url }))
            } else {
                Issue.record("State should be .content, got \(viewModel.state)")
            }
        }
    }
    
    @Test("filterFeeds updates state - Added filter results in empty")
    func testFilterFeedsAddedEmpty() async throws {
        let exploreFeeds: [ExploreFeed] = [SharedMocks.sampleExploreFeed1]
        let currentFeeds: [Feed] = []

        await withDependencies {
            $0.feedRepository.loadExploreFeeds = { exploreFeeds }
            $0.feedRepository.getCurrentFeeds = { currentFeeds }
        } operation: {
            let viewModel = ExploreViewModel()
            viewModel.loadExploreFeeds()
            await viewModel.loadTask?.value
            
            viewModel.selectedFilter = .added
            viewModel.filterFeeds()

            #expect(viewModel.selectedFilter == .added)
            #expect(viewModel.state == .empty)
        }
    }
    
    @Test("filteredFeeds computed property works correctly")
    func testFilteredFeedsComputedProperty() async throws {
        let exploreFeeds: [ExploreFeed] = [SharedMocks.sampleExploreFeed1, SharedMocks.sampleExploreFeed2, SharedMocks.sampleExploreFeed3]
        let currentFeeds: [Feed] = [SharedMocks.sampleFeed1]

        await withDependencies {
            $0.feedRepository.loadExploreFeeds = { exploreFeeds }
            $0.feedRepository.getCurrentFeeds = { currentFeeds }
        } operation: {
            let viewModel = ExploreViewModel()
            viewModel.loadExploreFeeds()
            await viewModel.loadTask?.value

            viewModel.selectedFilter = .notAdded
            #expect(viewModel.filteredFeeds.count == 2)
            #expect(!viewModel.filteredFeeds.contains(where: { $0.url == SharedMocks.sampleExploreFeed1.url }))
            #expect(viewModel.filteredFeeds.contains(where: { $0.url == SharedMocks.sampleExploreFeed2.url }))
            #expect(viewModel.filteredFeeds.contains(where: { $0.url == SharedMocks.sampleExploreFeed3.url }))

            viewModel.selectedFilter = .added
            #expect(viewModel.filteredFeeds.count == 1)
            #expect(viewModel.filteredFeeds.first?.url == SharedMocks.sampleExploreFeed1.url)
        }
    }
}
