//
//  View+Accessibility.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 19.04.25.
//

import SwiftUI

public extension View {
    func testId(_ id: String) -> some View {
        accessibilityIdentifier(id)
    }
}
