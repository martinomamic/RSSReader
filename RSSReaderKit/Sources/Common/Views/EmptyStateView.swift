import SwiftUI

public struct EmptyStateView: View {
    let title: String
    let message: String
    let icon: String
    let actionTitle: String?
    let action: (() -> Void)?
    let identifier: String
    
    public init(
        title: String,
        message: String,
        icon: String = Constants.Images.noItemsIcon,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        identifier: String
    ) {
        self.title = title
        self.message = message
        self.icon = icon
        self.actionTitle = actionTitle
        self.action = action
        self.identifier = identifier
    }
    
    public var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: icon)
        } description: {
            Text(message)
        } actions: {
            if let action, let actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                }
                .buttonStyle(.bordered)
            }
        }
        .testId(identifier)
    }
}