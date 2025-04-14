//
//  AddFeedView.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 13.04.25.
//

import SwiftUI

struct AddFeedView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddFeedViewModel
    
    init(feeds: Binding<[FeedViewModel]>) {
        _viewModel = State(initialValue: AddFeedViewModel(feeds: feeds))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Feed URL", text: $viewModel.urlString)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                } header: {
                    Text("Enter RSS feed URL")
                } footer: {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Examples (tap to use):")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Button("BBC News") {
                                viewModel.urlString = "https://feeds.bbci.co.uk/news/world/rss.xml"
                            }
                            .font(.footnote)
                            
                            Button("NBC News") {
                                viewModel.urlString = "https://feeds.nbcnews.com/nbcnews/public/news"
                            }
                            .font(.footnote)
                        }
                    }
                }            }
            .navigationTitle("Add Feed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addFeed()
                    }
                    .disabled(!viewModel.isValidURL || viewModel.isAdding)
                }
            }
            .overlay {
                if viewModel.isAdding {
                    ProgressView()
                }
            }
            .alert("Error Adding Feed", isPresented: $viewModel.showError) {
                Button("OK") {}
            } message: {
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
            }
        }
    }
    
    private func addFeed() {
        Task {
            if await viewModel.addFeed() {
                dismiss()
            }
        }
    }
}
