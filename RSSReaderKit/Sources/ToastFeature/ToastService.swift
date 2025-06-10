//
//  ToastService.swift
//  RSSReaderKit
//
//  Created by Martino Mamic on 06.06.25.
//

import Dependencies
import Foundation
import Observation
import SwiftUI

@MainActor @Observable
public final class ToastService {
    public var toasts: [Toast] = []
    
    public init() {}
    
    public func show(_ toast: Toast) {
        toasts.insert(toast, at: 0)
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            dismiss(toast)
        }
    }
    
    public func dismiss(_ toast: Toast) {
        toasts.removeAll { $0.id == toast.id }
    }
}

extension ToastService {
    public func showSuccess(_ message: String) {
        show(.success(message))
    }
    
    public func showInfo(_ message: String) {
        show(.info(message))
    }
    
    public func showError(_ message: String) {
        show(.error(message))
    }
}
