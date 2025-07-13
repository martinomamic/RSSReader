//
//  ErrorStateView.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 19.04.25.
//

import Common
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
            Label(LocalizedStrings.ErrorState.title, systemImage: Constants.Images.failedToLoadIcon)
        } description: {
            Text(ErrorUtils.toAppError(error).errorDescription)
        } actions: {
            Button(LocalizedStrings.ErrorState.tryAgain, action: retryAction)
                .buttonStyle(.bordered)
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    ErrorStateView(
        error: AppError.general,
        retryAction: {}
    )
}
