//
//  FeedRepositoryTests.swift
//  Tests/FeedRepositoryTests
//
//  Created by Martino Mamić on 29.04.25.
//

import Testing
import Dependencies
import Foundation
import ConcurrencyExtras
import SharedModels
import RSSClient
import PersistenceClient

@testable import FeedRepository

@Suite struct FeedRepositoryTests {
    
    func createTestFeed(
        url: String = "https://example.com/feed",
        title: String = "Test Feed",
        description: String = "Test description",
        isFavorite: Bool = false,
        notificationsEnabled: Bool = false
    ) -> Feed {
        Feed(
            url: URL(string: url)!,
            title: title,
            description: description,
            isFavorite: isFavorite,
            notificationsEnabled: notificationsEnabled
        )
    }
}
