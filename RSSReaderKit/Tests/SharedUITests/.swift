//
//  EmptyStateViewSnapshotTests 2.swift
//  RSSReaderKit
//
//  Created by Martino Mamic on 09.05.25.
//


import Testing
import SnapshotTestUtility
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
        .frame(width: 375, height: 400)
        
        // With action button
        let viewWithAction = EmptyStateView(
            title: "No Items",
            systemImage: "tray",
            description: "Add items to get started",
            primaryAction: {},
            primaryActionLabel: "Add Item"
        )
        .frame(width: 375, height: 400)
        
        // Take snapshots
        assertSnapshot(view: basicView, layouts: [.fixed(size: CGSize(width: 375, height: 400))], named: "EmptyStateViewBasic")
        assertSnapshot(view: viewWithAction, layouts: [.fixed(size: CGSize(width: 375, height: 400))], named: "EmptyStateViewWithAction")
        
        // Test with accessibility setting
        assertSnapshot(
            view: viewWithAction,
            layouts: [.fixed(size: CGSize(width: 375, height: 450))],
            accessibility: .large,
            named: "EmptyStateViewAccessible"
        )
    }
}
