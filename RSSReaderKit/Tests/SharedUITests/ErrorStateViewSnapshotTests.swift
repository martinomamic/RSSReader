//
//  ErrorStateViewSnapshotTests.swift
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
@Suite struct ErrorStateViewSnapshotTests {
    @Test("ErrorStateView variations")
    func testErrorStateViewVariations() async throws {
        let networkErrorView = ErrorStateView(
            error: AppError.networkError,
            retryAction: {}
        )
        
        let invalidURLErrorView = ErrorStateView(
            error: AppError.invalidURL,
            retryAction: {}
        )
        
        assertSnapshot(view: networkErrorView, layouts: [.fixed(size: CGSize(width: 375, height: 400))], named: "ErrorStateViewNetwork")
        assertSnapshot(view: invalidURLErrorView, layouts: [.fixed(size: CGSize(width: 375, height: 400))], named: "ErrorStateViewInvalidURL")
        
        assertSnapshot(
            view: networkErrorView,
            layouts: [.fixed(size: CGSize(width: 375, height: 450))],
            accessibility: .XXXL,
            named: "ErrorStateViewAccessible"
        )
    }
}
