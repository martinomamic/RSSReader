//
//  BackgroundRefreshService.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 03.05.25.
//

import Dependencies
import FeedRepository
import Foundation
import SharedModels
import UserDefaultsClient
import UserNotificationClient

@preconcurrency import BackgroundTasks

actor BackgroundRefreshService {
    private let taskIdentifier = "hr.maminjo.RSSReader.feedrefresh"
    private let refreshInterval: TimeInterval = 15 * 60
    private let maxRetries = 3
    private let isConfigured = LockIsolated(false)
    private let schedulingNeeded = LockIsolated(false)
    private var activeTask: Task<Void, Never>?
    private let lastScheduleAttempt = LockIsolated<Date?>(nil)
    private let debounceInterval: TimeInterval = 3
    
    nonisolated
    func configureOnLaunch() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: taskIdentifier,
            using: nil
        ) { [weak self] task in
            guard let bgTask = task as? BGAppRefreshTask else {
                return
            }
            
            let completeTask: @Sendable (Bool) -> Void = { success in
                Task { @MainActor in
                    bgTask.setTaskCompleted(success: success)
                }
            }
            
            let expireTask: @Sendable () -> Void = {
                Task {
                    bgTask.expirationHandler?()
                }
            }
            
            bgTask.expirationHandler = expireTask
            
            Task { @MainActor [weak self] in
                await self?.handleAppRefresh(
                    identifier: bgTask.identifier,
                    complete: completeTask,
                    expire: expireTask
                )
            }
        }
        
        isConfigured.setValue(true)
        Task {
            await scheduleAppRefreshIfNeeded()
        }
    }
    
    nonisolated
    func scheduleAppRefresh() {
        let now = Date()
        if let lastAttempt = lastScheduleAttempt.value,
            now.timeIntervalSince(lastAttempt) < debounceInterval {
            return
        }
        lastScheduleAttempt.setValue(now)

        guard !schedulingNeeded.value else { return }
        schedulingNeeded.setValue(true)
        Task { await attemptScheduling() }
    }
    
    private func attemptScheduling() async {
        guard isConfigured.value else {
            return
        }
        @Dependency(\.feedRepository) var repository
        
        do {
            let feeds = try await repository.getCurrentFeeds()
            let enabledFeeds = feeds.filter(\.notificationsEnabled)
            
            guard !enabledFeeds.isEmpty else {
                schedulingNeeded.setValue(false)
                return
            }
            
            let requests = await BGTaskScheduler.shared.pendingTaskRequests()
            guard !requests.contains(where: { $0.identifier == taskIdentifier }) else {
                schedulingNeeded.setValue(false)
                return
            }
            
            BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: taskIdentifier)
            
            try await MainActor.run {
                let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
                request.earliestBeginDate = Date(timeIntervalSinceNow: refreshInterval)
                
                try BGTaskScheduler.shared.submit(request)
                schedulingNeeded.setValue(false)
            }
        } catch {
            schedulingNeeded.setValue(false)
        }
    }
    
    private func handleAppRefresh(
        identifier: String,
        complete: @escaping @Sendable (Bool) -> Void,
        expire: @escaping @Sendable () -> Void
    ) async {
        activeTask?.cancel()
        
        let refreshTask = Task { [complete] in
            do {
                try await refreshFeeds()
                complete(true)
                
                scheduleAppRefresh()
            } catch {
                complete(false)
                
                scheduleAppRefresh()
            }
        }
        
        activeTask = refreshTask
        
        if Task.isCancelled {
            expire()
            complete(false)
            scheduleAppRefresh()
        }
    }
    
    private func refreshFeeds() async throws {
        @Dependency(\.feedRepository) var repository
        @Dependency(\.userNotifications) var userNotifications
        @Dependency(\.userDefaults) var userDefaults
        
        let feeds = try await repository.getCurrentFeeds()
        let enabledFeeds = feeds.filter(\.notificationsEnabled)
        
        guard !enabledFeeds.isEmpty else { return }
        
        let currentTime = Date()
        let lastCheckTime = userDefaults.getLastNotificationCheckTime() ?? currentTime
        
        userDefaults.setLastNotificationCheckTime(currentTime)
        
        var delayOffset = 0.5
        var errorCount = 0
        
        for feed in enabledFeeds {
            do {
                let items = try await repository.fetchItems(feed)
                
                let newItems = items.filter { item in
                    guard let pubDate = item.pubDate else { return false }
                    return pubDate > lastCheckTime
                }
                
                for item in newItems {
                    do {
                        try await userNotifications.sendTestNotification(
                            item.title,
                            item.description ?? "",
                            delayOffset
                        )
                        delayOffset += 0.5
                    } catch {
                        errorCount += 1
                    }
                }
            } catch {
                errorCount += 1
            }
        }
        
        if errorCount > 0 {
            throw NSError(
                domain: "BackgroundRefreshService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to process \(errorCount) feeds"]
            )
        }
    }
    
    func manuallyTriggerBackgroundRefresh() async -> Bool {
        do {
            try await refreshFeeds()
            return true
        } catch {
            return false
        }
    }
    
    func sceneDidEnterBackground() {
        guard schedulingNeeded.value else { return }
        
        Task {
            await attemptScheduling()
        }
    }
    
    func scheduleAppRefreshIfNeeded() async {
        guard isConfigured.value else { return }
        
        @Dependency(\.feedRepository) var repository
        
        do {
            let feeds = try await repository.getCurrentFeeds()
            let enabledFeeds = feeds.filter(\.notificationsEnabled)
            
            guard !enabledFeeds.isEmpty else { return }

            BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: taskIdentifier)
            
            let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
            request.earliestBeginDate = Date(timeIntervalSinceNow: refreshInterval)
        
            try await MainActor.run {
                try BGTaskScheduler.shared.submit(request)
            }
        } catch {
            #if DEBUG
            print("Failed to schedule background refresh: \(error)")
            #endif
        }
    }
    
#if DEBUG
    func testFeedParsing() async -> String {
        do {
            @Dependency(\.persistenceClient.loadFeeds) var loadSavedFeeds
            @Dependency(\.rssClient.fetchFeedItems) var fetchFeedItems
            
            var results = ""
            let feeds = try await loadSavedFeeds()
            results += "📊 Stored feeds: \(feeds.count)\n"
            
            if feeds.isEmpty {
                results += "ℹ️ No stored feeds to test\n"
            } else {
                for (index, feed) in feeds.enumerated() {
                    do {
                        let items = try await fetchFeedItems(feed.url)
                        let status = "✅ \(items.count) items"
                        results += "\(index + 1). \(feed.title ?? feed.url.absoluteString): \(status)\n"
                    } catch {
                        results += "\(index + 1). \(feed.title ?? feed.url.absoluteString): ❌ Error: \(error)\n"
                    }
                }
            }
            
            return results
        } catch {
            return "❌ Error testing feeds: \(error.localizedDescription)"
        }
    }
    
    func getBackgroundTaskStatus() async -> String {
        if isConfigured.value {
            return "Background task scheduler is configured"
        } else {
            return "Background task scheduler is not configured"
        }
    }
#endif
}
