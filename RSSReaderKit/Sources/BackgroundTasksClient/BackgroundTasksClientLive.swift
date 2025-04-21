import BackgroundTasks
import Dependencies
import Foundation
import NotificationClient
import PersistenceClient
import SharedModels
import UserNotifications

extension BackgroundTasksClient {
    public static func live() -> Self {
        let feedRefreshTaskIdentifier = "com.maminjo.feedrefresh"
        let refreshInterval: TimeInterval = 15 * 60 // 15 minutes
        
        actor BackgroundTaskState {
            var isConfigured = false
            var currentTask: BGAppRefreshTask?
            
            func configure() {
                guard !isConfigured else { return }
                BGTaskScheduler.shared.register(
                    forTaskWithIdentifier: feedRefreshTaskIdentifier,
                    using: nil
                ) { task in
                    if let bgTask = task as? BGAppRefreshTask {
                        Task {
                            await handleAppRefresh(task: bgTask)
                        }
                    }
                }
                isConfigured = true
            }
            
            func setCurrentTask(_ task: BGAppRefreshTask?) {
                currentTask = task
            }
            
            func hasScheduledTask() -> Bool {
                currentTask != nil
            }
        }
        
        let state = BackgroundTaskState()
        
        return Self(
            configure: {
                await state.configure()
            },
            scheduleAppRefresh: {
                @Dependency(\.notificationCenter) var notificationCenter
                @Dependency(\.persistenceClient.loadFeeds) var loadFeeds
                
                // Check notification authorization
                let settings = await notificationCenter.notificationSettings()
                guard settings.authorizationStatus == .authorized else { return }
                
                // Check for feeds with notifications enabled on main actor
                let feeds = try await MainActor.run {
                    try await loadFeeds()
                }
                guard feeds.contains(where: \.notificationsEnabled) else { return }
                
                // Check if task already scheduled
                guard !await state.hasScheduledTask() else { return }
                
                let request = BGAppRefreshTaskRequest(identifier: feedRefreshTaskIdentifier)
                request.earliestBeginDate = Date(timeIntervalSinceNow: refreshInterval)
                
                do {
                    try await BGTaskScheduler.shared.submit(request)
                } catch {
                    print("Could not schedule app refresh: \(error)")
                }
            },
            cancelScheduledRefresh: {
                BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: feedRefreshTaskIdentifier)
                await state.setCurrentTask(nil)
            },
            hasScheduledTask: {
                await state.hasScheduledTask()
            }
        )
        
        @Sendable func handleAppRefresh(task: BGAppRefreshTask) async {
            await state.setCurrentTask(task)
            
            let refreshTask = Task {
                do {
                    @Dependency(\.notificationClient) var notificationClient
                    @Dependency(\.persistenceClient.loadFeeds) var loadFeeds
                    
                    // Check feeds on main actor
                    let feeds = try await MainActor.run {
                        try await loadFeeds()
                    }
                    
                    guard feeds.contains(where: \.notificationsEnabled) else {
                        task.setTaskCompleted(success: true)
                        await state.setCurrentTask(nil)
                        return
                    }
                    
                    try await notificationClient.checkForNewItems()
                    task.setTaskCompleted(success: true)
                    
                    // Schedule next refresh if conditions still met
                    await scheduleAppRefresh()
                } catch {
                    task.setTaskCompleted(success: false)
                }
                await state.setCurrentTask(nil)
            }
            
            task.expirationHandler = {
                refreshTask.cancel()
                Task {
                    await state.setCurrentTask(nil)
                    // Try to schedule next refresh even if this one expired
                    await scheduleAppRefresh()
                }
            }
        }
    }
}