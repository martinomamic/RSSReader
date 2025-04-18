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

    var body: some Scene {
        WindowGroup {
            TabBarView()
        }
    }
}
