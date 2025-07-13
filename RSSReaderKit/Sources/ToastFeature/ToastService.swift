//
//  ToastService.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 06.06.25.
//

import Foundation
import Observation
import SwiftUI

@MainActor @Observable
public final class ToastService {
    public var toasts: [Toast] = []
    private var toastQueue: [Toast] = []
    private var activeTasks: [String: Task<Void, Never>] = [:]
    private let maxVisibleToasts = 3
    
    public init() {}
    
    public func show(_ toast: Toast) {
        toastQueue.append(toast)
        processQueue()
    }
    
    private func processQueue() {
        while toasts.count < maxVisibleToasts && !toastQueue.isEmpty {
            let toast = toastQueue.removeFirst()
            toasts.append(toast)
            
            activeTasks[toast.id] = Task {
                try? await Task.sleep(for: .seconds(2))
                if !Task.isCancelled {
                    dismiss(toast)
                }
            }
        }
    }
    
    public func dismiss(_ toast: Toast) {
        activeTasks[toast.id]?.cancel()
        activeTasks[toast.id] = nil
        toasts.removeAll { $0.id == toast.id }
        processQueue()
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
