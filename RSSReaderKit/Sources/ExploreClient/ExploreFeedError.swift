//
//  ExploreFeedError.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 18.04.25.
//

public enum ExploreFeedError: Error, LocalizedError {
    case fileNotFound
    case decodingFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Feeds file not found"
        case .decodingFailed(let message):
            return "Failed to decode feeds: \(message)"
        }
    }
}
