//
//  ViewState.swift
//  RSSReaderKit
//
//  Created by Martino Mamic on 05.05.25.
//

import Common
import Foundation

public enum ViewState<T>: Equatable where T: Equatable {
    case loading
    case loaded(T)
    case error(AppError)
    case empty
    
    public static func == (lhs: ViewState<T>, rhs: ViewState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.loaded(let lData), .loaded(let rData)):
            return lData == rData
        case (.error(let lError), .error(let rError)):
            return lError == rError
        case (.empty, .empty):
            return true
        default:
            return false
        }
    }
}
