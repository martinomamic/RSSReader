// swift-tools-version: 6.0

import PackageDescription

fileprivate enum Module: String, CaseIterable {
    case backgroundRefreshClient = "BackgroundRefreshClient"
    case common = "Common"
    case exploreClient = "ExploreClient"
    case exploreFeature = "ExploreFeature"
    case feedItemsFeature = "FeedItemsFeature"
    case feedListFeature = "FeedListFeature"
    case feedRepository = "FeedRepository"
    case notificationRepository = "NotificationRepository"
    case persistenceClient = "PersistenceClient"
    case rssClient = "RSSClient"
    case sharedModels = "SharedModels"
    case sharedUI = "SharedUI"
    case tabBarFeature = "TabBarFeature"
    case testUtility = "TestUtility"
    case toastFeature = "ToastFeature"
    case userDefaultsClient = "UserDefaultsClient"
    case userNotificationClient = "UserNotificationClient"

    var name: String { self.rawValue }
    var testName: String { "\(self.rawValue)Tests" }
}

fileprivate enum ExternalProduct {
    case concurrencyExtras
    case dependencies
    case snapshotTesting
    case kingfisher
    
    var name: String {
        switch self {
        case .concurrencyExtras:
            return "ConcurrencyExtras"
        case .dependencies:
            return "Dependencies"
        case .snapshotTesting:
            return "SnapshotTesting"
        case .kingfisher:
           return "Kingfisher"
        }
    }
    var package: String {
        switch self {
        case .concurrencyExtras:
            return "swift-concurrency-extras"
        case .dependencies:
            return "swift-dependencies"
        case .snapshotTesting:
            return "swift-snapshot-testing"
        case .kingfisher:
           return "Kingfisher"
        }
    }
}

fileprivate func externalProduct(_ product: ExternalProduct) -> Target.Dependency {
    .product(name: product.name, package: product.package)
}

fileprivate func module(_ module: Module) -> Target.Dependency {
    .target(name: module.name)
}

private func target(_ module: Module, dependencies: [Target.Dependency] = [], exclude: [String] = []) -> Target {
    .target(name: module.name, dependencies: dependencies, exclude: exclude)
}

fileprivate func testTarget(_ module: Module, dependencies: [Target.Dependency] = [], exclude: [String] = [], resources: [Resource]? = nil) -> Target {
    .testTarget(name: module.testName, dependencies: dependencies, exclude: exclude, resources: resources)
}

fileprivate func library(_ module: Module) -> PackageDescription.Product {
    .library(name: module.name, targets: [module.name])
}

fileprivate let snapshotsDirectory = "__Snapshots__"

