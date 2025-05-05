//
//  ExploreError.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 18.04.25.
//

import Common
import Foundation

public enum ExploreError: Error, LocalizedError {
    case fileNotFound
    case decodingFailed(String)
    case invalidURL
    case feedFetchFailed(String)
}

extension ExploreError: AppErrorConvertible {
    public func asAppError() -> AppError {
        switch self {
        case .fileNotFound:
            return .unknown("Feeds file not found")
        case .decodingFailed:
            return .parsingError
        case .invalidURL:
            return .invalidURL
        case .feedFetchFailed(let message):
            return .unknown(message)
        }
    }
}
