import Foundation
@_spi(Internals) @testable import SnapshotTesting
import XCTest

final class ReferenceStorageTests: XCTestCase {
    func testDefaultStorageRemainsAdjacentToSourceFile() throws {
        let directory = try snapshotDirectoryURL(
            explicitPath: nil,
            referenceStorage: nil,
            fileID: "FeatureTests/ChatViewTests.swift",
            filePath: "/workspace/Tests/FeatureTests/Flows/ChatViewTests.swift",
            androidBaseURL: nil
        )

        XCTAssertEqual(
            directory.path,
            "/workspace/Tests/FeatureTests/Flows/__Snapshots__/ChatViewTests"
        )
    }

    func testTestTargetStoragePreservesSourceHierarchyAndTestFileBoundary() throws {
        let directory = try snapshotDirectoryURL(
            explicitPath: nil,
            referenceStorage: .directory("__Snapshots__", relativeTo: .testTarget),
            fileID: "FeatureTests/ChatViewTests.swift",
            filePath: "/workspace/Tests/FeatureTests/Flows/ChatViewTests.swift",
            androidBaseURL: nil
        )

        XCTAssertEqual(
            directory.path,
            "/workspace/Tests/FeatureTests/__Snapshots__/Flows/ChatViewTests"
        )
    }

    func testNestedReferenceDirectoryIsSupported() throws {
        let directory = try snapshotDirectoryURL(
            explicitPath: nil,
            referenceStorage: .directory("References/Images", relativeTo: .testTarget),
            fileID: "FeatureTests/ChatViewTests.swift",
            filePath: "/workspace/Tests/FeatureTests/Flows/ChatViewTests.swift",
            androidBaseURL: nil
        )

        XCTAssertEqual(
            directory.path,
            "/workspace/Tests/FeatureTests/References/Images/Flows/ChatViewTests"
        )
    }

    func testAndroidStorageUsesStagingRootAndPreservesHierarchy() throws {
        let directory = try snapshotDirectoryURL(
            explicitPath: nil,
            referenceStorage: .directory("__Snapshots__", relativeTo: .testTarget),
            fileID: "FeatureTests/ChatViewTests.swift",
            filePath: "/workspace/Tests/FeatureTests/Flows/ChatViewTests.swift",
            androidBaseURL: URL(fileURLWithPath: "/data/local/tmp/android-xctest", isDirectory: true)
        )

        XCTAssertEqual(
            directory.path,
            "/data/local/tmp/android-xctest/__Snapshots__/Flows/ChatViewTests"
        )
    }

    func testExplicitDirectoryTakesPrecedenceOverReferenceStorage() throws {
        let directory = try snapshotDirectoryURL(
            explicitPath: "/explicit",
            referenceStorage: .directory("../invalid", relativeTo: .testTarget),
            fileID: "Unknown/ChatViewTests.swift",
            filePath: "/workspace/ChatViewTests.swift",
            androidBaseURL: nil
        )

        XCTAssertEqual(directory.path, "/explicit")
    }

    func testInvalidReferenceDirectoriesFail() {
        for directory in ["", "   ", "/absolute", ".", "..", "References/../Snapshots"] {
            XCTAssertThrowsError(
                try snapshotDirectoryURL(
                    explicitPath: nil,
                    referenceStorage: .directory(directory, relativeTo: .testTarget),
                    fileID: "FeatureTests/ChatViewTests.swift",
                    filePath: "/workspace/Tests/FeatureTests/ChatViewTests.swift",
                    androidBaseURL: nil
                )
            ) { error in
                XCTAssertEqual(error as? SnapshotReferenceStorageError, .invalidDirectory(directory))
            }
        }
    }

    func testMissingTestTargetFailsWithoutFallback() {
        XCTAssertThrowsError(
            try snapshotDirectoryURL(
                explicitPath: nil,
                referenceStorage: .directory("__Snapshots__", relativeTo: .testTarget),
                fileID: "FeatureTests/ChatViewTests.swift",
                filePath: "/workspace/Tests/OtherTests/ChatViewTests.swift",
                androidBaseURL: nil
            )
        ) { error in
            XCTAssertEqual(
                error as? SnapshotReferenceStorageError,
                .testTargetNotFound(
                    module: "FeatureTests",
                    filePath: "/workspace/Tests/OtherTests/ChatViewTests.swift"
                )
            )
        }
    }

    func testScopedStorageFeedsDirectoryResolution() throws {
        let directory = try withSnapshotTesting(
            referenceStorage: .directory("__Snapshots__", relativeTo: .testTarget)
        ) {
            try snapshotDirectoryURL(
                explicitPath: nil,
                referenceStorage: SnapshotTestingConfiguration.current?.referenceStorage,
                fileID: "FixtureTests/ChatViewTests.swift",
                filePath: "/workspace/Tests/FixtureTests/Flows/ChatViewTests.swift",
                androidBaseURL: nil
            )
        }

        XCTAssertEqual(
            directory.path,
            "/workspace/Tests/FixtureTests/__Snapshots__/Flows/ChatViewTests"
        )
    }
}
