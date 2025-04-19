import SwiftUI

public struct ErrorView: View {
    let title: String
    let message: String
    let retryAction: () -> Void
    
    public init(
        title: String = "Failed to Load",
        message: String,
        retryAction: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.retryAction = retryAction
    }
    
    public var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: Constants.Images.failedToLoadIcon)
        } description: {
            Text(message)
        } actions: {
            Button(action: retryAction) {
                Text("Try Again")
            }
            .buttonStyle(.bordered)
        }
    }
}
