//
//  RSSError.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 12.04.25.
//

import Common

public enum RSSError: Error {
    case invalidURL
    case networkError(Error)
    case parsingError(Error)
    case general
}

extension RSSError: AppErrorConvertible {
    public func asAppError() -> AppError {
        switch self {
        case .invalidURL: return .invalidURL
        case .networkError: return .networkError
        case .parsingError: return .parsingError
        case .general: return .general
        }
    }
}
