//
//  ErrorStateView.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 19.04.25.
//

import SwiftUI

public struct ErrorStateView: View {
    let error: Error
    let retryAction: () -> Void
    
    public init(error: Error, retryAction: @escaping () -> Void) {
        self.error = error
        self.retryAction = retryAction
    }
    
    public var body: some View {
        ContentUnavailableView {
            Label("Failed to Load", systemImage: Constants.Images.failedToLoadIcon)
        } description: {
            Text(error.localizedDescription)
        } actions: {
            Button("Try Again", action: retryAction)
                .buttonStyle(.bordered)
        }
    }
}

#Preview {
    ErrorStateView(
        error: NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Something went wrong"]),
        retryAction: {}
    )
}
