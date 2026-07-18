#if canImport(Testing)
import Foundation
import Testing

/// A type representing the configuration of snapshot testing.
public struct _SnapshotsTestTrait: SuiteTrait, TestTrait {
    public let isRecursive = true
    let configuration: SnapshotTestingConfiguration
}

public extension Trait where Self == _SnapshotsTestTrait {
    /// Configure snapshot testing in a suite or test.
    static var snapshots: Self {
        snapshots()
    }

    /// Configure snapshot testing in a suite or test.
    ///
    /// - Parameters:
    ///   - record: The record mode of the test.
    ///   - diffTool: The diff tool to use in failure messages.
    ///   - snapshotNaming: The naming strategy for unnamed snapshots.
    ///   - locale: The locale for SwiftUI snapshots. Defaults to `en_US_POSIX`.
    ///   - timeZone: The time zone for SwiftUI snapshots. Defaults to UTC.
    ///   - calendar: The calendar for SwiftUI snapshots. Defaults to Gregorian.
    static func snapshots(
        record: SnapshotTestingConfiguration.Record? = nil,
        diffTool: SnapshotTestingConfiguration.DiffTool? = nil,
        snapshotNaming: SnapshotTestingConfiguration.SnapshotNaming? = nil,
        locale: Locale? = nil,
        timeZone: TimeZone? = nil,
        calendar: Calendar? = nil
    ) -> Self {
        _SnapshotsTestTrait(
            configuration: SnapshotTestingConfiguration(
                record: record,
                diffTool: diffTool,
                snapshotNaming: snapshotNaming,
                locale: locale,
                timeZone: timeZone,
                calendar: calendar
            )
        )
    }

    /// Configure snapshot testing in a suite or test.
    ///
    /// - Parameter configuration: The configuration to use.
    static func snapshots(
        _ configuration: SnapshotTestingConfiguration
    ) -> Self {
        _SnapshotsTestTrait(configuration: configuration)
    }
}

#if compiler(>=6.1)
extension _SnapshotsTestTrait: TestScoping {
    public func provideScope(
        for test: Test,
        testCase: Test.Case?,
        performing function: () async throws -> Void
    ) async throws {
        try await withSnapshotTesting(
            record: configuration.record,
            diffTool: configuration.diffTool,
            snapshotNaming: configuration.snapshotNaming,
            locale: configuration.locale,
            timeZone: configuration.timeZone,
            calendar: configuration.calendar
        ) {
            try await File.$counter.withValue(File.Counter()) {
                try await function()
            }
        }
    }
}
#endif
#endif
