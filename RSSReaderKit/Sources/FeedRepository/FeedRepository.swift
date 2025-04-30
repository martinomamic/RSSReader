//
//  FeedListViewModel.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 27.04.25.
//

import Foundation
import SharedModels
import Dependencies

public struct FeedRepository: Sendable {
    public var feedsStream: AsyncStream<[Feed]>
    
    public var fetch: @Sendable (URL) async throws -> Feed
    public var add: @Sendable (URL) async throws -> Void
    public var delete: @Sendable (URL) async throws -> Void
    public var update: @Sendable (Feed) async throws -> Void
    public var toggleFavorite: @Sendable (URL) async throws -> Void
    public var toggleNotifications: @Sendable (URL) async throws -> Void
    public var loadInitialFeeds: @Sendable () async throws -> Void
    public var loadExploreFeeds: @Sendable () async throws -> [ExploreFeed]
    public var addExploreFeed: @Sendable (ExploreFeed) async throws -> Feed
}
