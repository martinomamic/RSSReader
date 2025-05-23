//
//  AddFeedView.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 13.04.25.
//

import Common
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
                ScrollView {
                    VStack(spacing: 16) {
                        urlInputSection
                        
                        exploreFeedsSection
                    }
                    .padding()
                }
                
            case .error(let error):
                ErrorStateView(error: error) {
                    viewModel.addFeed()
                }
                .testId(AccessibilityIdentifier.AddFeed.addViewErrorView)
                
            case .empty:
                EmptyStateView(
                    title: "Adding Views not possible",
                    systemImage: "tray.empty",
                    description: "No feeds to add"
                )
                .testId(AccessibilityIdentifier.AddFeed.addViewEmptyView)
            }
        }
        .task {
            viewModel.loadExploreFeeds()
        }
        .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
        .navigationTitle(LocalizedStrings.AddFeed.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            cancelButton
            addButton
        }
    }
    
    private var urlInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStrings.AddFeed.urlHeader)
                .font(.headline)
            
            TextField(LocalizedStrings.AddFeed.urlPlaceholder, text: $viewModel.urlString)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .keyboardType(.URL)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .testId(AccessibilityIdentifier.AddFeed.urlTextField)
            
            Button(action: {
                viewModel.addFeed()
            }) {
                HStack {
                    Text(LocalizedStrings.General.add)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isAddButtonDisabled ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .disabled(viewModel.isAddButtonDisabled)
            .testId(AccessibilityIdentifier.AddFeed.addButton)
            .padding(.top, 8)
        }
    }
    
    private var exploreFeedsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Suggested Feeds")
                .font(.headline)
            
            VStack(spacing: 12) {
                ForEach(viewModel.exploreFeeds) { feed in
                    ExploreFeedRow(
                        feed: feed,
                        isAdded: viewModel.isFeedAdded(feed),
                        onAddTapped: {
                            viewModel.addExploreFeed(feed)
                        }
                    )
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
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
