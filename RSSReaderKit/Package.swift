// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "RSSReaderKit",
    platforms: [
        .iOS(.v17),
        //satisfy SPM 
        .macOS(.v10_14)
    ],
    products: [
        .library(name: "Common", targets: ["Common"]),
        .library(name: "ExploreClient", targets: ["ExploreClient"]),
        .library(name: "ExploreFeature", targets: ["ExploreFeature"]),
        .library(name: "FeedItemsFeature", targets: ["FeedItemsFeature"]),
        .library(name: "FeedListFeature", targets: ["FeedListFeature"]),
        .library(name: "NotificationClient", targets: ["NotificationClient"]),
        .library(name: "PersistenceClient", targets: ["PersistenceClient"]),
        .library(name: "RSSClient", targets: ["RSSClient"]),
        .library(name: "SharedModels", targets: ["SharedModels"]),
        .library(name: "TabBarFeature", targets: ["TabBarFeature"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-concurrency-extras", from: "1.3.1"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.9.1"),
    ],
    targets: [
        .target(
            name: "RSSClient",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
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
        .target(
            name: "Common",
            dependencies: [
                "RSSClient"
            ]
        ),
        .target(
            name: "ExploreClient",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
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
                "ExploreClient",
                "SharedModels"
            ]
        ),
        .target(
            name: "FeedListFeature",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                "Common",
                "FeedItemsFeature",
                "PersistenceClient",
                "RSSClient",
                "SharedModels"
            ]
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
        .target(
            name: "PersistenceClient",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
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
