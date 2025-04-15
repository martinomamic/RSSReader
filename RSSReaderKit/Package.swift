// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "RSSReaderKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "Common", targets: ["Common"]),
        .library(name: "FeedItemsFeature", targets: ["FeedItemsFeature"]),
        .library(name: "FeedListFeature", targets: ["FeedListFeature"]),
        .library(name: "RSSClient", targets: ["RSSClient"]),
        .library(name: "SharedModels", targets: ["SharedModels"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
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
            name: "FeedListFeature",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                "Common",
                "FeedItemsFeature",
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
    ]
)
