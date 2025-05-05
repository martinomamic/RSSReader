//
//  BackgroundRefreshService.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 03.05.25.
//

import Dependencies
import Foundation
import FeedRepository
import SharedModels
import UserNotificationClient
import UserDefaultsClient

@preconcurrency import BackgroundTasks
import OSLog
import Swift

actor BackgroundRefreshService {
    private let taskIdentifier = "hr.maminjo.RSSReader.feedrefresh"
    private let refreshInterval: TimeInterval = 15 * 60 // 15 minutes
    private let maxRetries = 3
    private let isConfigured = LockIsolated(false)
    private let schedulingNeeded = LockIsolated(false)
    private var activeTask: Task<Void, Never>?
    private let logger = Logger(subsystem: "hr.maminjo.RSSReader", category: "BackgroundRefresh")
    private let lastScheduleAttempt = LockIsolated<Date?>(nil)
    private let debounceInterval: TimeInterval = 3 // seconds
    
    nonisolated
    func configureOnLaunch() {
        logger.info("Attempting to configure background refresh during launch")
        
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: taskIdentifier,
            using: nil
        ) { [weak self] task in
            guard let bgTask = task as? BGAppRefreshTask else {
                self?.logger.error("Invalid task type received")
                return
            }
            
            self?.logger.info("Background task started: \(bgTask.identifier)")
            
            let completeTask: @Sendable (Bool) -> Void = { success in
                Task { @MainActor in
                    self?.logger.info("Completing background task with success: \(success)")
                    bgTask.setTaskCompleted(success: success)
                }
            }
            
            let expireTask: @Sendable () -> Void = {
                Task { @MainActor in
                    self?.logger.warning("Background task expired")
                    bgTask.expirationHandler?()
                }
            }
            
            // Set expiration handler first
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
        logger.info("Background task scheduler configured")
        
        // Initial scheduling
        Task {
            await scheduleAppRefreshIfNeeded()
        }
    }
    
    nonisolated
    func scheduleAppRefresh() {
        let now = Date()
        if let last = lastScheduleAttempt.value, now.timeIntervalSince(last) < debounceInterval {
            logger.info("Debounced background refresh request (too soon since last: \(now.timeIntervalSince(last)))")
            return
        }
        lastScheduleAttempt.setValue(now)

        // Only proceed if we are not already scheduling
        guard !schedulingNeeded.value else {
            logger.info("Scheduling already in progress, skipping duplicate call")
            return
        }
        logger.info("scheduleAppRefresh called - marking scheduling needed")
        schedulingNeeded.setValue(true)
        Task { await attemptScheduling() }
    }
    
    private func attemptScheduling() async {
        guard isConfigured.value else {
            logger.warning("Cannot schedule refresh - service not configured")
            return
        }
        @Dependency(\.feedRepository) var repository
        
        do {
            let feeds = try await repository.getCurrentFeeds()
            let enabledFeeds = feeds.filter(\.notificationsEnabled)
            
            guard !enabledFeeds.isEmpty else {
                logger.info("No feeds with notifications enabled, clearing scheduling needed flag")
                schedulingNeeded.setValue(false)
                return
            }
            
            let requests = await BGTaskScheduler.shared.pendingTaskRequests()
            if requests.contains(where: { $0.identifier == taskIdentifier }) {
                logger.info("A BGAppRefreshTaskRequest is already pending, skipping scheduling.")
                schedulingNeeded.setValue(false)
                return
            }
            
            // Cancel existing tasks first
            BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: taskIdentifier)
            
            try await MainActor.run {
                let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
                request.earliestBeginDate = Date(timeIntervalSinceNow: 60) // Start with 1 minute for testing
                
                logger.info("Submitting BGTask request")
                try BGTaskScheduler.shared.submit(request)
                logger.info("Successfully scheduled background refresh")
                schedulingNeeded.setValue(false)
            }
        } catch {
            logger.error("Failed to schedule background refresh: \(error)")
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
                
                // Schedule next refresh
                scheduleAppRefresh()
            } catch {
                logger.error("Feed refresh failed: \(error)")
                complete(false)
                
                // Still try to schedule next refresh even on failure
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
                        logger.error("Failed to send notification for item: \(error)")
                        errorCount += 1
                    }
                }
            } catch {
                logger.error("Failed to fetch items for feed \(feed.url): \(error)")
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
        logger.info("Scene entered background - checking if scheduling is needed")
        
        guard schedulingNeeded.value else {
            logger.info("No scheduling needed")
            return
        }
        
        Task {
            await attemptScheduling()
        }
    }
    
    func scheduleAppRefreshIfNeeded() async {
        guard isConfigured.value else {
            logger.warning("Cannot schedule refresh - service not configured")
            return
        }
        
        @Dependency(\.feedRepository) var repository
        
        do {
            let feeds = try await repository.getCurrentFeeds()
            let enabledFeeds = feeds.filter(\.notificationsEnabled)
            logger.info("Scheduling check - Total feeds: \(feeds.count), Enabled: \(enabledFeeds.count)")
            
            for feed in feeds {
                logger.info("Feed \(feed.url.absoluteString): notifications \(feed.notificationsEnabled ? "enabled" : "disabled")")
            }
            
            guard !enabledFeeds.isEmpty else {
                logger.info("No feeds with notifications enabled, skipping refresh schedule")
                return
            }
            
            // Remove any existing scheduled tasks first
            BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: taskIdentifier)
            logger.info("Cancelled existing scheduled tasks")
            
            let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
            // Use a shorter interval for initial schedule
            request.earliestBeginDate = Date(timeIntervalSinceNow: 60)
            
            logger.info("Attempting to submit BGTask request with date: \(request.earliestBeginDate?.description ?? "nil")")
            
            // Ensure we're fully on MainActor and give time for app to stabilize
            try await MainActor.run {
                try BGTaskScheduler.shared.submit(request)
                logger.info("Successfully scheduled background refresh")
            }
        } catch {
            logger.error("Failed to schedule background refresh: \(error)")
            if let nsError = error as NSError? {
                logger.error("Error details - Domain: \(nsError.domain), Code: \(nsError.code), Description: \(nsError.localizedDescription)")
                if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? Error {
                    logger.error("Underlying error: \(underlyingError)")
                }
            }
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
