//
//  SnapshotAccessibility.swift
//  RSSReaderKit
//
//  Created by Martino Mamic on 09.05.25.
//

import SwiftUI

public enum SnapshotAccessibility: String {
  case none = ""
  case large
  case XL
  case XXXL
}

extension View {
  @ViewBuilder
  public func withAccessibility(_ accessibility: SnapshotAccessibility) -> some View {
    switch accessibility {
    case .none:
      self
    case .large:
      self.environment(\.sizeCategory, .accessibilityLarge)
    case .XL:
      self.environment(\.sizeCategory, .accessibilityExtraLarge)
    case .XXXL:
      self.environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
    }
  }
}
