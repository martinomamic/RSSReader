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
import UserNotifications

@MainActor
public final class BackgroundRefreshClient {
    @Dependency(\.notificationClient) private var notificationClient

    private let feedRefreshTaskIdentifier = "com.rssreader.feedrefresh"

    public static let shared = BackgroundRefreshClient()

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
            print("Scheduled background refresh for future execution")
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
