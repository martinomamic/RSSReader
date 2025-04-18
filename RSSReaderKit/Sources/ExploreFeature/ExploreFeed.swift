//
//  ExploreFeed.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 18.04.25.
//

import Foundation

public struct ExploreFeed: Codable, Identifiable, Hashable {
    public var id: String { url }
    
    public let name: String
    public let url: String
    public let category: String
    
    public init(name: String, url: String, category: String) {
        self.name = name
        self.url = url
        self.category = category
    }
}
