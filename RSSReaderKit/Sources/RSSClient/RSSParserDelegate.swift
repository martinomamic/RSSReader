//
//  RSSParserDelegate.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 12.04.25.
//

import Foundation
import SharedModels

public class RSSParserDelegate: NSObject, RSSParserDelegateProtocol {
    private var feed: Feed!
    private var items: [FeedItem] = []
    
    private var currentElement = ""
    private var currentTitle: String?
    private var currentDescription: String?
    private var currentLink: String?
    private var currentPubDate: String?
    private var currentImageURL: String?
    private var isInsideItem = false
    private var isInsideImage = false
    private var feedID = UUID()
    
    private var textBuffer = ""
    
    public var result: (feed: Feed, items: [FeedItem]) {
        return (feed: feed, items: items)
    }
    
    public override init() {
        super.init()
    }
    
    public func configure(feedURL: URL) {
        self.feed = Feed(url: feedURL)
        self.items = []
        self.feedID = UUID()
    }
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        textBuffer = ""
        
        guard let element = RSSElement(rawValue: elementName) else { return }
        
        switch element {
        case .item:
            isInsideItem = true
            currentTitle = nil
            currentDescription = nil
            currentLink = nil
            currentPubDate = nil
            currentImageURL = nil
        case .image:
            isInsideImage = true
        case .enclosure where isInsideItem:
            if let url = attributeDict[RSSAttribute.url.rawValue], 
               let type = attributeDict[RSSAttribute.type.rawValue], 
               MediaType.image.matches(type) {
                currentImageURL = url
            }
        default:
            break
        }
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let text = textBuffer.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let element = RSSElement(rawValue: elementName) else { return }
        
        switch element {
        case .title:
            if isInsideItem {
                currentTitle = text
            } else if !isInsideImage {
                feed.title = text
            }
        case .description:
            if isInsideItem {
                currentDescription = text
            } else {
                feed.description = text
            }
        case .link:
            if isInsideItem {
                currentLink = text
            }
        case .pubDate:
            if isInsideItem {
                currentPubDate = text
            }
        case .url:
            if isInsideImage {
                feed.imageURL = URL(string: text)
            }
        case .image:
            isInsideImage = false
        case .item:
            isInsideItem = false
            
            if let title = currentTitle, let linkString = currentLink, let link = URL(string: linkString) {
                let pubDate = currentPubDate.flatMap { DateFormat.parseDate($0) }
                let imageURL = currentImageURL.flatMap { URL(string: $0) }
                
                let item = FeedItem(
                    feedID: feedID,
                    title: title,
                    link: link,
                    pubDate: pubDate,
                    description: currentDescription,
                    imageURL: imageURL
                )
                
                items.append(item)
            }
        default:
            break
        }
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        textBuffer += string
    }
}
