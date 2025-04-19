import SwiftUI
import Common

public struct RoundedButton: View {
    let title: String
    let action: () -> Void
    let backgroundColor: Color
    let isEnabled: Bool
    
    public init(
        title: String,
        action: @escaping () -> Void,
        backgroundColor: Color = .blue,
        isEnabled: Bool = true
    ) {
        self.title = title
        self.action = action
        self.backgroundColor = backgroundColor
        self.isEnabled = isEnabled
    }
    
    public var body: some View {
        if isEnabled {
            Button(action: action) {
                buttonLabel
            }
        } else {
            buttonLabel
        }
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