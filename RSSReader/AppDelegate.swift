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
        // Register for background tasks
        BackgroundRefreshManager.shared.registerBackgroundTasks()
        
        // Request notification permissions when the app launches
        Task {
            do {
                try await notificationClient.requestPermissions()
            } catch {
                // Handle permission denied
                print("Notification permissions denied: \(error)")
            }
        }
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Schedule background refresh
        BackgroundRefreshManager.shared.scheduleAppRefresh()
    }
}
