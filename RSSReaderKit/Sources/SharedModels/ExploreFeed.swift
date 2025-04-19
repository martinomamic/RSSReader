//
//  ExploreFeed.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 18.04.25.
//

public struct ExploreFeed: Codable, Identifiable, Hashable, Sendable {
    public var id: String { url }

    public let name: String
    public let url: String

    public init(name: String, url: String) {
        self.name = name
        self.url = url
    }
}
