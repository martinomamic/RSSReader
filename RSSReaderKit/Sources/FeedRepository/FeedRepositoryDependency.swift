import Dependencies

private enum FeedRepositoryKey: DependencyKey {
    static var liveValue: FeedRepository = .liveValue
}

public extension DependencyValues {
    var feedRepository: FeedRepository {
        get { self[FeedRepositoryKey.self] }
        set { self[FeedRepositoryKey.self] = newValue }
    }
}