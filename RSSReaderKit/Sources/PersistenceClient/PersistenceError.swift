//
//  PersistenceError.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 17.04.25.
//

import Common

public enum PersistenceError: Error, Equatable {
    case operationFailed(String)
}

extension PersistenceError: AppErrorConvertible {
    public func asAppError() -> AppError {
        switch self {
        case let .operationFailed(message):
            return .unknown(message)
        }
    }
}
