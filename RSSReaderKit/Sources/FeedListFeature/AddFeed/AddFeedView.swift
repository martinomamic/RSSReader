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
                                viewModel.setExampleURL(.bbc)
                            }
                            .testId(AccessibilityIdentifier.AddFeed.bbcExampleButton)

                            Button(LocalizedStrings.AddFeed.nbcNews) {
                                viewModel.setExampleURL(.nbc)
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
                    .disabled(viewModel.isAddButtonDisabled)
                    .testId(AccessibilityIdentifier.AddFeed.addButton)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .alert(LocalizedStrings.AddFeed.errorTitle, isPresented: viewModel.errorAlertBinding) {
                Button(LocalizedStrings.General.ok) {
                    viewModel.dismissError()
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
                if shouldDismiss {
                    dismiss()
                }
            }
        }
    }
}
