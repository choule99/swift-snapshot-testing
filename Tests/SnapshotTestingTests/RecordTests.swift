import SnapshotTesting
import XCTest

// SwiftPM's Linux XCTest discovery requires async wrappers for @MainActor test methods.
// swiftformat:disable redundantAsync

class RecordTests: BaseTestCase {
    nonisolated var snapshotURL: URL {
        guard let name = self.name
            .split(separator: " ")
            .flatMap({ String($0).split(separator: ".") })
            .last else {
            preconditionFailure("Could not determine test name")
        }
        let testName = name.prefix(while: { $0 != "]" })
        let fileURL = URL(fileURLWithPath: #filePath, isDirectory: false)
        return fileURL
            .deletingLastPathComponent()
            .appendingPathComponent("__Snapshots__")
            .appendingPathComponent(fileURL.deletingPathExtension().lastPathComponent)
            .appendingPathComponent("\(testName).1.json")
    }

    override func setUp() {
        super.setUp()

        let testDirectory = snapshotURL.deletingLastPathComponent()
        try? FileManager.default
            .removeItem(at: testDirectory)
        try? FileManager.default
            .createDirectory(at: testDirectory, withIntermediateDirectories: true)
    }

    override func tearDown() {
        super.tearDown()
        try? FileManager.default
            .removeItem(at: snapshotURL.deletingLastPathComponent())
    }

    #if canImport(Darwin)
    func testRecordNever() async {
        XCTExpectFailure {
            withSnapshotTesting(record: .never) {
                assertSnapshot(of: 42, as: .json)
            }
        } issueMatcher: {
            $0.compactDescription == """
            failed - No reference was found on disk. New snapshot was not recorded because recording is disabled
            """
        }

        XCTAssertEqual(
            FileManager.default.fileExists(atPath: snapshotURL.path),
            false
        )
    }
    #endif

    #if canImport(Darwin)
    func testRecordMissing() async {
        XCTExpectFailure {
            withSnapshotTesting(record: .missing) {
                assertSnapshot(of: 42, as: .json)
            }
        } issueMatcher: {
            $0.compactDescription.hasPrefix(
                """
                failed - No reference was found on disk. Automatically recorded snapshot: …
                """
            )
        }

        try XCTAssertEqual(
            String(bytes: Data(contentsOf: snapshotURL), encoding: .utf8),
            "42"
        )
    }
    #endif

    #if canImport(Darwin)
    func testRecordMissing_ExistingFile() async throws {
        try Data("999".utf8).write(to: snapshotURL)

        XCTExpectFailure {
            withSnapshotTesting(record: .missing) {
                assertSnapshot(of: 42, as: .json)
            }
        } issueMatcher: {
            $0.compactDescription.hasPrefix(
                """
                failed - Snapshot does not match reference.
                """
            )
        }

        try XCTAssertEqual(
            String(bytes: Data(contentsOf: snapshotURL), encoding: .utf8),
            "999"
        )
    }
    #endif

    #if canImport(Darwin)
    func testRecordAll_Fresh() async throws {
        XCTExpectFailure {
            withSnapshotTesting(record: .all) {
                assertSnapshot(of: 42, as: .json)
            }
        } issueMatcher: {
            $0.compactDescription.hasPrefix(
                """
                failed - Record mode is on. Automatically recorded snapshot: …
                """
            )
        }

        try XCTAssertEqual(
            String(bytes: Data(contentsOf: snapshotURL), encoding: .utf8),
            "42"
        )
    }
    #endif

    #if canImport(Darwin)
    func testRecordAll_Overwrite() async throws {
        try Data("999".utf8).write(to: snapshotURL)

        XCTExpectFailure {
            withSnapshotTesting(record: .all) {
                assertSnapshot(of: 42, as: .json)
            }
        } issueMatcher: {
            $0.compactDescription.hasPrefix(
                """
                failed - Record mode is on. Automatically recorded snapshot: …
                """
            )
        }

        try XCTAssertEqual(
            String(bytes: Data(contentsOf: snapshotURL), encoding: .utf8),
            "42"
        )
    }
    #endif

    #if canImport(Darwin)
    func testRecordFailed_WhenFailure() async throws {
        try Data("999".utf8).write(to: snapshotURL)

        XCTExpectFailure {
            withSnapshotTesting(record: .failed) {
                assertSnapshot(of: 42, as: .json)
            }
        } issueMatcher: {
            $0.compactDescription.hasPrefix(
                """
                failed - Snapshot does not match reference. A new snapshot was automatically recorded.
                """
            )
        }

        try XCTAssertEqual(
            String(bytes: Data(contentsOf: snapshotURL), encoding: .utf8),
            "42"
        )
    }
    #endif

    func testRecordFailed_NoFailure() async throws {
        #if os(Android)
        throw XCTSkip("cannot save next to file on Android")
        #endif
        try Data("42".utf8).write(to: snapshotURL)
        let modifiedDate =
            try XCTUnwrap(try FileManager.default
                .attributesOfItem(atPath: snapshotURL.path)[FileAttributeKey.modificationDate] as? Date)

        withSnapshotTesting(record: .failed) {
            assertSnapshot(of: 42, as: .json)
        }

        try XCTAssertEqual(
            String(bytes: Data(contentsOf: snapshotURL), encoding: .utf8),
            "42"
        )
        XCTAssertEqual(
            try FileManager.default
                .attributesOfItem(atPath: snapshotURL.path)[FileAttributeKey.modificationDate] as? Date,
            modifiedDate
        )
    }

    #if canImport(Darwin)
    func testRecordFailed_MissingFile() async throws {
        XCTExpectFailure {
            withSnapshotTesting(record: .failed) {
                assertSnapshot(of: 42, as: .json)
            }
        } issueMatcher: {
            $0.compactDescription.hasPrefix(
                """
                failed - No reference was found on disk. Automatically recorded snapshot: …
                """
            )
        }

        try XCTAssertEqual(
            String(bytes: Data(contentsOf: snapshotURL), encoding: .utf8),
            "42"
        )
    }
    #endif
}
