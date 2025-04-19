//
//  RSSViewError.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 14.04.25.
//

import Foundation

public enum RSSViewError: Error, Equatable, LocalizedError, Identifiable {
    public var id: String { errorDescription }

    case invalidURL
    case duplicateFeed
    case networkError(String)
    case parsingError(String)
    case unknown(String)

    public var errorDescription: String {
        switch self {
        case .invalidURL:
            return "Please enter a valid URL"
        case .duplicateFeed:
            return "This feed is already in your list"
        case .networkError(let message):
            return "Network error: \(message)"
        case .parsingError(let message):
            return "Failed to parse feed: \(message)"
        case .unknown(let message):
            return message
        }
    }
}
