//
//  AppDelegate.swift
//  RSSReader
//
//  Created by Martino Mamić on 17.04.25.
//

import BackgroundRefreshClient
import Dependencies
import UIKit
import UserNotificationClient

class AppDelegate: NSObject, UIApplicationDelegate {
    @Dependency(\.userNotifications) var userNotifications
    @Dependency(\.backgroundRefresh) var backgroundRefresh
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        userNotifications.setDelegate()
        backgroundRefresh.configure()
        return true
    }
    
    func application(
        _ application: UIApplication,
        handleEventsForBackgroundURLSession identifier: String,
        completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
