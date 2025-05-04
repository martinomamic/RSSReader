//
//  BackgroundRefreshClientLive.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 03.05.25.
//

import Dependencies
import Foundation

extension BackgroundRefreshClient {
    public static func live() -> Self {
        let service = BackgroundRefreshService()
        
        return Self(
            configure: {
                service.configureOnLaunch()
            },
            scheduleAppRefresh: {
                Task {
                    await service.scheduleAppRefreshIfNeeded()
                }
            },
            manuallyTriggerBackgroundRefresh: {
                await service.manuallyTriggerBackgroundRefresh()
            },
            testFeedParsing: {
                await service.testFeedParsing()
            },
            getBackgroundTaskStatus: {
                await service.getBackgroundTaskStatus()
            }
        )
    }
}
