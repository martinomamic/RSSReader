import Foundation

public enum BackgroundTasksError: Error {
    case notAuthorized
    case noEnabledFeeds
    case taskAlreadyScheduled
    case schedulingFailed(Error)
}

extension BackgroundTasksError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Notifications not authorized"
        case .noEnabledFeeds:
            return "No feeds with notifications enabled"
        case .taskAlreadyScheduled:
            return "Background task already scheduled"
        case .schedulingFailed(let error):
            return "Failed to schedule background task: \(error.localizedDescription)"
        }
    }
}