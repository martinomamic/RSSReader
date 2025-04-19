//
//  FeedItem.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 12.04.25.
//

import Foundation

public struct FeedItem: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let feedID: UUID
    public let title: String
    public let link: URL
    public let pubDate: Date?
    public let description: String?
    public let imageURL: URL?

    public init(
        id: UUID = UUID(),
        feedID: UUID,
        title: String,
        link: URL,
        pubDate: Date? = nil,
        description: String? = nil,
        imageURL: URL? = nil
    ) {
        self.id = id
        self.feedID = feedID
        self.title = title
        self.link = link
        self.pubDate = pubDate
        self.description = description
        self.imageURL = imageURL
    }
}
