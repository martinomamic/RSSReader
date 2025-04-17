//
//  Feed.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 12.04.25.
//

import Foundation

public struct Feed: Identifiable, Hashable, Sendable {
    public var id: URL { url }
    public let url: URL
    public var title: String?
    public var description: String?
    public var imageURL: URL?
    public var isFavorite: Bool
    public var notificationsEnabled: Bool

    public init(
        url: URL,
        title: String? = nil,
        description: String? = nil,
        imageURL: URL? = nil,
        isFavorite: Bool = false,
        notificationsEnabled: Bool = false
    ) {
        self.url = url
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.isFavorite = isFavorite
        self.notificationsEnabled = notificationsEnabled
    }

    public static func == (lhs: Feed, rhs: Feed) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
