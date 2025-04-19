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
            Form {
                Section {
                    TextField(LocalizedStrings.AddFeed.urlPlaceholder, text: $viewModel.urlString)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .testId(AccessibilityIdentifier.AddFeed.urlTextField)
                } header: {
                    Text(LocalizedStrings.AddFeed.urlHeader)
                } footer: {
                    VStack(alignment: .leading, spacing: Constants.UI.footerSpacing) {
                        Text(LocalizedStrings.AddFeed.examplesHeader)
                            .font(.footnote)
                            .foregroundColor(.secondary)

                        VStack(alignment: .leading, spacing: Constants.UI.exampleButtonSpacing) {
                            Button(LocalizedStrings.AddFeed.bbcNews) {
                                viewModel.urlString = Constants.URLs.bbcNews
                            }
                            .testId(AccessibilityIdentifier.AddFeed.bbcExampleButton)

                            Button(LocalizedStrings.AddFeed.nbcNews) {
                                viewModel.urlString = Constants.URLs.nbcNews
                            }
                            .testId(AccessibilityIdentifier.AddFeed.nbcExampleButton)
                        }
                    }
                }
            }
            .navigationTitle(LocalizedStrings.AddFeed.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizedStrings.General.cancel) {
                        dismiss()
                    }
                    .testId(AccessibilityIdentifier.AddFeed.cancelButton)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(LocalizedStrings.General.add) {
                        viewModel.addFeed()
                    }
                    .disabled(!viewModel.isValidURL || viewModel.state == .adding)
                    .testId(AccessibilityIdentifier.AddFeed.addButton)
                }
            }
            .overlay {
                if case .adding = viewModel.state {
                    ProgressView()
                }
            }
            .alert(LocalizedStrings.AddFeed.errorTitle, isPresented: .init(
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
                Button(LocalizedStrings.General.ok) {}
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
}
