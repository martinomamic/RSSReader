//
//  PersistenceClient.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 15.04.25.
//

import Foundation
import SharedModels

public struct PersistenceClient: Sendable {
    public var saveFeeds: @Sendable ([Feed]) async throws -> Void
    public var loadFeeds: @Sendable () async throws -> [Feed]
    
    public init(
        saveFeeds: @escaping @Sendable ([Feed]) async throws -> Void,
        loadFeeds: @escaping @Sendable () async throws -> [Feed]
    ) {
        self.saveFeeds = saveFeeds
        self.loadFeeds = loadFeeds
    }
}
