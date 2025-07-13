//
//  ToastOverlayView.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 06.06.25.
//

import SwiftUI

public struct ToastOverlayView: View {
    var toastService: ToastService
    
    public init(toastService: ToastService) {
        self.toastService = toastService
    }
    
    public var body: some View {
        VStack {
            Spacer()
            ForEach(toastService.toasts) { toast in
                ToastView(toast: toast, toastService: toastService)
            }
        }
        .animation(
            .spring(
                response: 0.3,
                dampingFraction: 0.8
            ),
            value: toastService.toasts.count
        )
    }
}

@MainActor
extension View {
    public func toastOverlay(_ toastService: ToastService) -> some View {
        overlay(alignment: .bottom) {
            ToastOverlayView(toastService: toastService)
        }
    }
}
