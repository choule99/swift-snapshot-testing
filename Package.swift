// swift-tools-version:6.3

import PackageDescription

let customDumpSwiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("ImmutableWeakCaptures"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault")
]

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
        ),
        .library(
            name: "CustomDump",
            targets: ["CustomDump"]
        ),
        .library(
            name: "SnapshotTestingCustomDump",
            targets: ["SnapshotTestingCustomDump"]
        )
    ],
    traits: [
        "FoundationNetworking",
        .default(enabledTraits: ["FoundationNetworking"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.2.2"),
        .package(url: "https://github.com/swiftlang/swift-syntax", "509.0.0" ..< "605.0.0")
    ],
    targets: [
        .target(
            name: "SnapshotTesting"
        ),
        .testTarget(
            name: "SnapshotTestingTests",
            dependencies: [
                "SnapshotTesting",
                "SnapshotTestingCustomDump"
            ],
            exclude: [
                "__Fixtures__",
                "__Snapshots__"
            ]
        ),
        .target(
            name: "CustomDump",
            dependencies: [
                .product(name: "IssueReporting", package: "xctest-dynamic-overlay")
            ],
            swiftSettings: customDumpSwiftSettings
        ),
        .testTarget(
            name: "CustomDumpTests",
            dependencies: [
                "CustomDump",
                .product(name: "IssueReportingTestSupport", package: "xctest-dynamic-overlay")
            ],
            swiftSettings: customDumpSwiftSettings
        ),
        .target(
            name: "SnapshotTestingCustomDump",
            dependencies: [
                "CustomDump",
                "SnapshotTesting"
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
                "InlineSnapshotTesting",
                "SnapshotTestingCustomDump"
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
