import BackgroundTasks
import Dependencies
import Foundation
import NotificationClient
import PersistenceClient
import SharedModels
import UserNotifications

extension BackgroundTasksClient {
    public static func live() -> Self {
        @Dependency(\.notificationClient.checkForNewItems) var checkForNewItems
        @Dependency(\.notificationClient.getAuthorizationStatus) var getAuthorizationStatus
        @Dependency(\.persistenceClient.loadFeeds) var loadFeeds
        
        actor State {
            private var currentTask: BGAppRefreshTask?
            let identifier = "com.maminjo.feedrefresh"
            let refreshInterval: TimeInterval = 15 * 60
            
            func setCurrentTask(_ task: BGAppRefreshTask?) {
                currentTask = task
            }
            
            func cancelCurrentTask() {
                currentTask?.setTaskCompleted(success: false)
                currentTask = nil
            }
            
            func hasTask() -> Bool {
                currentTask != nil
            }
        }
        
        let state = State()
        
        @Sendable func handleBackgroundTask(_ task: BGAppRefreshTask) async {
            defer { task.setTaskCompleted(success: true) }
            
            do {
                let feeds = try await loadFeeds()
                guard feeds.contains(where: \.notificationsEnabled) else { return }
                
                try await checkForNewItems()
                try await scheduleNextRefresh()
            } catch {
                task.setTaskCompleted(success: false)
            }
        }
        
        @Sendable func scheduleNextRefresh() async throws {
            guard await getAuthorizationStatus() else { return }
            
            let identifier =  state.identifier
            let interval =  state.refreshInterval
            
            let request = BGAppRefreshTaskRequest(identifier: identifier)
            request.earliestBeginDate = Date(timeIntervalSinceNow: interval)
            
            try await submitBackgroundTask(request)
        }
        
        @Sendable func submitBackgroundTask(_ request: BGAppRefreshTaskRequest) async throws {
            try await withCheckedThrowingContinuation { continuation in
                do {
                    try BGTaskScheduler.shared.submit(request)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
        
        return Self(
            configure: {
                let identifier =  state.identifier
                
                BGTaskScheduler.shared.register(
                    forTaskWithIdentifier: identifier,
                    using: nil
                ) { task in
                    guard let bgTask = task as? BGAppRefreshTask else { return }
                    Task {
                        await state.setCurrentTask(bgTask)
                        await handleBackgroundTask(bgTask)
                        await state.setCurrentTask(nil)
                    }
                    
                    bgTask.expirationHandler = {
                        Task {
                            await state.cancelCurrentTask()
                            try? await scheduleNextRefresh()
                        }
                    }
                }
            },
            scheduleAppRefresh: {
                guard await !state.hasTask(),
                      await getAuthorizationStatus() else { return }
                
                let feeds = try? await loadFeeds()
                guard let feeds = feeds,
                      feeds.contains(where: \.notificationsEnabled) else { return }
                
                try? await scheduleNextRefresh()
            },
            cancelScheduledRefresh: {
                let identifier =  state.identifier
                BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: identifier)
                await state.cancelCurrentTask()
            },
            hasScheduledTask: {
                await state.hasTask()
            }
        )
    }
}
