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
    var state: ViewState<Bool> = .idle
    
    init() {}
    
    var isAddButtonDisabled: Bool {
        !isValidURL
    }
    
    var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }
    
    var shouldDismiss: Bool {
        if case .content(true) = state { return true }
        return false
    }
    
    private var isValidURL: Bool {
        guard !urlString.isEmpty,
              let url = URL(string: urlString) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    func addFeed() {
        guard let url = URL(string: urlString) else {
            state = .error(AppError.invalidURL)
            return
        }
        
        addFeedTask?.cancel()
        state = .loading
        
        addFeedTask = Task {
            do {
                try await feedRepository.add(url)
                state = .content(true)
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
