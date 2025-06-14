//
//  NotificationDebugViewSnapshotTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 08.05.25.
//

import Testing
import TestUtility
import SwiftUI
import Dependencies
import Common

@testable import NotificationRepository

@MainActor
@Suite struct NotificationDebugViewSnapshotTests {
    @Test("NotificationDebugView in different states")
    func testNotificationDebugView() async throws {
        let debugView = NotificationDebugView()
        
        assertSnapshot(
            view: debugView,
            named: "NotificationDebugView",
            embedding: .navigationStack()
        )
        
        assertSnapshot(
            view: debugView,
            accessibility: .XXXL,
            named: "NotificationDebugViewAccessible",
            embedding: .navigationStack()
        )
    }
    
    @Test("NotificationDebugView with refreshing state")
    func testNotificationDebugViewRefreshing() async throws {
        let debugView = NotificationDebugView()
        debugView.isRefreshing = true
        
        assertSnapshot(
            view: debugView,
            named: "NotificationDebugViewRefreshing",
            embedding: .navigationStack()
        )
    }
    
    @Test("NotificationDebugView with results")
    func testNotificationDebugViewWithResults() async throws {
        let debugView = NotificationDebugView()
        debugView.isRefreshing = false
        debugView.refreshResult = "✅ Background refresh triggered successfully at 2025-05-09 15:30"
        debugView.notificationStatus = "Authorized"
        
        assertSnapshot(
            view: debugView,
            named: "NotificationDebugViewResults",
            embedding: .navigationStack()
        )
    }
}
