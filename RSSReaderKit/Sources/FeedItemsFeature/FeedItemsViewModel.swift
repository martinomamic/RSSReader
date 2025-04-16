import Common
import Dependencies
import Foundation
import RSSClient
import SharedModels

@Observable @MainActor
public class FeedItemsViewModel: Identifiable {
    @ObservationIgnored
    @Dependency(\.rssClient) private var rssClient
    
    let feedURL: URL
    let feedTitle: String
    
    var state: FeedItemsState = .loading
    var selectedItem: FeedItem?
    var showItemDetail = false
    
    private var loadTask: Task<Void, Never>?
    
    public init(feedURL: URL, feedTitle: String) {
        self.feedURL = feedURL
        self.feedTitle = feedTitle
    }
    
    func loadItems() {
        loadTask?.cancel()
        state = .loading
        
        loadTask = Task {
            do {
                let items = try await rssClient.fetchFeedItems(feedURL)
                
                if items.isEmpty {
                    state = .empty
                } else {
                    state = .loaded(items)
                }
            } catch {
                state = .error(RSSErrorMapper.mapToViewError(error))
            }
        }
    }
    
    func selectItem(_ item: FeedItem) {
        selectedItem = item
        showItemDetail = true
    }
}
