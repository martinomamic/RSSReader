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

actor BackgroundRefreshService {
    private let taskIdentifier = "hr.maminjo.RSSReader.feedrefresh"
    private let refreshInterval: TimeInterval = 15 * 60
    private var isConfigured = false
    private var activeTask: Task<Void, Never>?
    
    nonisolated
    func configureOnLaunch() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: taskIdentifier,
            using: nil
        ) { [weak self] task in
            guard let bgTask = task as? BGAppRefreshTask else { return }
            
            let completeTask: @Sendable (Bool) -> Void = { success in
                Task { @MainActor in
                    bgTask.setTaskCompleted(success: success)
                }
            }
            
            let expireTask: @Sendable () -> Void = {
                Task { @MainActor in
                    bgTask.expirationHandler?()
                }
            }
            
            Task { @MainActor [weak self] in
                await self?.handleAppRefresh(
                    identifier: bgTask.identifier,
                    complete: completeTask,
                    expire: expireTask
                )
            }
        }
        
        Task { await markAsConfigured() }
    }
    
    private func markAsConfigured() {
        isConfigured = true
    }
    
    private func handleAppRefresh(
        identifier: String,
        complete:  @escaping @Sendable (Bool) -> Void,
        expire:  @escaping @Sendable () -> Void
    ) async {
        activeTask?.cancel()
        
        let refreshTask = Task { [complete] in
            do {
                try await refreshFeeds()
                complete(true)
                await scheduleAppRefreshIfNeeded()
            } catch {
                complete(false)
            }
        }
        
        activeTask = refreshTask
        
        if Task.isCancelled {
            expire()
            complete(false)
            Task {
                await scheduleAppRefreshIfNeeded()
            }
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
 
        for feed in enabledFeeds {
            do {
                let items = try await repository.fetchItems(feed)
                
                let newItems = items.filter { item in
                    guard let pubDate = item.pubDate else { return false }
                    return pubDate > lastCheckTime
                }
                
                for item in newItems {
                    try await  userNotifications.sendTestNotification(
                        item.title,
                        item.description ?? "",
                        delayOffset,
                    )
                    delayOffset += 0.5
                }
            } catch {
            
            }
        }
    }
    
    func scheduleAppRefreshIfNeeded() async {
        guard isConfigured else { return }
        
        @Dependency(\.feedRepository) var repository
        
        do {
            let feeds = try await repository.getCurrentFeeds()
            guard feeds.contains(where: \.notificationsEnabled) else {
                return
            }
            
            let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
            request.earliestBeginDate = Date(timeIntervalSinceNow: refreshInterval)
            
            try BGTaskScheduler.shared.submit(request)
        } catch {
            
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
        if isConfigured {
            return "Background task scheduler is configured"
        } else {
            return "Background task scheduler is not configured"
        }
    }
#endif
}
