import SwiftUI

public struct EmptyStateView: View {
    let title: String
    let systemImage: String
    let description: String
    let primaryAction: (() -> Void)?
    let primaryActionLabel: String?
    
    public init(
        title: String,
        systemImage: String,
        description: String,
        primaryAction: (() -> Void)? = nil,
        primaryActionLabel: String? = nil
    ) {
        self.title = title
        self.systemImage = systemImage
        self.description = description
        self.primaryAction = primaryAction
        self.primaryActionLabel = primaryActionLabel
    }
    
    public var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(description)
        } actions: {
            if let primaryAction, let primaryActionLabel {
                Button(action: primaryAction) {
                    Text(primaryActionLabel)
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

#Preview {
    EmptyStateView(
        title: "No Items",
        systemImage: "tray",
        description: "Add items to get started",
        primaryAction: {},
        primaryActionLabel: "Add Item"
    )
}