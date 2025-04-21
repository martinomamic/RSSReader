//
//  PersistenceClientLive.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 15.04.25.
//

import Dependencies
import Foundation
import SharedModels
import SwiftData
import RSSClient

extension PersistenceClient {
    public static func live() -> PersistenceClient {
        let modelContainer: ModelContainer

        do {
            let schema = Schema([PersistableFeed.self])
            let modelConfiguration = ModelConfiguration(schema: schema)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Failed to create model container: \(error.localizedDescription)")
        }

        return PersistenceClient(
            addFeed: { feed async throws in
                let context = ModelContext(modelContainer)
                var feedToPersist = feed
                @Dependency(\.rssClient.fetchFeedItems) var fetchFeedItems
                do {
                    let items = try await fetchFeedItems(feed.url)
                    let latestPubDate = items.compactMap(\.pubDate).max() ?? Date()
                    feedToPersist.lastFetchDate = latestPubDate
                    print("[Persistence] Added feed '\(feed.title ?? feed.url.absoluteString)' setting lastFetchDate = \(latestPubDate)")
                } catch {
                    feedToPersist.lastFetchDate = Date()
                    print("[Persistence] Failed to fetch items for '\(feed.title ?? feed.url.absoluteString)'; setting lastFetchDate = NOW (\(feedToPersist.lastFetchDate!))")
                }
                let persistableFeed = PersistableFeed(from: feedToPersist)
                context.insert(persistableFeed)

                do {
                    try context.save()
                } catch {
                    throw PersistenceError.saveFailed(error.localizedDescription)
                }
            },
            updateFeed: { feed async throws in
                let context = ModelContext(modelContainer)
                let feedURL = feed.url
                let predicate = #Predicate<PersistableFeed> { $0.url == feedURL }
                let descriptor = FetchDescriptor<PersistableFeed>(predicate: predicate)

                do {
                    guard let existingFeed = try context.fetch(descriptor).first else {
                        return
                    }
                    // I assumed only isFavorite can change, but maybe the feed content can be modified
                    // if the URL changes it's a different feed, but maybe I should resolve that as well
                    existingFeed.title = feed.title
                    existingFeed.feedDescription = feed.description
                    existingFeed.imageURLString = feed.imageURL?.absoluteString
                    existingFeed.isFavorite = feed.isFavorite
                    existingFeed.notificationsEnabled = feed.notificationsEnabled

                    try context.save()
                } catch {
                    throw PersistenceError.saveFailed(error.localizedDescription)
                }
            },
            deleteFeed: { url async throws in
                let context = ModelContext(modelContainer)
                let predicate = #Predicate<PersistableFeed> { $0.url == url }
                let descriptor = FetchDescriptor<PersistableFeed>(predicate: predicate)

                do {
                    guard let existingFeed = try context.fetch(descriptor).first else {
                        return
                    }

                    context.delete(existingFeed)
                    try context.save()
                } catch {
                    throw PersistenceError.saveFailed(error.localizedDescription)
                }
            },
            loadFeeds: { () async throws in
                let context = ModelContext(modelContainer)
                let descriptor = FetchDescriptor<PersistableFeed>()

                do {
                    let persistableFeeds = try context.fetch(descriptor)
                    return persistableFeeds.reversed().map { $0.toFeed() }
                } catch {
                    throw PersistenceError.loadFailed(error.localizedDescription)
                }
            }
        )
    }
}
