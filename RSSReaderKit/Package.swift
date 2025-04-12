// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "RSSReaderKit",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "RSSReaderKit", targets: ["RSSReaderKit"]),
        .library(name: "SharedModels", targets: ["SharedModels"]),
        .library(name: "UIComponents", targets: ["UIComponents"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nmdias/FeedKit.git", from: "9.1.2"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.11.0"),
    ],
    targets: [
        .target(
            name: "RSSReaderKit",
            dependencies: [
                "SharedModels",
                "UIComponents"
            ]
        ),
        .testTarget(
            name: "RSSReaderKitTests",
            dependencies: [
                "RSSReaderKit",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
        .target(
            name: "SharedModels",
            dependencies: []
        ),
        
        .target(
            name: "UIComponents",
            dependencies: [
                .product(name: "Kingfisher", package: "Kingfisher"),
                "SharedModels"
            ]
        ),
        .testTarget(
            name: "UIComponentsTests",
            dependencies: [
                "UIComponents",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ]
        ),
    ]
)
