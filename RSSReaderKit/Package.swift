// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "RSSReaderKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "Common", targets: ["Common"]),
        .library(name: "ExploreClient", targets: ["ExploreClient"]),
        .library(name: "ExploreFeature", targets: ["ExploreFeature"]),
        .library(name: "FeedItemsFeature", targets: ["FeedItemsFeature"]),
        .library(name: "FeedListFeature", targets: ["FeedListFeature"]),
        .library(name: "FeedRepository", targets: ["FeedRepository"]),
        .library(name: "NotificationClient", targets: ["NotificationClient"]),
        .library(name: "PersistenceClient", targets: ["PersistenceClient"]),
        .library(name: "RSSClient", targets: ["RSSClient"]),
        .library(name: "SharedModels", targets: ["SharedModels"]),
        .library(name: "TabBarFeature", targets: ["TabBarFeature"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-concurrency-extras", from: "1.3.1"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.9.1"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.15.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.3.2"),
    ],
    targets: [
        .target(
            name: "RSSClient",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                "Common",
                "SharedModels"
            ]
        ),
        .testTarget(
            name: "RSSClientTests",
            dependencies: [
                "RSSClient",
            ],
            resources: [
                .copy("Resources/bbc.xml")
            ]
        ),
        .target(
            name: "SharedModels",
            dependencies: []
        ),
        .testTarget(
            name: "SharedModelsTests",
            dependencies: [
                "SharedModels"
            ]
        ),
        .target(
            name: "Common",
            dependencies: [
                "Kingfisher"
            ]
        ),
        .testTarget(
            name: "CommonComponentTests",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                "Common",
                "ExploreClient",
                "PersistenceClient",
                "RSSClient",
            ],
            exclude: ["__Snapshots__"]
        ),
        .target(
            name: "ExploreClient",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                "Common",
                "PersistenceClient",
                "RSSClient",
                "SharedModels"
            ]
        ),
        .testTarget(
            name: "ExploreClientTests",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                "ExploreClient",
                "PersistenceClient",
                "RSSClient",
                "SharedModels"
            ]
        ),
        .target(
            name: "ExploreFeature",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                "Common",
                "FeedRepository",
                "SharedModels"
            ]
        ),
        .testTarget(
            name: "ExploreFeatureTests",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                "ExploreFeature"
            ],
            exclude: ["__Snapshots__"]
        ),
        .target(
            name: "FeedListFeature",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                "Common",
                "FeedItemsFeature",
                "FeedRepository",
                "NotificationClient",
                "SharedModels"
            ]
        ),
        .testTarget(
            name: "FeedListTests",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                "FeedListFeature",
                "NotificationClient"
            ],
            exclude: ["__Snapshots__"]
        ),
        .target(
            name: "FeedItemsFeature",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                "Common",
                "RSSClient",
                "SharedModels"
            ]
        ),
        .testTarget(
            name: "FeedItemsTests",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                "FeedItemsFeature",
                "NotificationClient"
            ],
            exclude: ["__Snapshots__"]
        ),
        .target(
            name: "FeedRepository",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                "Common",
                "ExploreClient",
                "PersistenceClient",
                "RSSClient",
                "SharedModels"
            ]
        ),
        .testTarget(
            name: "FeedRepositoryTests",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras"),
                "FeedRepository",
                "RSSClient",
                "PersistenceClient"
            ]
        ),
        .target(
            name: "NotificationClient",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                "Common",
                "PersistenceClient",
                "RSSClient",
                "SharedModels",
            ]
        ),
        .testTarget(
            name: "NotificationClientTests",
            dependencies: [
                .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras"),
                "NotificationClient",
            ]
        ),
        .target(
            name: "TabBarFeature",
            dependencies: [
                "ExploreFeature",
                "FeedListFeature"
            ]
        ),
        .testTarget(
            name: "TabBarFeatureTests",
            dependencies: [
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                "TabBarFeature",
                "Common"
            ],
            exclude: ["__Snapshots__"]
        ),
        .target(
            name: "PersistenceClient",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                "Common",
                "SharedModels"
            ]
        ),
        .testTarget(
            name: "PersistenceClientTests",
            dependencies: [
                .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras"),
                "PersistenceClient"
            ]
        ),
    ]
)
