//
//  RSSErrorMapper.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 14.04.25.
//

import RSSClient

struct RSSErrorMapper {
    static func mapToViewError(_ error: Error) -> RSSViewError {
        if let rssError = error as? RSSError {
            switch rssError {
            case .invalidURL:
                return .invalidURL
            case .networkError(let underlyingError):
                return .networkError(underlyingError.localizedDescription)
            case .parsingError(let underlyingError):
                return .parsingError(underlyingError.localizedDescription)
            case .unknown:
                return .unknown("An unknown error occurred")
            }
        }
        return .unknown(error.localizedDescription)
    }
}
