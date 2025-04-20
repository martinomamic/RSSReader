//
//  AppDelegate.swift
//  RSSReader
//
//  Created by Martino Mamić on 17.04.25.
//

import NotificationClient
import UIKit
import PersistenceClient

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        NotificationDelegate.shared.setup()
        BackgroundRefreshClient.shared.configure()

        Task {
            let feeds = (try? await PersistenceClient.live().loadFeeds()) ?? []
            if feeds.contains(where: \.notificationsEnabled) {
                print("[BGRefresh] (AppDelegate) Scheduling BGTask at launch, feeds with notifications: \(feeds.filter(\.notificationsEnabled).count)")
                BackgroundRefreshClient.shared.scheduleAppRefresh()
            } else {
                print("[BGRefresh] (AppDelegate) No feeds enabled for notifications at launch.")
            }
        }

        return true
    }
}
