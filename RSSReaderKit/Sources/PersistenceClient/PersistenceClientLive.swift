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
                print("DEBUG: PersistenceClient saveFeed: Inserting \(feed.url)")
                try context.save()
                let allFeeds = try context.fetch(FetchDescriptor<PersistableFeed>())
                print("DEBUG: Persistence feeds after save: \(allFeeds.map { $0.url })")
            },
            updateFeed: { feed async throws in
                let context = ModelContext(Self.modelContainer)
                let feedURL = feed.url
                let predicate = #Predicate<PersistableFeed> { $0.url == feedURL }
                let descriptor = FetchDescriptor<PersistableFeed>(predicate: predicate)

                let feedsBefore = try context.fetch(FetchDescriptor<PersistableFeed>())
                print("DEBUG: PersistenceClient updateFeed feeds before: \(feedsBefore.map { $0.url })")

                guard let existingFeed = try context.fetch(descriptor).first else {
                    print("DEBUG: PersistenceClient updateFeed: Feed not found: \(feed.url)")
                    return
                }
                existingFeed.title = feed.title
                existingFeed.feedDescription = feed.description
                existingFeed.imageURLString = feed.imageURL?.absoluteString
                existingFeed.isFavorite = feed.isFavorite
                existingFeed.notificationsEnabled = feed.notificationsEnabled

                try context.save()
                let allFeeds = try context.fetch(FetchDescriptor<PersistableFeed>())
                print("DEBUG: Persistence feeds after update: \(allFeeds.map { "\($0.url): F:\($0.isFavorite) N:\($0.notificationsEnabled)" })")
            },
            deleteFeed: { url async throws in
                let context = ModelContext(Self.modelContainer)
                let predicate = #Predicate<PersistableFeed> { $0.url == url }
                let descriptor = FetchDescriptor<PersistableFeed>(predicate: predicate)

                let feedsBefore = try context.fetch(FetchDescriptor<PersistableFeed>())
                print("DEBUG: PersistenceClient deleteFeed feeds before: \(feedsBefore.map { $0.url })")

                guard let existingFeed = try context.fetch(descriptor).first else {
                    print("DEBUG: PersistenceClient deleteFeed: Feed not found: \(url)")
                    return
                }
                context.delete(existingFeed)
                try context.save()
                let allFeeds = try context.fetch(FetchDescriptor<PersistableFeed>())
                print("DEBUG: Persistence feeds after delete: \(allFeeds.map { $0.url })")
            },
            loadFeeds: { () async throws in
                let context = ModelContext(Self.modelContainer)
                let descriptor = FetchDescriptor<PersistableFeed>()
                let persistableFeeds = try context.fetch(descriptor)
                print("DEBUG: PersistenceClient loadFeeds: \(persistableFeeds.map { $0.url })")
                return persistableFeeds.reversed().map { $0.toFeed() }
            }
        )
    }
}
