//
//  BackgroundRefreshClient.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 17.04.25.
//

import BackgroundTasks
import Common
import Dependencies
import Foundation
import PersistenceClient
@preconcurrency import UserNotifications

#if DEBUG
@MainActor
enum BGTaskDiagnostics {
    static var isBGTaskNotificationDebugEnabled: Bool = true
}
#endif

@MainActor
public final class BackgroundRefreshClient {
    @Dependency(\.notificationClient) private var notificationClient
    @Dependency(\.persistenceClient.loadFeeds) private var loadFeeds

    private let feedRefreshTaskIdentifier = "hr.maminjo.RSSReader.feedrefresh"
    private let refreshInterval: TimeInterval = 30 * 60
    private var isConfigured = false
    private var scheduler: Any = BGTaskScheduler.shared

    public static let shared = BackgroundRefreshClient()

    private init() {}

    public func configure() {
        print("[BGRefresh] Attempting to register BGAppRefreshTask '\(feedRefreshTaskIdentifier)'")
        (scheduler as? BGTaskScheduler)?.register(
            forTaskWithIdentifier: feedRefreshTaskIdentifier,
            using: nil
        ) { [weak self] task in
            print("[BGRefresh] BGAppRefreshTask handler invoked by system")
            if let bgTask = task as? BGAppRefreshTask {
                self?.handleAppRefresh(task: bgTask)
            }
        }
        isConfigured = true
        print("[BGRefresh] BGAppRefreshTask registration complete (isConfigured = \(isConfigured))")
    }

    public func scheduleAppRefresh() {
        guard isConfigured else {
            print("[BGRefresh] scheduleAppRefresh: not configured")
            return
        }

        Task {
            let authorizationStatus = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
            print("[BGRefresh] Notification permission status: \(authorizationStatus.rawValue) (authorized=1)")
            guard authorizationStatus == .authorized else {
                print("[BGRefresh] Not authorized, not scheduling refresh")
                return
            }

            let feeds = (try? await loadFeeds()) ?? []
            print("[BGRefresh] Feeds with notifications: \(feeds.filter(\.notificationsEnabled).count)")
            guard feeds.contains(where: \.notificationsEnabled) else {
                print("[BGRefresh] No feeds with notifications enabled")
                return
            }

            let request = BGAppRefreshTaskRequest(identifier: feedRefreshTaskIdentifier)
            request.earliestBeginDate = Date(timeIntervalSinceNow: refreshInterval)
            print("[BGRefresh] Attempting to schedule BGAppRefreshTask '\(feedRefreshTaskIdentifier)' with earliestBeginDate \(String(describing: request.earliestBeginDate))")

            do {
                try (scheduler as? BGTaskScheduler)?.submit(request)
                print("[BGRefresh] Background refresh scheduled (\(refreshInterval/60) min)")
            } catch {
                print("[BGRefresh] Failed to schedule background refresh: \(error)")
            }
        }
    }

    public func cancelScheduledRefresh() {
        print("[BGRefresh] Cancel BGAppRefreshTask '\(feedRefreshTaskIdentifier)'")
        (scheduler as? BGTaskScheduler)?.cancel(taskRequestWithIdentifier: feedRefreshTaskIdentifier)
    }

    private func handleAppRefresh(task: BGAppRefreshTask) {
        print("[BGRefresh] handleAppRefresh triggered by iOS")

        #if DEBUG
        if BGTaskDiagnostics.isBGTaskNotificationDebugEnabled {
            // ADD: local notification when BGTask fires, for diagnostic purposes
            Task {
                let center = UNUserNotificationCenter.current()
                let debugContent = UNMutableNotificationContent()
                debugContent.title = "🕒 BGTask Triggered"
                debugContent.body = "Background fetch started at \(Date().formatted(date: .numeric, time: .standard))"
                debugContent.sound = .default

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let request = UNNotificationRequest(
                    identifier: "debug-bgtask-fired-\(UUID().uuidString)",
                    content: debugContent,
                    trigger: trigger
                )
                try? await center.add(request)
                print("[BGRefresh] Background fetch diagnosis notification scheduled")
            }
        }
        #endif

        let refreshTask = Task {
            do {
                let feeds = try await loadFeeds()
                guard feeds.contains(where: \.notificationsEnabled) else {
                    print("[BGRefresh] No feeds enabled when refresh triggered")
                    task.setTaskCompleted(success: true)
                    return
                }

                print("[BGRefresh] Running notificationClient.checkForNewItems() from BGTask")
                try await notificationClient.checkForNewItems()
                task.setTaskCompleted(success: true)
                scheduleAppRefresh()
            } catch {
                print("[BGRefresh] Error in background fetch: \(error)")
                task.setTaskCompleted(success: false)
            }
        }

        task.expirationHandler = { [weak self] in
            print("[BGRefresh] Task expired/cancelled by system")
            refreshTask.cancel()
            task.setTaskCompleted(success: false)
            self?.scheduleAppRefresh()
        }
    }
}

#if DEBUG
extension BackgroundRefreshClient {
    public func manuallyTriggerBackgroundRefresh() async -> Bool {
        do {
            let center = UNUserNotificationCenter.current()
            let testContent = UNMutableNotificationContent()
            testContent.title = "Manual Refresh Started"
            testContent.body = "Starting background refresh at \(Date().formatted(date: .numeric, time: .standard))"
            testContent.sound = .default

            let startTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

            let testRequest = UNNotificationRequest(
                identifier: "manual-refresh-start-\(UUID().uuidString)",
                content: testContent,
                trigger: startTrigger
            )

            try await center.add(testRequest)
            print("Pre-refresh notification with 1-second delay")

            try await notificationClient.checkForNewItems()
            print("Manual background refresh successful")

            let successContent = UNMutableNotificationContent()
            successContent.title = "✅ Manual Refresh Completed"
            successContent.body = "Background refresh completed at \(Date().formatted(date: .numeric, time: .standard))"
            successContent.sound = .default

            let successTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)

            let successRequest = UNNotificationRequest(
                identifier: "manual-refresh-complete-\(UUID().uuidString)",
                content: successContent,
                trigger: successTrigger
            )

            try await center.add(successRequest)
            print("Post-refresh success notification with 2-second delay")

            return true
        } catch {
            print("Error during manual background refresh: \(error)")

            do {
                let center = UNUserNotificationCenter.current()
                let errorContent = UNMutableNotificationContent()
                errorContent.title = "❌ Background Refresh Error"
                errorContent.body = "Error: \(error.localizedDescription)"
                errorContent.sound = .default

                let errorTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

                let errorRequest = UNNotificationRequest(
                    identifier: "manual-refresh-error-\(UUID().uuidString)",
                    content: errorContent,
                    trigger: errorTrigger
                )

                try await center.add(errorRequest)
                print("Error notification with 1-second delay")
            } catch {
                print("Failed to send error notification: \(error)")
            }

            return false
        }
    }
}
#endif
