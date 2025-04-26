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
    private static let modelContainer: ModelContainer = {
        do {
            let schema = Schema([PersistableFeed.self])
            let modelConfiguration = ModelConfiguration(schema: schema)
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Failed to create model container: \(error.localizedDescription)")
        }
    }()
    
    public static func live() -> PersistenceClient {
        return PersistenceClient(
            saveFeed: { feed async throws in
                let context = ModelContext(Self.modelContainer)
                let persistableFeed = PersistableFeed(from: feed)
                context.insert(persistableFeed)

                do {
                    try context.save()
                } catch {
                    throw PersistenceError.saveFailed(error.localizedDescription)
                }
            },
            updateFeed: { feed async throws in
                let context = ModelContext(Self.modelContainer)
                let feedURL = feed.url
                let predicate = #Predicate<PersistableFeed> { $0.url == feedURL }
                let descriptor = FetchDescriptor<PersistableFeed>(predicate: predicate)

                do {
                    guard let existingFeed = try context.fetch(descriptor).first else {
                        return
                    }
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
                let context = ModelContext(Self.modelContainer)
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
                let context = ModelContext(Self.modelContainer)
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
