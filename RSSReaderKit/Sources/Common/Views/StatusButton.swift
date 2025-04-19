import SwiftUI
import Common

public struct StatusButton: View {
    let action: () -> Void
    let systemImage: String
    let isActive: Bool
    let activeColor: Color
    let testId: String
    
    public init(
        action: @escaping () -> Void,
        systemImage: String,
        isActive: Bool,
        activeColor: Color = .blue,
        testId: String
    ) {
        self.action = action
        self.systemImage = systemImage
        self.isActive = isActive
        self.activeColor = activeColor
        self.testId = testId
    }
    
    public var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundColor(isActive ? activeColor : .gray)
        }
        .buttonStyle(BorderlessButtonStyle())
        .testId(testId)
    }
}