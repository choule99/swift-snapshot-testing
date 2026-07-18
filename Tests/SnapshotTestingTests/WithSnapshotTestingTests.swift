import XCTest

@_spi(Internals) @testable import SnapshotTesting

// SwiftPM's Linux XCTest discovery requires async wrappers for @MainActor test methods.
// swiftformat:disable redundantAsync

@MainActor class WithSnapshotTestingTests: XCTestCase {
    func testSnapshotArtifactsDirectory() async {
        let temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)

        XCTAssertEqual(snapshotArtifactsDirectory(nil), temporaryDirectory)
        XCTAssertEqual(snapshotArtifactsDirectory(""), temporaryDirectory)
        XCTAssertEqual(snapshotArtifactsDirectory(" \t\n"), temporaryDirectory)

        let configuredDirectory = URL(fileURLWithPath: "/tmp/snapshot artifacts ", isDirectory: true)
        XCTAssertEqual(
            snapshotArtifactsDirectory("/tmp/snapshot artifacts "),
            configuredDirectory
        )
    }

    func testNesting() async {
        withSnapshotTesting(record: .all) {
            XCTAssertEqual(
                SnapshotTestingConfiguration.current?
                    .diffTool?(currentFilePath: "old.png", failedFilePath: "new.png"),
                """
                @−
                "file://old.png"
                @+
                "file://new.png"

                To configure output for a custom diff tool, use 'withSnapshotTesting'. For example:

                    withSnapshotTesting(diffTool: .ksdiff) {
                      // ...
                    }
                """
            )
            XCTAssertEqual(SnapshotTestingConfiguration.current?.record, .all)
            withSnapshotTesting(diffTool: "ksdiff") {
                XCTAssertEqual(
                    SnapshotTestingConfiguration.current?
                        .diffTool?(currentFilePath: "old.png", failedFilePath: "new.png"),
                    "ksdiff old.png new.png"
                )
                XCTAssertEqual(SnapshotTestingConfiguration.current?.record, .all)
            }
        }
    }

    func testVerifySnapshotDiffToolOverride() async {
        let snapshotDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: snapshotDirectory) }

        let strategy = Snapshotting<String, String>(pathExtension: "txt", diffing: .lines) { value in
            XCTAssertEqual(
                SnapshotTestingConfiguration.current?
                    .diffTool?(currentFilePath: "old.txt", failedFilePath: "new.txt"),
                "inner old.txt new.txt"
            )
            return value
        }

        withSnapshotTesting(diffTool: "outer") {
            _ = verifySnapshot(
                of: "Blob",
                as: strategy,
                named: "per-call-diff-tool",
                record: .never,
                diffTool: "inner",
                snapshotDirectory: snapshotDirectory.path
            )

            XCTAssertEqual(
                SnapshotTestingConfiguration.current?
                    .diffTool?(currentFilePath: "old.txt", failedFilePath: "new.txt"),
                "outer old.txt new.txt"
            )
        }
    }
}
