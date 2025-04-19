//
//  AddFeedView.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 13.04.25.
//

import Common
import SwiftUI

struct AddFeedView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddFeedViewModel

    init(feeds: Binding<[FeedViewModel]>) {
        _viewModel = State(initialValue: AddFeedViewModel(feeds: feeds))
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Add Feed")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
                .overlay { loadingOverlay }
                .alert("Error Adding Feed", isPresented: errorAlertBinding) {
                    Button("OK") {}
                } message: {
                    if case .error(let error) = viewModel.state {
                        Text(error.errorDescription)
                    }
                }
                .onChange(of: viewModel.state) { _, newState in
                    if case .success = newState {
                        dismiss()
                    }
                }
        }
    }
    
    private var content: some View {
        Form {
            Section {
                urlField
            } header: {
                Text("Enter RSS feed URL")
            } footer: {
                footerContent
            }
        }
    }
    
    private var urlField: some View {
        TextField("Feed URL", text: $viewModel.urlString)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .keyboardType(.URL)
            .testId(AccessibilityIdentifier.AddFeed.urlTextField)
    }
    
    private var footerContent: some View {
        VStack(alignment: .leading, spacing: Constants.UI.footerSpacing) {
            Text("Examples (tap to use):")
                .font(.footnote)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: Constants.UI.exampleButtonSpacing) {
                Button("BBC News") {
                    viewModel.urlString = Constants.URLs.bbcNews
                }
                .testId(AccessibilityIdentifier.AddFeed.bbcExampleButton)

                Button("NBC News") {
                    viewModel.urlString = Constants.URLs.nbcNews
                }
                .testId(AccessibilityIdentifier.AddFeed.nbcExampleButton)
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                dismiss()
            }
            .testId(AccessibilityIdentifier.AddFeed.cancelButton)
        }

        ToolbarItem(placement: .confirmationAction) {
            Button("Add") {
                viewModel.addFeed()
            }
            .disabled(!viewModel.isValidURL || viewModel.state == .adding)
            .testId(AccessibilityIdentifier.AddFeed.addButton)
        }
    }
    
    private var loadingOverlay: some View {
        Group {
            if case .adding = viewModel.state {
                ProgressView()
            }
        }
    }
    
    private var errorAlertBinding: Binding<Bool> {
        .init(
            get: {
                if case .error = viewModel.state { return true }
                return false
            },
            set: { show in
                if !show, case .error = viewModel.state {
                    viewModel.state = .idle
                }
            }
        )
    }
}
