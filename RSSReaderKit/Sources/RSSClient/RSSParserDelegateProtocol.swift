//
//  RSSParserDelegateProtocol.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 13.04.25.
//

import Foundation
import SharedModels

public protocol RSSParserDelegateProtocol: XMLParserDelegate {
    var result: (feed: Feed, items: [FeedItem]) { get }
    func configure(feedURL: URL)
}
