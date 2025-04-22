 //
//  ErrorUtils.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 22.04.25.
//

import Foundation

/// Utility functions to handle errors consistently across the app
public enum ErrorUtils {
    /// Converts any error to AppError
    /// - Parameter error: The original error
    /// - Returns: A user-friendly AppError
    public static func toAppError(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }
        
        if let errorWithConversion = error as? AppErrorConvertible {
            return errorWithConversion.asAppError()
        }
        
        return .unknown(error.localizedDescription)
    }
}

/// Protocol for errors that can be converted to AppError
public protocol AppErrorConvertible {
    func asAppError() -> AppError
}
