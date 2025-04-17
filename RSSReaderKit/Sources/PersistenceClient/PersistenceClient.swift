//
//  PersistenceClient.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 15.04.25.
//

import Foundation
import SharedModels

public struct PersistenceClient: Sendable {
    public var addFeed: @Sendable (Feed) async throws -> Void
    public var updateFeed: @Sendable (Feed) async throws -> Void
    public var deleteFeed: @Sendable (URL) async throws -> Void
    public var loadFeeds: @Sendable () async throws -> [Feed]
    
    public init(
        addFeed: @escaping @Sendable (Feed) async throws -> Void,
        updateFeed: @escaping @Sendable (Feed) async throws -> Void,
        deleteFeed: @escaping @Sendable (URL) async throws -> Void,
        loadFeeds: @escaping @Sendable () async throws -> [Feed]
    ) {
        self.addFeed = addFeed
        self.updateFeed = updateFeed
        self.deleteFeed = deleteFeed
        self.loadFeeds = loadFeeds
    }
}
