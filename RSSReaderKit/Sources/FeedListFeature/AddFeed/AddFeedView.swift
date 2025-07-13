//
//  AddFeedView.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 13.04.25.
//

import Common
import SwiftUI
import SharedUI
import ToastFeature

struct AddFeedView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel = AddFeedViewModel()
    
    var body: some View {
        VStack {
            switch viewModel.state {
            case .loading:
                addForm
                    .overlay {
                        ProgressView()
                    }
                
            case .content:
                addForm
                
            case .error(let error):
                ErrorStateView(error: error) {
                    viewModel.addFeed()
                }
                .testId(AccessibilityIdentifier.AddFeed.addViewErrorView)
                
            case .empty:
                EmptyStateView(
                    title: LocalizedStrings.AddFeed.emptyTitle,
                    systemImage: "tray.empty",
                    description: LocalizedStrings.AddFeed.emptyDescription
                )
                .testId(AccessibilityIdentifier.AddFeed.addViewEmptyView)
            }
        }
        .toastOverlay(viewModel.toastService)
        .task {
            viewModel.loadExploreFeeds()
        }
        .navigationTitle(LocalizedStrings.AddFeed.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            cancelButton
            addButton
        }
    }
    
    private var addForm: some View {
        ScrollView {
            VStack(spacing: 16) {
                urlInputSection
                
                if !viewModel.exploreFeeds.isEmpty {
                    exploreFeedsSection
                }
            }
            .padding()
        }
    }
    
    private var urlInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStrings.AddFeed.urlHeader)
                .font(.headline)
                .padding(.vertical, 8)
            
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
            Text(LocalizedStrings.AddFeed.suggestedFeeds)
                .font(.headline)
            
            VStack(spacing: 0) {
                ForEach(viewModel.exploreFeeds) { feed in
                    VStack(spacing: 0) {
                        ExploreFeedRow(
                            feed: feed,
                            isAdded: viewModel.isFeedAdded(feed),
                            isProcessing: viewModel.isProcessingFeed(feed),
                            onTapped: {
                                viewModel.addExploreFeed(feed)
                            }
                        )
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        if feed.id != viewModel.exploreFeeds.last?.id {
                            Divider()
                                .padding(.leading)
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.exploreFeeds.map(\.url))
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
