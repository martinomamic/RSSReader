//
//  EmptyStateViewSnapshotTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamic on 09.05.25.
//

import Testing
import TestUtility
import SwiftUI
import Common

@testable import SharedUI

@MainActor
@Suite struct EmptyStateViewSnapshotTests {
    @Test("EmptyStateView variations")
    func testEmptyStateViewVariations() async throws {
        let basicView = EmptyStateView(
            title: "No Items",
            systemImage: "tray",
            description: "Add items to get started"
        )
        
        let viewWithAction = EmptyStateView(
            title: "No Items",
            systemImage: "tray",
            description: "Add items to get started",
            primaryAction: {},
            primaryActionLabel: "Add Item"
        )
        
        assertSnapshot(
            view: basicView,
            layouts: [.fixed(size: CGSize(width: 375, height: 400))],
            named: "EmptyStateViewBasic")
        
        assertSnapshot(
            view: viewWithAction,
            layouts: [.fixed(size: CGSize(width: 375, height: 400))],
            named: "EmptyStateViewWithAction"
        )
        
        assertSnapshot(
            view: viewWithAction,
            layouts: [.fixed(size: CGSize(width: 375, height: 450))],
            accessibility: .XXXL,
            named: "EmptyStateViewAccessible"
        )
    }
}
