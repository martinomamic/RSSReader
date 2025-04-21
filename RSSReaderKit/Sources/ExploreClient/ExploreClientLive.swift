//
//  ExploreClientLive.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 18.04.25.
//

import Foundation
import SharedModels
import Dependencies
import RSSClient
import PersistenceClient

extension ExploreClient {
    public static func live() -> ExploreClient {
        @Dependency(\.rssClient.fetchFeed) var fetchFeed
        @Dependency(\.persistenceClient.addFeed) var addFeed

        return ExploreClient(
            loadExploreFeeds: {
                guard let url = Bundle.main.url(forResource: "feeds", withExtension: "json") else {
                    throw ExploreError.fileNotFound
                }

                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    let feedList = try decoder.decode(ExploreFeedList.self, from: data)
                    return feedList.feeds
                } catch {
                    throw ExploreError.decodingFailed(error.localizedDescription)
                }
            },
            addFeed: { exploreFeed in
                guard let url = URL(string: exploreFeed.url) else {
                    throw ExploreError.invalidURL
                }

                do {
                    let feed = try await fetchFeed(url)

                    try await addFeed(feed)

                    return feed
                } catch let error as RSSError {
                    throw ExploreError.feedFetchFailed(error.localizedDescription)
                } catch {
                    throw error
                }
            }
        )
    }
}
