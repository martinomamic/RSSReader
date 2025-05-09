//
//  TabBarSnapshotTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 30.04.25.
//

import Testing
import SnapshotTestUtility
import SwiftUI
import Common

@testable import TabBarFeature

@MainActor
@Suite struct TabBarSnapshotTests {
    @Test("TabBarView with all tabs")
    func testTabBarView() async throws {
        let tabBarView = TabBarView()
        
        assertSnapshot(view: tabBarView, layouts: SnapshotLayout.defaults, named: "TabBarView")
        
        assertSnapshot(
            view: tabBarView,
            layouts: [.mediumPhone],
            accessibility: .XXXL,
            named: "TabBarView"
        )
    }
}
