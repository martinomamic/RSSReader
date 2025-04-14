//
//  RSSParserDelegate.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 13.04.25.
//

import Foundation
import SharedModels

public struct RSSParser: Sendable {
    private let delegateFactory: @Sendable () -> RSSParserDelegateProtocol
    
    public init(delegateFactory: @Sendable @escaping () -> RSSParserDelegateProtocol = { RSSParserDelegate() }) {
        self.delegateFactory = delegateFactory
    }
    
    public func parse(data: Data, feedURL: URL) async throws -> (feed: Feed?, items: [FeedItem]) {
        let parser = XMLParser(data: data)
        let delegate = delegateFactory()
        delegate.configure(feedURL: feedURL)
        parser.delegate = delegate
        
        if parser.parse() {
            return delegate.result
        } else if let error = parser.parserError {
            throw RSSError.parsingError(error)
        } else {
            throw RSSError.unknown
        }
    }
}
