//
//  Toast.swift
//  RSSReaderKit
//
//  Created by Martino Mamic on 06.06.25.
//

import SwiftUI
import Foundation

public struct Toast: Identifiable, Sendable {
    public enum ToastType: Int, CaseIterable, Sendable {
        case info
        case success
        case error
    }

    public let id: String
    public let message: String
    public let type: ToastType

    public init(
        id: String = UUID().uuidString,
        message: String,
        type: ToastType
    ) {
        self.id = id
        self.message = message
        self.type = type
    }
}

extension Toast: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.message == rhs.message && lhs.type == rhs.type
    }
}

extension Toast {
    public static func success(_ message: String) -> Toast {
        Toast(message: message, type: .success)
    }
    
    public static func info(_ message: String) -> Toast {
        Toast(message: message, type: .info)
    }
    
    public static func error(_ message: String) -> Toast {
        Toast(message: message, type: .error)
    }
}

extension Toast {
    var backgroundColor: Color {
        switch self.type {
        case .info:
            return .blue.opacity(0.5)
        case .error:
            return .red.opacity(0.5)
        case .success:
            return .green.opacity(0.5)
        }
    }

    var foregroundColor: Color {
        switch self.type {
        case .info:
            return .blue
        case .error:
            return .red
        case .success:
            return .green
        }
    }

    var icon: String {
        switch self.type {
        case .info:
            return "info.circle.fill"
        case .error:
            return "exclamationmark.triangle.fill"
        case .success:
            return "checkmark.circle.fill"
        }
    }
}
