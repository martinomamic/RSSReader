import Foundation
import SharedModels
import Dependencies

@DependencyClient
public struct FeedRepository: FeedRepositoryProtocol, Sendable {
    public var feedsStream: AsyncStream<[Feed]>
    
    public var fetch: @Sendable (URL) async throws -> Feed
    public var add: @Sendable (URL) async throws -> Feed
    public var delete: @Sendable (URL) async throws -> Void
    public var update: @Sendable (Feed) async throws -> Void
    public var toggleFavorite: @Sendable (URL) async throws -> Void
    public var toggleNotifications: @Sendable (URL) async throws -> Void
    public var refreshAll: @Sendable () async throws -> Void
}