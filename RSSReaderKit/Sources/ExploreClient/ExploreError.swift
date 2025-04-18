//
//  ExploreFeedError.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 18.04.25.
//

import Foundation

public enum ExploreError: Error, LocalizedError {
    case fileNotFound
    case decodingFailed(String)
    case invalidURL
    case feedFetchFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Feeds file not found"
        case .decodingFailed(let message):
            return "Failed to decode feeds: \(message)"
        case .invalidURL:
            return "Invalid feed URL"
        case .feedFetchFailed(let message):
            return "Failed to fetch feed: \(message)"
        }
    }
}
