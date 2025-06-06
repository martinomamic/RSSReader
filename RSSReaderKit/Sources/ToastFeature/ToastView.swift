//
//  ToastView.swift
//  RSSReaderKit
//
//  Created by Martino Mamic on 06.06.25.
//

import Common
import SwiftUI

public struct ToastView: View {
    let toast: Toast

    @State private var offset: CGSize = .zero
    
    public init(toast: Toast, offset: CGSize) {
        self.toast = toast
        self.offset = offset
    }

    public var body: some View {
        HStack {
            Image(systemName: toast.icon)
                .foregroundColor(toast.foregroundColor)
                .font(.title2)

            Text(toast.message)
                .font(.body)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(toast.backgroundColor)
        .cornerRadius(Constants.UI.cornerRadius)
        .padding(.horizontal)
        .padding(.top, Constants.UI.verticalPadding)
        .offset(y: offset.height)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: offset)
        .transition(.move(edge: .top).combined(with: .opacity))
        .zIndex(1000)
    }
}

public extension ViewState where T == Toast? {
    static var idle: ViewState<Toast?> {
        return .content(nil)
    }
}
