//
//  SnapshotUtility.swift
//  RSSReaderKit
//
//  Created by Martino Mamic on 08.05.25.
//

import Dependencies
import SnapshotTesting
import SwiftUI
import Testing

public let perceptualPrecision: Float = 0.98

public enum ColorSchemeVariant: String {
    case light
    case dark
    case both
}

@MainActor
public func assertSnapshot<V: View>(
  view: V,
  testName: String = #function,
  file: StaticString = #filePath,
  line: UInt = #line,
  isRecording: Bool? = nil,
  layouts: [SnapshotLayout] = SnapshotLayout.defaults,
  accessibility: SnapshotAccessibility = .none,
  colorScheme: ColorSchemeVariant = .both,
  named: String? = nil,
  perceptualPrecision: Float = perceptualPrecision
) {
    func prepareView(for scheme: ColorScheme) -> some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            view
                .environment(\.colorScheme, scheme)
                .withAccessibility(accessibility)
        }
    }
    
    func makeSnapshot(scheme: ColorScheme, layout: SnapshotLayout) {
        let suffix = scheme == .light ? "light" : "dark"
        let snapshotName = "\(named.map { "\($0)-" } ?? "")\(layout.name)-\(accessibility.rawValue)-\(suffix)"
        
        assertSnapshot(
            of: prepareView(for: scheme),
            as: .image(
                perceptualPrecision: perceptualPrecision,
                layout: .device(config: layout.config)
            ),
            named: snapshotName,
            record: isRecording,
            file: file,
            testName: testName,
            line: line
        )
    }
    
    for layout in layouts {
        switch colorScheme {
        case .light:
            makeSnapshot(scheme: .light, layout: layout)
        case .dark:
            makeSnapshot(scheme: .dark, layout: layout)
        case .both:
            makeSnapshot(scheme: .light, layout: layout)
            makeSnapshot(scheme: .dark, layout: layout)
        }
    }
}
