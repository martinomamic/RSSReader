import Foundation
import SwiftData
import SharedModels

@Model
final class PersistableFeed {
    @Attribute(.unique)
    var id: UUID
    var title: String?
    var url: URL
    var feedDescription: String?
    var imageURLString: String?
    var isFavorite: Bool
    
    init(id: UUID,
         title: String?,
         url: URL,
         feedDescription: String?,
         imageURLString: String?,
         isFavorite: Bool) {
        self.id = id
        self.title = title
        self.url = url
        self.feedDescription = feedDescription
        self.imageURLString = imageURLString
        self.isFavorite = isFavorite
    }
    
    convenience init(from feed: Feed) {
        self.init(
            id: feed.id,
            title: feed.title,
            url: feed.url,
            feedDescription: feed.description,
            imageURLString: feed.imageURL?.absoluteString,
            isFavorite: feed.isFavorite
        )
    }
    
    func toFeed() -> Feed {
        Feed(
            id: id,
            url: url,
            title: title,
            description: feedDescription,
            imageURL: imageURLString.flatMap(URL.init(string:)),
            isFavorite: isFavorite
        )
    }
}
