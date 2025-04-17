//
//  BackgroundRefreshManager.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 17.04.25.
//

import BackgroundTasks
import Dependencies
import Foundation

@MainActor
public final class BackgroundRefreshManager: Sendable {
    @Dependency(\.notificationClient) private var notificationClient
    
    private let feedRefreshTaskIdentifier = "com.rssreader.feedrefresh"
    
    public static let shared = BackgroundRefreshManager()
    
    private init() {}
    
    public func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: feedRefreshTaskIdentifier,
            using: nil
        ) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    public func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: feedRefreshTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()

        let refreshTask = Task {
            do {
                try await notificationClient.checkForNewItems()
                task.setTaskCompleted(success: true)
            } catch {
                task.setTaskCompleted(success: false)
            }
        }
        
        task.expirationHandler = {
            refreshTask.cancel()
            task.setTaskCompleted(success: false)
        }
    }
}
