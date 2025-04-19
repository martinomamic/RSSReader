//
//  PersistenceClient.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 15.04.25.
//

import Foundation
import SwiftData
import SharedModels

@available(iOS 17, macOS 14, *)
@Model
final class PersistableFeed {
    @Attribute(.unique)
    var url: URL
    var title: String?
    var feedDescription: String?
    var imageURLString: String?
    var isFavorite: Bool
    var notificationsEnabled: Bool

    init(
        url: URL,
        title: String? = nil,
        feedDescription: String? = nil,
        imageURLString: String? = nil,
        isFavorite: Bool = false,
        notificationsEnabled: Bool = false
    ) {
        self.url = url
        self.title = title
        self.feedDescription = feedDescription
        self.imageURLString = imageURLString
        self.isFavorite = isFavorite
        self.notificationsEnabled = notificationsEnabled
    }

    convenience init(from feed: Feed) {
        self.init(
            url: feed.url,
            title: feed.title,
            feedDescription: feed.description,
            imageURLString: feed.imageURL?.absoluteString,
            isFavorite: feed.isFavorite,
            notificationsEnabled: feed.notificationsEnabled
        )
    }

    func toFeed() -> Feed {
        Feed(
            url: url,
            title: title,
            description: feedDescription,
            imageURL: imageURLString.flatMap(URL.init(string:)),
            isFavorite: isFavorite,
            notificationsEnabled: notificationsEnabled
        )
    }
}
