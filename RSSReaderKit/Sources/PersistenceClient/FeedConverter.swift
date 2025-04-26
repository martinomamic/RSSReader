//
//  FeedConverter.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 26.04.25.
//

import Foundation
import SharedModels

struct FeedConverter {
    static func toPersistable(_ feed: Feed) -> PersistableFeed {
        PersistableFeed(
            url: feed.url,
            title: feed.title,
            feedDescription: feed.description,
            imageURLString: feed.imageURL?.absoluteString,
            isFavorite: feed.isFavorite,
            notificationsEnabled: feed.notificationsEnabled
        )
    }
    
    static func fromPersistable(_ persistable: PersistableFeed) throws -> Feed {
        guard let url = URL(string: persistable.urlString) else {
            throw PersistenceError.operationFailed("Conversion failed: Saved URL string is invalid")
        }
        
        return Feed(
            url: url,
            title: persistable.title,
            description: persistable.feedDescription,
            imageURL: persistable.imageURLString.flatMap(URL.init(string:)),
            isFavorite: persistable.isFavorite,
            notificationsEnabled: persistable.notificationsEnabled
        )
    }
}
