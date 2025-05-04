//
//  NotificationError.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 17.04.25.
//

import Common

public enum NotificationError: Error {
    case permissionDenied
}

extension NotificationError: AppErrorConvertible {
    public func asAppError() -> AppError {
        switch self {
        case .permissionDenied:
            return .permissionDenied
        }
    }
}
