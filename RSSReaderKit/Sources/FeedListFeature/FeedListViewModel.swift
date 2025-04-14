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

@MainActor
@Observable class FeedListViewModel {
    @ObservationIgnored
    @Dependency(\.rssClient) private var rssClient
    
    var feeds: [FeedViewModel] = []
    var isLoading = false
    var error: Error?
}
