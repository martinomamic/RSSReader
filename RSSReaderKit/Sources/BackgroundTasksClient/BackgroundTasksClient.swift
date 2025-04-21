import BackgroundTasks
import Dependencies
import Foundation
import NotificationClient
import PersistenceClient
import SharedModels

public struct BackgroundTasksClient {
    public var configure: @Sendable () async -> Void
    public var scheduleAppRefresh: @Sendable () async -> Void
    public var cancelScheduledRefresh: @Sendable () async -> Void
    public var hasScheduledTask: @Sendable () async -> Bool
    
    public init(
        configure: @escaping @Sendable () async -> Void,
        scheduleAppRefresh: @escaping @Sendable () async -> Void,
        cancelScheduledRefresh: @escaping @Sendable () async -> Void,
        hasScheduledTask: @escaping @Sendable () async -> Bool
    ) {
        self.configure = configure
        self.scheduleAppRefresh = scheduleAppRefresh
        self.cancelScheduledRefresh = cancelScheduledRefresh
        self.hasScheduledTask = hasScheduledTask
    }
}

// MARK: - Dependency Key
extension BackgroundTasksClient: DependencyKey {
    public static var liveValue: Self { .live() }
    
    public static var testValue: Self {
        Self(
            configure: {},
            scheduleAppRefresh: {},
            cancelScheduledRefresh: {},
            hasScheduledTask: { false }
        )
    }
}

extension DependencyValues {
    public var backgroundTasksClient: BackgroundTasksClient {
        get { self[BackgroundTasksClient.self] }
        set { self[BackgroundTasksClient.self] = newValue }
    }
}