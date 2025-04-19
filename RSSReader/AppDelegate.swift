//
//  AppDelegate.swift
//  RSSReader
//
//  Created by Martino Mamić on 17.04.25.
//

import UIKit
import NotificationClient
import Dependencies

class AppDelegate: NSObject, UIApplicationDelegate {
    @Dependency(\.notificationClient) private var notificationClient

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        NotificationDelegate.shared.setup()
        BackgroundRefreshClient.shared.registerBackgroundTasks()

        // Request notification permissions at launch
        Task {
            do {
                try await notificationClient.requestPermissions()
                print("Notification permissions requested successfully")
            } catch {
                print("Notification permissions denied: \(error)")
            }
        }

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Schedule next background refresh when app enters background
        BackgroundRefreshClient.shared.scheduleAppRefresh()
    }
}
