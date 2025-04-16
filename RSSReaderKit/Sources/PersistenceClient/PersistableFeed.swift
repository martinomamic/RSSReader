//
//  PersistableFeed.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 15.04.25.
//

import Foundation
import SwiftData
import SharedModels

@Model
public final class PersistableFeed {
    @Attribute(.unique) public var id: UUID
    public var url: URL
    public var title: String?
    public var feedDescription: String?
    public var imageURLString: String?
    public var isFavorite: Bool
    
    public init(from feed: Feed) {
        self.id = feed.id
        self.url = feed.url
        self.title = feed.title
        self.feedDescription = feed.description
        self.imageURLString = feed.imageURL?.absoluteString
        self.isFavorite = feed.isFavorite
    }
    
    public func toFeed() -> Feed {
        Feed(
            id: id,
            url: url,
            title: title,
            description: feedDescription,
            imageURL: imageURLString.flatMap { URL(string: $0) },
            isFavorite: isFavorite
        )
    }
}
