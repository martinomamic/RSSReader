//
//  NotificationDebugViewSnapshotTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamic on 08.05.25.
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
        let debugView = NavigationStack { NotificationDebugView() }
        
        assertSnapshot(
            view: debugView,
            named: "NotificationDebugView"
        )
        
        assertSnapshot(
            view: debugView,
            accessibility: .XXXL,
            named: "NotificationDebugViewAccessible"
        )
    }
    
    @Test("NotificationDebugView with refreshing state")
    func testNotificationDebugViewRefreshing() async throws {
        let debugView = NotificationDebugView()
        debugView.isRefreshing = true
        
        assertSnapshot(
            view: NavigationStack { debugView },
            named: "NotificationDebugViewRefreshing"
        )
    }
    
    @Test("NotificationDebugView with results")
    func testNotificationDebugViewWithResults() async throws {
        let debugView = NotificationDebugView()
        debugView.isRefreshing = false
        debugView.refreshResult = "✅ Background refresh triggered successfully at 2025-05-09 15:30"
        debugView.notificationStatus = "Authorized"
        
        assertSnapshot(
            view: NavigationStack { debugView },
            named: "NotificationDebugViewResults"
        )
    }
}
