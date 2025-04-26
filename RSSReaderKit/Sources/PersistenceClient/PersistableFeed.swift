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
    var urlString: String
    var title: String?
    var feedDescription: String?
    var imageURLString: String?
    var isFavorite: Bool
    var notificationsEnabled: Bool

    init(
        url: URL,
        title: String?,
        feedDescription: String?,
        imageURLString: String?,
        isFavorite: Bool,
        notificationsEnabled: Bool = false
    ) {
        self.urlString = url.absoluteString
        self.title = title
        self.feedDescription = feedDescription
        self.imageURLString = imageURLString
        self.isFavorite = isFavorite
        self.notificationsEnabled = notificationsEnabled
    }
}
