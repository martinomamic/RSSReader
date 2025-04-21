//
//  CommonComponentsSnapshotTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 21.04.25.
//

import Testing
import SnapshotTesting
import SwiftUI
import Common

@MainActor
@Suite struct CommonComponentsSnapshotTests {
    @Test("EmptyStateView")
    func testEmptyStateView() async throws {
        let emptyView = EmptyStateView(
            title: "No Items",
            systemImage: "tray",
            description: "Add items to get started"
        )
        .frame(width: 375, height: 400)
        
        assertSnapshot(of: emptyView, as: .image)
    }
    
    @Test("EmptyStateView with action")
    func testEmptyStateViewWithAction() async throws {
        let emptyView = EmptyStateView(
            title: "No Items",
            systemImage: "tray",
            description: "Add items to get started",
            primaryAction: {},
            primaryActionLabel: "Add Item"
        )
        .frame(width: 375, height: 400)
        
        assertSnapshot(of: emptyView, as: .image)
    }
    
    @Test("ErrorStateView")
    func testErrorStateView() async throws {
        let errorView = ErrorStateView(
            error: NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Something went wrong"]),
            retryAction: {}
        )
        .frame(width: 375, height: 400)
        
        assertSnapshot(of: errorView, as: .image)
    }
    
    @Test("FeedImageView with URL")
    func testFeedImageViewWithURL() async throws {
        let imageView = FeedImageView(url: URL(string: "https://example.com/image.jpg"))
            .frame(width: 100, height: 100)
            
        assertSnapshot(of: imageView, as: .image)
    }
    
    @Test("FeedImageView without URL")
    func testFeedImageViewNoURL() async throws {
        let imageView = FeedImageView(url: nil)
            .frame(width: 100, height: 100)
            
        assertSnapshot(of: imageView, as: .image)
    }
    
    @Test("RoundedButton")
    func testRoundedButton() async throws {
        let buttonView = RoundedButton(
            title: "Add Feed",
            action: {}
        )
        .padding()
        .frame(width: 200)
        
        assertSnapshot(of: buttonView, as: .image)
    }
    
    @Test("ToggleButton when active")
    func testToggleButtonActive() async throws {
        let buttonView = ToggleButton(
            action: {},
            systemImage: "star.fill",
            isActive: true,
            activeColor: .yellow,
            testId: "testButton"
        )
        .padding()
        .frame(width: 100, height: 100)
        
        assertSnapshot(of: buttonView, as: .image)
    }
    
    @Test("ToggleButton when inactive")
    func testToggleButtonInactive() async throws {
        let buttonView = ToggleButton(
            action: {},
            systemImage: "star",
            isActive: false,
            activeColor: .yellow,
            testId: "testButton"
        )
        .padding()
        .frame(width: 100, height: 100)
        
        assertSnapshot(of: buttonView, as: .image)
    }
}
