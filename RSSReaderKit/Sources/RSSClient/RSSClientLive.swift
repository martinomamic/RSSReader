//
//  RSSClientLive.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 12.04.25.
//

import Common
import Dependencies
import Foundation
import SharedModels

extension RSSClient {
    public static func live() -> RSSClient {
        let parser = RSSParser()
        
        return RSSClient(
            fetchFeed: { url in
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    let (feed, _) = try await parser.parse(data: data, feedURL: url)
                    guard let feed else { throw RSSError.unknown }
                    return feed
                } catch let error as RSSError {
                    throw error
                } catch {
                    throw RSSError.networkError(error)
                }
            },
            
            fetchFeedItems: { url in
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    let (_, items) = try await parser.parse(data: data, feedURL: url)
                    return items
                } catch let error as RSSError {
                    throw error
                } catch {
                    throw RSSError.networkError(error)
                }
            }
        )
    }
}
