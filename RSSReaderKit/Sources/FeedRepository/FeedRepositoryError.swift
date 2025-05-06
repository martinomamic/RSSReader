//
//  FeedRepositoryError.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 27.04.25.
//

import Foundation

public enum FeedRepositoryError: LocalizedError {
    case feedAlreadyExists
    case failedToFetch
    case failedToSave
    case failedToDelete
    case feedNotFound
    case invalidURL
    
    public var errorDescription: String? {
        switch self {
        case .failedToFetch:
            return "Failed to fetch feed"
        case .failedToSave:
            return "Failed to save feed"
        case .failedToDelete:
            return "Failed to delete feed"
        case .feedNotFound:
            return "Feed not found"
        case .invalidURL:
            return "Invalid URL"
        case .feedAlreadyExists:
            return "Feed already exists"
        }
    }
}
