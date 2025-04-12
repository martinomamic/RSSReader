// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "RSSReaderKit",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "RSSClient", targets: ["RSSClient"]),
        .library(name: "SharedModels", targets: ["SharedModels"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nmdias/FeedKit.git", from: "9.1.2"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "RSSClient",
            dependencies: [
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
    ]
)
