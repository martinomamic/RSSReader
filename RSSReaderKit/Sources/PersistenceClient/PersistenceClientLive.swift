//
//  PersistenceClientLive.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 15.04.25.
//

import Foundation
import SharedModels
import SwiftData

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
            saveFeed: { feed async throws in
                let context = ModelContext(modelContainer)
                let persistableFeed = FeedConverter.toPersistable(feed)
                context.insert(persistableFeed)

                do {
                    try context.save()
                } catch {
                    throw PersistenceError.operationFailed("Failed to save feed")
                }
            },
            updateFeed: { feed async throws in
                let context = ModelContext(modelContainer)
                let feedURL = feed.url
                let predicate = #Predicate<PersistableFeed> { $0.urlString == feedURL.absoluteString }
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
                    throw PersistenceError.operationFailed("Failed updating feed")
                }
            },
            deleteFeed: { url async throws in
                let context = ModelContext(modelContainer)
                let predicate = #Predicate<PersistableFeed> { $0.urlString == url.absoluteString }
                let descriptor = FetchDescriptor<PersistableFeed>(predicate: predicate)

                do {
                    guard let existingFeed = try context.fetch(descriptor).first else {
                        return
                    }

                    context.delete(existingFeed)
                    try context.save()
                } catch {
                    throw PersistenceError.operationFailed("Failed deleting feed")
                }
            },
            loadFeeds: { () async throws in
                let context = ModelContext(modelContainer)
                let descriptor = FetchDescriptor<PersistableFeed>()

                do {
                    let persistableFeeds = try context.fetch(descriptor)
                    return try persistableFeeds.reversed().map { try FeedConverter.fromPersistable($0) }
                } catch {
                    throw PersistenceError.operationFailed("Failed loading feeds")
                }
            }
        )
    }
}
