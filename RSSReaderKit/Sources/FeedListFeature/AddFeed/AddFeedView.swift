//
//  AddFeedView.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 13.04.25.
//

import Common
import ExploreFeature
import SwiftUI
import SharedUI

struct AddFeedView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel = AddFeedViewModel()
    
    var body: some View {
        VStack {
            switch viewModel.state {
            case .loading:
                ProgressView()
                
            case .content:
                addFeedForm
                
            case .error(let error):
                ErrorStateView(error: error) {
                    viewModel.addFeed()
                }
                
            case .empty:
                EmptyStateView(
                    title: "Adding Views not possible",
                    systemImage: "tray.empty",
                    description: "No feeds to add"
                )
            }
        }
        .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
    }
    
    private var addFeedForm: some View {
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
                
            }
        }
        .navigationTitle(LocalizedStrings.AddFeed.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            cancelButton
            addButton
        }
    }
    
    private var addButton: ToolbarItem<(), some View> {
        ToolbarItem(placement: .confirmationAction) {
            Button(LocalizedStrings.General.add) {
                viewModel.addFeed()
            }
            .disabled(viewModel.isAddButtonDisabled)
            .testId(AccessibilityIdentifier.AddFeed.addButton)
        }
    }
    
    private var cancelButton: ToolbarItem<(), some View> {
        ToolbarItem(placement: .cancellationAction) {
            Button(LocalizedStrings.General.cancel) {
                dismiss()
            }
            .testId(AccessibilityIdentifier.AddFeed.cancelButton)
        }
    }
}
