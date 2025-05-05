//
//  BackgroundRefreshClientDependency.swift
//  RSSReaderKit
//
//  Created by Martino Mamic on 03.05.25.
//

import Dependencies
import Foundation
import SharedModels

extension BackgroundRefreshClient: DependencyKey {
    public static var liveValue: BackgroundRefreshClient { .live() }

    public static var testValue: BackgroundRefreshClient {
        BackgroundRefreshClient(
            configure: {},
            scheduleAppRefresh: {},
            sceneDidEnterBackground: {},
            manuallyTriggerBackgroundRefresh: { true },
            testFeedParsing: { "Test parsing completed" },
            getBackgroundTaskStatus: { "Background task configured" }
        )
    }
}

extension DependencyValues {
    public var backgroundRefresh: BackgroundRefreshClient {
        get { self[BackgroundRefreshClient.self] }
        set { self[BackgroundRefreshClient.self] = newValue }
    }
}
