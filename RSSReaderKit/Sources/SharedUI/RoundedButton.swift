//
//  RoundedButton.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 19.04.25.
//

import Common
import SwiftUI

public struct RoundedButton: View {
    let title: String
    let action: () -> Void
    let backgroundColor: Color
    let isDisabled: Bool
    
    public init(
        title: String,
        action: @escaping () -> Void,
        backgroundColor: Color = .blue,
        isDisabled: Bool = false
    ) {
        self.title = title
        self.action = action
        self.backgroundColor = backgroundColor
        self.isDisabled = isDisabled
    }
    
    public var body: some View {
        Button(action: action) {
            buttonLabel
        }
        .disabled(isDisabled)
    }
    
    private var buttonLabel: some View {
        Text(title)
            .font(.caption)
            .padding(.horizontal, Constants.UI.exploreFeedButtonHorizontalPadding)
            .padding(.vertical, Constants.UI.exploreFeedButtonVerticalPadding)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(Constants.UI.exploreFeedButtonCornerRadius)
    }
}
