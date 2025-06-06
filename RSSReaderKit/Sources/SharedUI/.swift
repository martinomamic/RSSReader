//
//  ToastView.swift
//  RSSReaderKit
//
//  Created by Martino Mamic on 04.06.25.
//

import Common
import Dependencies
import SharedModels
import SwiftUI

public struct ToastView: View {
    let toast: Toast
    let onDismiss: () -> Void
    
    public init(toast: Toast, onDismiss: @escaping () -> Void) {
        self.toast = toast
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(foregroundColor)
                .font(.title2)
            
            Text(toast.message)
                .font(.body)
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(8)
        .padding(.horizontal)
        .shadow(radius: 4)
    }
    
    private var backgroundColor: Color {
        switch toast.type {
        case .info: return .blue.opacity(0.3)
        case .success: return .green.opacity(0.3)
        case .error: return .red.opacity(0.3)
        }
    }
    
    private var foregroundColor: Color {
        switch toast.type {
        case .info: return .blue
        case .success: return .green
        case .error: return .red
        }
    }
    
    private var icon: String {
        switch toast.type {
        case .info: return "info.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .error: return "exclamationmark.triangle.fill"
        }
    }
}

@MainActor
public struct ToastContainer: View {
    @State private var toasts: [Toast] = []
    @Dependency(\.toastClient) private var toastClient
    
    public init() {}
    
    public var body: some View {
        VStack {
            ForEach(toasts) { toast in
                ToastView(toast: toast) {
                    dismiss(toast)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            Spacer()
        }
        .animation(.spring(), value: toasts)
        .task {
            for await toast in toastClient.observe() {
                show(toast)
            }
        }
    }
    
    private func show(_ toast: Toast) {
        toasts.insert(toast, at: 0)
        
        Task {
            try? await Task.sleep(for: .seconds(3))
            dismiss(toast)
        }
    }
    
    private func dismiss(_ toast: Toast) {
        toasts.removeAll { $0.id == toast.id }
    }
}
