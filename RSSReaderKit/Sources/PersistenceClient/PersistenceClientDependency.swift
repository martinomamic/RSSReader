//
//  PersistenceDependency.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 15.04.25.
//

import ConcurrencyExtras
import Dependencies
import Foundation
import SharedModels

@available(macOS 14.0, *)
extension PersistenceClient: DependencyKey {
    public static var liveValue: PersistenceClient { .live() }

    public static var testValue: PersistenceClient {
        let feedStore = LockIsolated<[Feed]>([])

        return PersistenceClient(
            addFeed: { feed in
                feedStore.withValue { feeds in
                    feeds.append(feed)
                }
            },
            updateFeed: { feed in
                feedStore.withValue { feeds in
                    if let index = feeds.firstIndex(where: { $0.url == feed.url }) {
                        feeds[index] = feed
                    }
                }
            },
            deleteFeed: { url in
                feedStore.withValue { feeds in
                    feeds.removeAll(where: { $0.url == url })
                }
            },
            loadFeeds: {
                return feedStore.value
            }
        )
    }
}

extension DependencyValues {
    public var persistenceClient: PersistenceClient {
        get { self[PersistenceClient.self] }
        set { self[PersistenceClient.self] = newValue }
    }
}
