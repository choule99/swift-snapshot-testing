import Foundation
import XCTest

// Deprecated after 1.18.9:

@available(
    *, deprecated,
    message: "Use overload with 'record: SnapshotTestingConfiguration.Record?'"
)
@MainActor @_disfavoredOverload public func assertSnapshot<Value>(
    of value: @autoclosure () throws -> Value,
    as snapshotting: Snapshotting<Value, some Any>,
    named name: String? = nil,
    record recording: Bool? = nil,
    timeout: TimeInterval = 5,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    assertSnapshot(
        of: try value(),
        as: snapshotting,
        named: name,
        record: SnapshotTestingConfiguration.Record(recording),
        timeout: timeout,
        fileID: fileID,
        file: filePath,
        testName: testName,
        line: line,
        column: column
    )
}

@available(
    *, deprecated,
    message: "Use overload with 'record: SnapshotTestingConfiguration.Record?'"
)
@MainActor @_disfavoredOverload public func assertSnapshots<Value>(
    of value: @autoclosure () throws -> Value,
    as strategies: [String: Snapshotting<Value, some Any>],
    record recording: Bool? = nil,
    timeout: TimeInterval = 5,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    assertSnapshots(
        of: try value(),
        as: strategies,
        record: SnapshotTestingConfiguration.Record(recording),
        timeout: timeout,
        fileID: fileID,
        file: filePath,
        testName: testName,
        line: line,
        column: column
    )
}

@available(
    *, deprecated,
    message: "Use overload with 'record: SnapshotTestingConfiguration.Record?'"
)
@MainActor @_disfavoredOverload public func assertSnapshots<Value>(
    of value: @autoclosure () throws -> Value,
    as strategies: [Snapshotting<Value, some Any>],
    record recording: Bool? = nil,
    timeout: TimeInterval = 5,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    assertSnapshots(
        of: try value(),
        as: strategies,
        record: SnapshotTestingConfiguration.Record(recording),
        timeout: timeout,
        fileID: fileID,
        file: filePath,
        testName: testName,
        line: line,
        column: column
    )
}

@available(
    *, deprecated,
    message: "Use overload with 'record: SnapshotTestingConfiguration.Record?'"
)
@MainActor @_disfavoredOverload public func verifySnapshot<Value>(
    of value: @autoclosure () throws -> Value,
    as snapshotting: Snapshotting<Value, some Any>,
    named name: String? = nil,
    record recording: Bool? = nil,
    snapshotDirectory: String? = nil,
    timeout: TimeInterval = 5,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) -> String? {
    verifySnapshot(
        of: try value(),
        as: snapshotting,
        named: name,
        record: SnapshotTestingConfiguration.Record(recording),
        snapshotDirectory: snapshotDirectory,
        timeout: timeout,
        fileID: fileID,
        file: filePath,
        testName: testName,
        line: line,
        column: column
    )
}

private extension SnapshotTestingConfiguration.Record {
    init?(_ recording: Bool?) {
        guard let recording else {
            return nil
        }
        self = recording ? .all : .missing
    }
}

// Deprecated after 1.11.1:

@available(*, deprecated, renamed: "assertSnapshot(of:as:named:record:timeout:file:testName:line:)") @MainActor public func assertSnapshot<Value>(
    matching value: @autoclosure () throws -> Value,
    as snapshotting: Snapshotting<Value, some Any>,
    named name: String? = nil,
    record recording: Bool? = nil,
    timeout: TimeInterval = 5,
    file: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line
) {
    assertSnapshot(
        of: try value(),
        as: snapshotting,
        named: name,
        record: recording,
        timeout: timeout,
        file: file,
        testName: testName,
        line: line
    )
}

@available(
    *, deprecated, renamed: "assertSnapshots(of:as:named:record:timeout:file:testName:line:)"
) @MainActor public func assertSnapshots<Value>(
    matching value: @autoclosure () throws -> Value,
    as strategies: [String: Snapshotting<Value, some Any>],
    record recording: Bool? = nil,
    timeout: TimeInterval = 5,
    file: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line
) {
    assertSnapshots(
        of: try value(),
        as: strategies,
        record: recording,
        timeout: timeout,
        file: file,
        testName: testName,
        line: line
    )
}

@available(
    *, deprecated, renamed: "assertSnapshots(of:as:named:record:timeout:file:testName:line:)"
) @MainActor public func assertSnapshots<Value>(
    matching value: @autoclosure () throws -> Value,
    as strategies: [Snapshotting<Value, some Any>],
    record recording: Bool? = nil,
    timeout: TimeInterval = 5,
    file: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line
) {
    assertSnapshots(
        of: try value(),
        as: strategies,
        record: recording,
        timeout: timeout,
        file: file,
        testName: testName,
        line: line
    )
}

@available(
    *, deprecated,
    renamed: "verifySnapshot(of:as:named:record:snapshotDirectory:timeout:file:testName:line:)"
) @MainActor public func verifySnapshot<Value>(
    matching value: @autoclosure () throws -> Value,
    as snapshotting: Snapshotting<Value, some Any>,
    named name: String? = nil,
    record recording: Bool? = nil,
    snapshotDirectory: String? = nil,
    timeout: TimeInterval = 5,
    file: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line
) -> String? {
    verifySnapshot(
        of: try value(),
        as: snapshotting,
        named: name,
        record: SnapshotTestingConfiguration.Record(recording),
        snapshotDirectory: snapshotDirectory,
        timeout: timeout,
        file: file,
        testName: testName,
        line: line
    )
}

@available(*, deprecated, renamed: "XCTestCase")
public typealias SnapshotTestCase = XCTestCase

@available(*, deprecated, renamed: "isRecording") public var record: Bool {
    get { isRecording }
    set { isRecording = newValue }
}
