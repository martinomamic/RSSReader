//
//  AppError.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 22.04.25.
//

import Foundation

/// A unified error type for presenting user-friendly error messages across the app
public enum AppError: Error, Equatable, LocalizedError, Identifiable {
    public var id: String { errorDescription }
    
    case invalidURL
    case networkError
    case parsingError
    case duplicateFeed
    case feedNotFound
    case permissionDenied
    case general
    case unknown(String)
    
    /// User-friendly error message
    public var errorDescription: String {
        switch self {
        case .invalidURL:
            return "Please enter a valid URL"
        case .networkError:
            return "Unable to connect to server. Please check your internet connection and try again."
        case .parsingError:
            return "Unable to read feed content. The feed format may be unsupported."
        case .duplicateFeed:
            return "This feed is already in your list"
        case .feedNotFound:
            return "Feed not found"
        case .permissionDenied:
            return "Notifications permission denied. Please enable notifications in Settings."
        case .general:
            return "Something went wrong. Please try again."
        case .unknown(let message):
            return message
        }
    }
}
