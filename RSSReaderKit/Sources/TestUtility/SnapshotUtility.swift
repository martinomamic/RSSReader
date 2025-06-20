//
//  SnapshotUtility.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 08.05.25.
//

import SnapshotTesting
import SwiftUI
import Testing

public let perceptualPrecision: Float = 0.98

public enum ColorSchemeVariant: String {
    case light
    case dark
    case both
}

public enum SnapshotEmbedding {
    case navigationStack(title: String? = nil)
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
  perceptualPrecision: Float = perceptualPrecision,
  embedding: SnapshotEmbedding? = nil
) {
    func prepareView(for scheme: ColorScheme) -> some View {
        let contentView: AnyView
        
        if let embedding {
            switch embedding {
            case .navigationStack(let title):
                contentView = AnyView(
                    NavigationStack {
                        view
                            .navigationTitle(title ?? "")
                    }
                )
            }
        } else {
            contentView = AnyView(view)
        }
 
        return ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            contentView
                .environment(\.colorScheme, scheme)
                .preferredColorScheme(scheme)
                .withAccessibility(accessibility)
        }
        .background(Color(.systemBackground))
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
