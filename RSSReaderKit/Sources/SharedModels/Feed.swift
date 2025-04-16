//
//  Feed.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 12.04.25.
//

import Foundation

public struct Feed: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let url: URL
    public var title: String?
    public var description: String?
    public var imageURL: URL?
    public var isFavorite: Bool
    
    public init(
        id: UUID = UUID(),
        url: URL,
        title: String? = nil,
        description: String? = nil,
        imageURL: URL? = nil,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.url = url
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.isFavorite = isFavorite
    }
}
