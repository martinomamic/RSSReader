//
//  PersistenceError.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 17.04.25.
//

import Common

public enum PersistenceError: Error, Equatable {
    case saveFailed(String)
    case loadFailed(String)
}

extension PersistenceError: AppErrorConvertible {
    public func asAppError() -> AppError {
        switch self {
        case .saveFailed:
            return .unknown("Failed to save data")
        case .loadFailed:
            return .unknown("Failed to load data")
        }
    }
}