let package = Package(
    name: "RSSReaderKit",
    platforms: [
        .iOS(.v17)
    ],
    products: Module.allCases.map { library($0) },
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-concurrency-extras", from: "1.3.1"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.9.1"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.15.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.3.2"),
    ],
    targets: [
        target(
            .backgroundRefreshClient,
            dependencies: [
                externalProduct(.dependencies),
                module(.common),
                module(.feedRepository),
                module(.persistenceClient),
                module(.sharedModels),
                module(.userDefaultsClient),
                module(.userNotificationClient)
            ]
        ),
        testTarget(
            .backgroundRefreshClient,
            dependencies: [
                externalProduct(.dependencies),
                module(.backgroundRefreshClient),
                module(.testUtility),
            ]
        ),
        target(.common),
        testTarget(
            .common,
            dependencies: [
                externalProduct(.dependencies),
                module(.common),
                module(.exploreClient),
                module(.notificationRepository),
                module(.persistenceClient),
                module(.rssClient),
                module(.testUtility),
            ]
        ),
        target(
            .exploreClient,
            dependencies: [
                externalProduct(.dependencies),
                module(.common),
                module(.persistenceClient),
                module(.rssClient),
                module(.sharedModels)
            ]
        ),
        testTarget(
            .exploreClient,
            dependencies: [
                externalProduct(.dependencies),
                module(.exploreClient),
                module(.persistenceClient),
                module(.rssClient),
                module(.sharedModels),
                module(.testUtility),
            ]
        ),
        target(
            .exploreFeature,
            dependencies: [
                externalProduct(.dependencies),
                module(.common),
                module(.feedRepository),
                module(.sharedModels),
                module(.sharedUI),
                module(.toastFeature)
            ]
        ),
        testTarget(
            .exploreFeature,
            dependencies: [
                externalProduct(.dependencies),
                module(.exploreFeature),
                module(.testUtility)
            ],
            exclude: [snapshotsDirectory]
        ),
        target(
            .feedItemsFeature,
            dependencies: [
                externalProduct(.dependencies),
                module(.common),
                module(.rssClient),
                module(.sharedModels),
                module(.sharedUI)
            ]
        ),
        testTarget(
            .feedItemsFeature,
            dependencies: [
                externalProduct(.dependencies),
                module(.feedItemsFeature),
                module(.notificationRepository),
                module(.testUtility)
            ],
            exclude: [snapshotsDirectory]
        ),
        target(
            .feedListFeature,
            dependencies: [
                externalProduct(.dependencies),
                module(.common),
                module(.feedItemsFeature),
                module(.feedRepository),
                module(.notificationRepository),
                module(.sharedModels),
                module(.sharedUI),
                module(.toastFeature)
            ]
        ),
        testTarget(
            .feedListFeature,
            dependencies: [
                externalProduct(.dependencies),
                module(.feedListFeature),
                module(.notificationRepository),
                module(.testUtility)
            ],
            exclude: [snapshotsDirectory]
        ),
        target(
            .feedRepository,
            dependencies: [
                externalProduct(.dependencies),
                module(.common),
                module(.exploreClient),
                module(.persistenceClient),
                module(.rssClient),
                module(.sharedModels)
            ]
        ),
        testTarget(
            .feedRepository,
            dependencies: [
                externalProduct(.concurrencyExtras),
                externalProduct(.dependencies),
                module(.feedRepository),
                module(.rssClient),
                module(.persistenceClient),
                module(.testUtility),
            ]
        ),
        target(
            .notificationRepository,
            dependencies: [
                externalProduct(.dependencies),
                module(.backgroundRefreshClient),
                module(.common),
                module(.userNotificationClient)
            ]
        ),
        testTarget(
            .notificationRepository,
            dependencies: [
                externalProduct(.dependencies),
                module(.notificationRepository),
                module(.testUtility),
            ],
            exclude: [snapshotsDirectory]
        ),
        target(
            .persistenceClient,
            dependencies: [
                externalProduct(.dependencies),
                module(.common),
                module(.sharedModels)
            ]
        ),
        testTarget(
            .persistenceClient,
            dependencies: [
                externalProduct(.concurrencyExtras),
                module(.persistenceClient),
                module(.testUtility),
            ]
        ),
        target(
            .rssClient,
            dependencies: [
                externalProduct(.dependencies),
                module(.common),
                module(.sharedModels)
            ]
        ),
        testTarget(
            .rssClient,
            dependencies: [
                module(.rssClient),
                module(.testUtility),
            ],
            resources: [
                .copy("Resources/bbc.xml")
            ]
        ),
        target(.sharedModels),
        testTarget(
            .sharedModels,
            dependencies: [
                module(.sharedModels),
                module(.testUtility),
            ]
        ),
        target(
            .sharedUI,
            dependencies: [
                externalProduct(.kingfisher),
                module(.common),
                module(.sharedModels)
            ]
        ),
        testTarget(
            .sharedUI,
            dependencies: [
                module(.sharedUI),
                module(.testUtility)
            ],
            exclude: [snapshotsDirectory]
        ),
        target(
            .toastFeature,
            dependencies: [
                module(.common)
            ]
        ),
        target(
            .tabBarFeature,
            dependencies: [
                module(.exploreFeature),
                module(.feedListFeature)
            ]
        ),
        testTarget(
            .tabBarFeature,
            dependencies: [
                module(.common),
                module(.tabBarFeature),
                module(.testUtility)
            ],
            exclude: [snapshotsDirectory]
        ),
        target(
            .testUtility,
            dependencies: [
                externalProduct(.snapshotTesting),
                module(.sharedModels)
            ]
        ),
        target(
            .userDefaultsClient,
            dependencies: [
                externalProduct(.dependencies)
            ]
        ),
        testTarget(
            .userDefaultsClient,
            dependencies: [
                externalProduct(.concurrencyExtras),
                module(.userDefaultsClient),
                module(.testUtility),
            ]
        ),
        target(
            .userNotificationClient,
            dependencies: [
                externalProduct(.dependencies)
            ]
        ),
        testTarget(
            .userNotificationClient,
            dependencies: [
                externalProduct(.dependencies),
                module(.userNotificationClient),
                module(.testUtility),
            ]
        ),
    ]
)