//
//  RSSParserTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 12.04.25.
//

import Testing
import Foundation

@testable import RSSClient
@testable import SharedModels

@Suite struct RSSParserTests {
    @Test("Parse valid RSS feed")
    func testParseValidRSSFeed() async throws {
        let parser = RSSParser()
        guard let url = Bundle.module.url(forResource: "bbc", withExtension: "xml") else {
            throw RSSError.invalidURL
        }

        let sampleRSSData = try Data(contentsOf: url)
        let (feed, items) = try await parser.parse(data: sampleRSSData, feedURL: url)

        #expect(feed?.title == "BBC News")
        #expect(feed?.description == "BBC News - World")
        #expect(feed?.url == url)
        #expect(items.count == 24)

        let firstItem = items.first
        #expect(firstItem != nil)
        #expect(firstItem?.title == "Israeli air strike destroys part of last functioning hospital in Gaza City")
        #expect(firstItem?.description == "The Israel Defense Forces said the hospital contained a \"command and control center used by Hamas\".")
        #expect(firstItem?.link == URL(string: "https://www.bbc.com/news/articles/cjr7l123zy5o"))
    }

    @Test("Parse invalid XML throws error")
    func testParseInvalidXML() async throws {
        let parser = RSSParser()
        let invalidXMLData = Data("blob".utf8)
        let url = URL(string: "blob")!

        do {
            _ = try await parser.parse(data: invalidXMLData, feedURL: url)
            #expect(Bool(false), "Invalid XML error")
        } catch {
            #expect(error is RSSError)
        }
    }
}
