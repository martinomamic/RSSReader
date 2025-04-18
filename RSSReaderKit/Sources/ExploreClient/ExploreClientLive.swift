//
//  ExploreClientLive.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 18.04.25.
//

extension ExploreClient {
    public static func live() -> ExploreClient {
        return ExploreClient(
            loadExploreFeeds: {
                guard let url = Bundle.main.url(forResource: "feeds", withExtension: "json") else {
                    throw ExploreFeedError.fileNotFound
                }
                
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    let feedList = try decoder.decode(ExploreFeedList.self, from: data)
                    return feedList.feeds
                } catch {
                    throw ExploreFeedError.decodingFailed(error.localizedDescription)
                }
            }
        )
    }
}
