//
//  AppDelegate.swift
//  RSSReader
//
//  Created by Martino Mamić on 17.04.25.
//

import NotificationClient
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        NotificationDelegate.shared.setup()
        BackgroundRefreshClient.shared.configure()
        return true
    }
}
