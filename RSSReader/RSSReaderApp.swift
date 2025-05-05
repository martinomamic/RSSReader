//
//  RSSReaderApp.swift
//  RSSReader
//
//  Created by Martino Mamić on 12.04.25.
//

import SwiftUI
import TabBarFeature

@main
struct RSSReaderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            TabBarView()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                Task {
                    await appDelegate.backgroundRefresh.scheduleAppRefresh()
                }
            }
        }
    }
}
