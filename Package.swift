// swift-tools-version:6.3

import PackageDescription

let package = Package(
    name: "swift-snapshot-testing",
    platforms: [
        .iOS(.v17),
        .macOS(.v13),
        .tvOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SnapshotTesting",
            targets: ["SnapshotTesting"]
        ),
        .library(
            name: "InlineSnapshotTesting",
            targets: ["InlineSnapshotTesting"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", "509.0.0" ..< "605.0.0")
    ],
    targets: [
        .target(
            name: "SnapshotTesting"
        ),
        .testTarget(
            name: "SnapshotTestingTests",
            dependencies: [
                "SnapshotTesting"
            ],
            exclude: [
                "__Fixtures__",
                "__Snapshots__"
            ]
        ),
        .target(
            name: "InlineSnapshotTesting",
            dependencies: [
                "SnapshotTesting",
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax")
            ]
        ),
        .testTarget(
            name: "InlineSnapshotTestingTests",
            dependencies: [
                "InlineSnapshotTesting"
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
