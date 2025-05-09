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
    for layout in layouts {
      switch colorScheme {
      case .light:
        assertSnapshot(
          of: view.environment(\.colorScheme, .light).withAccessibility(accessibility),
          as: .image(
            perceptualPrecision: perceptualPrecision,
            layout: .device(config: layout.config)
          ),
          named: "\(named.map { "\($0)-" } ?? "")\(layout.name)-\(accessibility.rawValue)-light",
          record: isRecording,
          file: file,
          testName: testName,
          line: line
        )
        
      case .dark:
        assertSnapshot(
          of: view.environment(\.colorScheme, .dark).withAccessibility(accessibility),
          as: .image(
            perceptualPrecision: perceptualPrecision,
            layout: .device(config: layout.config)
          ),
          named: "\(named.map { "\($0)-" } ?? "")\(layout.name)-\(accessibility.rawValue)-dark",
          record: isRecording,
          file: file,
          testName: testName,
          line: line
        )
        
      case .both:
        assertSnapshot(
          of: view.environment(\.colorScheme, .light).withAccessibility(accessibility),
          as: .image(
            perceptualPrecision: perceptualPrecision,
            layout: .device(config: layout.config)
          ),
          named: "\(named.map { "\($0)-" } ?? "")\(layout.name)-\(accessibility.rawValue)-light",
          record: isRecording,
          file: file,
          testName: testName,
          line: line
        )
        
        assertSnapshot(
          of: view.environment(\.colorScheme, .dark).withAccessibility(accessibility),
          as: .image(
            perceptualPrecision: perceptualPrecision,
            layout: .device(config: layout.config)
          ),
          named: "\(named.map { "\($0)-" } ?? "")\(layout.name)-\(accessibility.rawValue)-dark",
          record: isRecording,
          file: file,
          testName: testName,
          line: line
        )
      }
  }
}
