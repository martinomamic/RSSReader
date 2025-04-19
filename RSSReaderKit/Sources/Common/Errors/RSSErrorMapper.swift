//
//  RSSErrorMapper.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 14.04.25.
//

import RSSClient

public enum RSSErrorMapper {
    public static func map(_ error: Error) -> RSSViewError {
        switch error {
        case let rssError as RSSError:
            return mapRSSError(rssError)
        default:
            return .unknown(error.localizedDescription)
        }
    }
    
    private static func mapRSSError(_ error: RSSError) -> RSSViewError {
        switch error {
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
}
