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
                    VStack(alignment: .leading, spacing: Constants.UI.footerSpacing) {
                        Text("Examples (tap to use):")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: Constants.UI.exampleButtonSpacing) {
                            Button("BBC News") {
                                viewModel.urlString = Constants.URLs.bbcNews
                            }
                            .font(.footnote)
                            
                            Button("NBC News") {
                                viewModel.urlString = Constants.URLs.nbcNews
                            }
                            .font(.footnote)
                        }
                    }
                }
            }
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
                    .disabled(!viewModel.isValidURL || viewModel.state == .adding)
                }
            }
            .overlay {
                if case .adding = viewModel.state {
                    ProgressView()
                }
            }
            .alert("Error Adding Feed", isPresented: .init(
                get: {
                    if case .error = viewModel.state { return true }
                    return false
                },
                set: { show in
                    if !show, case .error = viewModel.state {
                        viewModel.state = .idle
                    }
                }
            )) {
                Button("OK") {}
            } message: {
                if case .error(let error) = viewModel.state {
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
