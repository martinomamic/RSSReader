//
//  FeedItemsState.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 14.04.25.
//

import Common
import SharedModels

enum FeedItemsState: Equatable {
    case loading
    case loaded([FeedItem])
    case error(RSSViewError)
    case empty
    
    static func == (lhs: FeedItemsState, rhs: FeedItemsState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading), (.empty, .empty):
            return true
        case (.loaded(let lhsItems), .loaded(let rhsItems)):
            return lhsItems.count == rhsItems.count
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}
