//
//  PersistenceClient.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 15.04.25.
//

import Foundation
import SwiftData
import SharedModels

@Model
final class PersistableFeed {
    @Attribute(.unique)
    var url: URL
    var title: String?
    var feedDescription: String?
    var imageURLString: String?
    var isFavorite: Bool
    var notificationsEnabled: Bool
    var lastFetchDate: Date?

    init(
        title: String?,
        url: URL,
        feedDescription: String?,
        imageURLString: String?,
        isFavorite: Bool,
        notificationsEnabled: Bool = false,
        lastFetchDate: Date? = nil
    ) {
        self.title = title
        self.url = url
        self.feedDescription = feedDescription
        self.imageURLString = imageURLString
        self.isFavorite = isFavorite
        self.notificationsEnabled = notificationsEnabled
        self.lastFetchDate = lastFetchDate
    }

    convenience init(from feed: Feed) {
        self.init(
            title: feed.title,
            url: feed.url,
            feedDescription: feed.description,
            imageURLString: feed.imageURL?.absoluteString,
            isFavorite: feed.isFavorite,
            notificationsEnabled: feed.notificationsEnabled,
            lastFetchDate: feed.lastFetchDate
        )
    }

    func toFeed() -> Feed {
        Feed(
            url: url,
            title: title,
            description: feedDescription,
            imageURL: imageURLString.flatMap(URL.init(string:)),
            isFavorite: isFavorite,
            notificationsEnabled: notificationsEnabled,
            lastFetchDate: lastFetchDate
        )
    }
}
