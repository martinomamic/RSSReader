//
//  NotificationDebugViewSnapshotTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamic on 08.05.25.
//

import Testing
import SnapshotTestUtility
import SwiftUI
import Dependencies
import Common

@testable import NotificationRepository

@MainActor
@Suite struct NotificationDebugViewSnapshotTests {
    @Test("NotificationDebugView in different states")
    func testNotificationDebugView() async throws {
        withDependencies {
            $0.notificationRepository = NotificationRepository.testValue
        } operation: {
            let debugView = NotificationDebugView()
            
            assertSnapshot(
                view: debugView,
                layouts: SnapshotLayout.defaults,
                colorScheme: .both,
                named: "NotificationDebugView"
            )
            
            assertSnapshot(
                view: debugView,
                layouts: [.mediumPhone],
                accessibility: .XXXL,
                colorScheme: .both,
                named: "NotificationDebugViewAccessible"
            )
        }
    }
    
    @Test("NotificationDebugView with refreshing state")
    func testNotificationDebugViewRefreshing() async throws {
        withDependencies {
            $0.notificationRepository = NotificationRepository.testValue
        } operation: {
            let debugView = NotificationDebugView()
            debugView.isRefreshing = true
            
            assertSnapshot(
                view: debugView,
                layouts: [.mediumPhone],
                colorScheme: .both,
                named: "NotificationDebugViewRefreshing"
            )
        }
    }
    
    @Test("NotificationDebugView with results")
    func testNotificationDebugViewWithResults() async throws {
        withDependencies {
            $0.notificationRepository = NotificationRepository.testValue
        } operation: {
            let debugView = NotificationDebugView()
            debugView.isRefreshing = false
            debugView.refreshResult = "✅ Background refresh triggered successfully at 2025-05-09 15:30"
            debugView.notificationStatus = "Authorized"
            
            
            assertSnapshot(
                view: debugView,
                layouts: [.mediumPhone],
                colorScheme: .both,
                named: "NotificationDebugViewResults"
            )
        }
    }
}
