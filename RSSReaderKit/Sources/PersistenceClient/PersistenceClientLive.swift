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
            saveFeeds: { feeds async throws in
                let context = ModelContext(modelContainer)
                
                for feed in feeds {
                    let persistableFeed = PersistableFeed(from: feed)
                    context.insert(persistableFeed)
                }
                
                try context.save()
            },
            loadFeeds: { () async throws in
                let context = ModelContext(modelContainer)
                let descriptor = FetchDescriptor<PersistableFeed>()
                
                let persistableFeeds = try context.fetch(descriptor)
                return persistableFeeds.map { $0.toFeed() }
            }

        )
    }
}
