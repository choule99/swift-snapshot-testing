import Foundation
@testable import SnapshotTesting
import XCTest

// SwiftPM's Linux XCTest discovery requires async wrappers for @MainActor test methods.
// swiftformat:disable redundantAsync

@MainActor final class SegmentedSnapshotNameTests: XCTestCase {
    func testSegmentsAreSanitizedIndependentlyAndJoinedWithPeriods() async throws {
        let snapshotDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: snapshotDirectory) }

        _ = SegmentedSnapshotName.$components.withValue(["compact light", "empty state"]) {
            verifySnapshot(
                of: 42,
                as: .json,
                options: .init(record: .all, snapshotDirectory: snapshotDirectory.path),
                testName: "test_chat"
            )
        }

        let reference = snapshotDirectory
            .appendingPathComponent("test_chat.compact-light.empty-state.json")
        XCTAssertEqual(try String(contentsOf: reference, encoding: .utf8), "42")
    }

    func testPublicNamedSnapshotRemainsOneSanitizedSegment() async throws {
        let snapshotDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: snapshotDirectory) }

        _ = verifySnapshot(
            of: 42,
            as: .json,
            named: "compact.light",
            options: .init(record: .all, snapshotDirectory: snapshotDirectory.path),
            testName: "test_chat"
        )

        let reference = snapshotDirectory.appendingPathComponent("test_chat.compact-light.json")
        XCTAssertEqual(try String(contentsOf: reference, encoding: .utf8), "42")
    }
}
