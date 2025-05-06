//
//  BackgroundRefreshClient.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 03.05.25.
//

import BackgroundTasks
import Dependencies
import Foundation

public struct BackgroundRefreshClient: Sendable {
    public var configure: @Sendable () -> Void
    public var scheduleAppRefresh: @Sendable () async -> Void
    public var sceneDidEnterBackground: @Sendable () async -> Void
    
    public var manuallyTriggerBackgroundRefresh: @Sendable () async -> Bool
    public var testFeedParsing: @Sendable () async -> String
    public var getBackgroundTaskStatus: @Sendable () async -> String
    
    public init(
        configure: @escaping @Sendable () -> Void,
        scheduleAppRefresh: @escaping @Sendable () async -> Void,
        sceneDidEnterBackground: @escaping @Sendable () async -> Void,
        manuallyTriggerBackgroundRefresh: @escaping @Sendable () async -> Bool,
        testFeedParsing: @escaping @Sendable () async -> String,
        getBackgroundTaskStatus: @escaping @Sendable () async -> String
    ) {
        self.configure = configure
        self.scheduleAppRefresh = scheduleAppRefresh
        self.sceneDidEnterBackground = sceneDidEnterBackground
        
        self.manuallyTriggerBackgroundRefresh = manuallyTriggerBackgroundRefresh
        self.testFeedParsing = testFeedParsing
        self.getBackgroundTaskStatus = getBackgroundTaskStatus
    }
}
