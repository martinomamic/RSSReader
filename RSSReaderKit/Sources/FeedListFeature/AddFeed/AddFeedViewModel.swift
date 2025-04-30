//
//  AddFeedViewModel.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 13.04.25.
//

import Common
import Dependencies
import Foundation
import SharedModels
import SwiftUI

enum AddFeedState: Equatable {
    case idle
    case adding
    case error(AppError)
    case success
}

enum ExampleURL {
    case bbc
    case nbc
}

@MainActor @Observable
class AddFeedViewModel {
    @ObservationIgnored
    @Dependency(\.feedRepository) private var feedRepository
    
    private var addFeedTask: Task<Void, Never>?
    
    var urlString: String = ""
    var state: AddFeedState = .idle
    
    init() {}
    
    var isAddButtonDisabled: Bool {
        !isValidURL
    }
    
    var isLoading: Bool {
        state == .adding
    }
    
    var shouldDismiss: Bool {
        state == .success
    }
    
    var errorAlertBinding: Binding<Bool> {
        .init(
            get: { if case .error = self.state { return true } else { return false } },
            set: { show in if !show { self.dismissError() } }
        )
    }
    
    private var isValidURL: Bool {
        guard !urlString.isEmpty,
              let url = URL(string: urlString) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    func setExampleURL(_ example: ExampleURL) {
        switch example {
        case .bbc:
            urlString = Constants.URLs.bbcNews
        case .nbc:
            urlString = Constants.URLs.nbcNews
        }
    }
    
    func dismissError() {
        state = .idle
    }
    
    func addFeed() {
        guard let url = URL(string: urlString) else {
            state = .error(.invalidURL)
            return
        }
        
        addFeedTask?.cancel()
        state = .adding
        
        addFeedTask = Task {
            do {
                try await feedRepository.add(url)
                state = .success
            } catch {
                state = .error(ErrorUtils.toAppError(error))
            }
        }
    }
}


#if DEBUG
extension AddFeedViewModel {
    @MainActor
    func waitForAddToFinish() async {
        await addFeedTask?.value
    }
}

#endif
