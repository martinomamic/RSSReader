//
//  RSSViewError.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 14.04.25.
//

public enum RSSViewError: Error, Equatable {
    case invalidURL
    case duplicateFeed
    case networkError(String)
    case parsingError(String)
    case unknown(String)
    
    var localizedDescription: String {
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
