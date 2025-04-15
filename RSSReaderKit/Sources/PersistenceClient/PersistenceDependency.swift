//
//  PersistenceDependency.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 15.04.25.
//

import Dependencies
import Foundation

extension PersistenceClient: DependencyKey {
    public static var liveValue: PersistenceClient { .live() }
    
    public static var testValue: PersistenceClient {
        return PersistenceClient(
            saveFeeds: { _ in },
            loadFeeds: { [] }
        )
    }
}

extension DependencyValues {
    public var persistenceClient: PersistenceClient {
        get { self[PersistenceClient.self] }
        set { self[PersistenceClient.self] = newValue }
    }
}
