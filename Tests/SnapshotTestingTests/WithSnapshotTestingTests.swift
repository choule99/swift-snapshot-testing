import XCTest

@_spi(Internals) @testable import SnapshotTesting

// SwiftPM's Linux XCTest discovery requires async wrappers for @MainActor test methods.
// swiftformat:disable redundantAsync

@MainActor class WithSnapshotTestingTests: XCTestCase {
    func testSnapshotNaming() async throws {
        let snapshotDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: snapshotDirectory) }

        func verify(_ value: Int, testName: String) -> String? {
            verifySnapshot(
                of: value,
                as: .json,
                options: SnapshotAssertionOptions(
                    record: .all,
                    snapshotDirectory: snapshotDirectory.path
                ),
                testName: testName
            )
        }

        _ = verify(1, testName: "numbered")
        _ = verify(2, testName: "numbered")
        let numberedURL = snapshotDirectory.appendingPathComponent("numbered")
        XCTAssertEqual(
            try String(contentsOf: numberedURL.appendingPathExtension("1.json"), encoding: .utf8),
            "1"
        )
        XCTAssertEqual(
            try String(contentsOf: numberedURL.appendingPathExtension("2.json"), encoding: .utf8),
            "2"
        )

        let collision = withSnapshotTesting(snapshotNaming: .testName) {
            _ = verify(42, testName: "counterless")
            return verify(999, testName: "counterless")
        }

        let counterlessURL = snapshotDirectory.appendingPathComponent("counterless.json")
        XCTAssertEqual(
            collision,
            """
            Multiple unnamed snapshots would use the same reference: \(counterlessURL.path)
            Name additional snapshots with 'named:' or use snapshot naming '.numbered'.
            """
        )
        XCTAssertEqual(try String(contentsOf: counterlessURL, encoding: .utf8), "42")
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: snapshotDirectory.appendingPathComponent("counterless.1.json").path
            )
        )
    }

    func testSnapshotArtifactsDirectory() async {
        let temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let environmentDirectory = URL(fileURLWithPath: "/environment", isDirectory: true)
        let explicitDirectory = URL(fileURLWithPath: "/explicit", isDirectory: true)

        XCTAssertEqual(
            snapshotArtifactsDirectory("/explicit", environmentPath: "/environment"),
            explicitDirectory
        )
        XCTAssertEqual(
            snapshotArtifactsDirectory(nil, environmentPath: "/environment"),
            environmentDirectory
        )
        XCTAssertEqual(
            snapshotArtifactsDirectory("", environmentPath: "/environment"),
            environmentDirectory
        )
        XCTAssertEqual(snapshotArtifactsDirectory(nil, environmentPath: nil), temporaryDirectory)
        XCTAssertEqual(snapshotArtifactsDirectory("", environmentPath: ""), temporaryDirectory)
        XCTAssertEqual(snapshotArtifactsDirectory(" \t\n", environmentPath: " \n"), temporaryDirectory)

        let configuredDirectory = URL(fileURLWithPath: "/tmp/snapshot artifacts ", isDirectory: true)
        XCTAssertEqual(
            snapshotArtifactsDirectory("/tmp/snapshot artifacts ", environmentPath: nil),
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

    func testSnapshotEnvironmentDefaultsAndNesting() async throws {
        XCTAssertEqual(SnapshotTestingConfiguration.resolvedLocale.identifier, "en_US_POSIX")
        XCTAssertEqual(SnapshotTestingConfiguration.resolvedTimeZone.secondsFromGMT(), 0)
        XCTAssertEqual(SnapshotTestingConfiguration.resolvedCalendar.identifier, .gregorian)

        let locale = Locale(identifier: "fr_CA")
        let timeZone = try XCTUnwrap(TimeZone(identifier: "America/Toronto"))
        var calendar = Calendar(identifier: .hebrew)
        calendar.locale = locale
        calendar.timeZone = timeZone

        withSnapshotTesting(locale: locale, timeZone: timeZone, calendar: calendar) {
            XCTAssertEqual(SnapshotTestingConfiguration.resolvedLocale, locale)
            XCTAssertEqual(SnapshotTestingConfiguration.resolvedTimeZone, timeZone)
            XCTAssertEqual(SnapshotTestingConfiguration.resolvedCalendar, calendar)

            withSnapshotTesting(record: .all) {
                XCTAssertEqual(SnapshotTestingConfiguration.resolvedLocale, locale)
                XCTAssertEqual(SnapshotTestingConfiguration.resolvedTimeZone, timeZone)
                XCTAssertEqual(SnapshotTestingConfiguration.resolvedCalendar, calendar)
            }
        }
    }

    func testConfigurationBuilderAndOverloads() async throws {
        let locale = Locale(identifier: "fr_CA")
        let timeZone = try XCTUnwrap(TimeZone(identifier: "America/Toronto"))
        let calendar = Calendar(identifier: .hebrew)
        let original = SnapshotTestingConfiguration()
        let configuration = original
            .recording(.all)
            .usingDiffTool("diff")
            .namingSnapshots(.testName)
            .usingLocale(locale)
            .usingTimeZone(timeZone)
            .usingCalendar(calendar)

        XCTAssertNil(original.record)
        XCTAssertNil(original.locale)
        withSnapshotTesting(configuration) {
            XCTAssertEqual(SnapshotTestingConfiguration.current?.record, .all)
            XCTAssertEqual(SnapshotTestingConfiguration.current?.snapshotNaming, .testName)
            XCTAssertEqual(SnapshotTestingConfiguration.resolvedLocale, locale)
            XCTAssertEqual(SnapshotTestingConfiguration.resolvedTimeZone, timeZone)
            XCTAssertEqual(SnapshotTestingConfiguration.resolvedCalendar, calendar)
        }
        await withSnapshotTesting(configuration) {
            await Task.yield()
            XCTAssertEqual(SnapshotTestingConfiguration.current?.record, .all)
        }
    }

    func testAssertionOptionsBuilder() async {
        let original = SnapshotAssertionOptions()
        let options = original
            .recording(.failed)
            .usingDiffTool("diff")
            .savingSnapshots(in: "/snapshots")
            .savingArtifacts(in: "/artifacts")
            .waiting(upTo: 10)

        XCTAssertNil(original.record)
        XCTAssertEqual(original.timeout, 5)
        XCTAssertEqual(options.record, .failed)
        XCTAssertEqual(options.snapshotDirectory, "/snapshots")
        XCTAssertEqual(options.artifactsDirectory, "/artifacts")
        XCTAssertEqual(options.timeout, 10)
        XCTAssertEqual(
            options.diffTool?(currentFilePath: "old", failedFilePath: "new"),
            "diff old new"
        )
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
                options: SnapshotAssertionOptions(
                    record: .never,
                    diffTool: "inner",
                    snapshotDirectory: snapshotDirectory.path
                )
            )

            XCTAssertEqual(
                SnapshotTestingConfiguration.current?
                    .diffTool?(currentFilePath: "old.txt", failedFilePath: "new.txt"),
                "outer old.txt new.txt"
            )
        }
    }
}
