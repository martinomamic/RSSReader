//
//  FeedListViewModel.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 13.04.25.
//

import Foundation
import SwiftUI
import RSSClient
import SharedModels
import Dependencies
import Observation

enum FeedListState: Equatable {
    case idle
    case loading
    case error(RSSViewError)
}

@MainActor
@Observable class FeedListViewModel {
    @ObservationIgnored
    @Dependency(\.rssClient) private var rssClient
    
    var feeds: [FeedViewModel] = []
    var state: FeedListState = .idle
    
    func loadFeeds() async {
        state = .loading
        state = .idle
    }
}
