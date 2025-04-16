//
//  WebContentView.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 16.04.25.
//

import SwiftUI

public struct WebContentView: View {
    private let url: URL
    private let title: String
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    
    public init(url: URL, title: String) {
        self.url = url
        self.title = title
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                }
                WebView(url: url) { isLoading in
                    self.isLoading = isLoading
                }
                .edgesIgnoringSafeArea(.bottom)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
