//
//  NotificationDebugViewTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamic on 08.05.25.
//

import Dependencies
import NotificationRepository
import SnapshotTesting
import SwiftUI
import Testing

@testable import SharedUI

@MainActor
@Suite struct NotificationDebugViewTests {
    @Test("NotificationDebugView initial state")
    func testNotificationDebugViewInitialState() async throws {
        withDependencies {
            $0.notificationRepository.getNotificationStatus = { "Authorized" }
            $0.notificationRepository.getPendingNotifications = { [] }
        } operation: {
            let debugView = NotificationDebugView()
                .frame(width: 375, height: 600)
            
            assertSnapshot(of: debugView, as: .image)
        }
    }
    
    @Test("NotificationDebugView with results")
    func testNotificationDebugViewWithResults() async throws {
        let debugView = NotificationDebugView()
        debugView.notificationStatus = "Authorized"
        debugView.refreshResult = "✅ Background refresh triggered successfully at 14:30"
        
        assertSnapshot(of: debugView, as: .image)
    }
    
    @Test("NotificationDebugView in loading state")
    func testNotificationDebugViewLoading() async throws {
        let debugView = NotificationDebugView()
        
        debugView.notificationStatus = "Authorized"
        debugView.isRefreshing = true
        
        assertSnapshot(of: debugView, as: .image)
    }
}
