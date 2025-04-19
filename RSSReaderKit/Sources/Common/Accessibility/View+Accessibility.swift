import SwiftUI

public extension View {
    func testId(_ id: String) -> some View {
        accessibilityIdentifier(id)
    }
}
