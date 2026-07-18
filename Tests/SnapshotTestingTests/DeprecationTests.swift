import SnapshotTesting
import XCTest

// SwiftPM's Linux XCTest discovery requires async wrappers for @MainActor test methods.
// swiftformat:disable redundantAsync

@MainActor final class DeprecationTests: XCTestCase {
    @available(*, deprecated) func testIsRecordingProxy() async {
        SnapshotTesting.record = true
        XCTAssertEqual(isRecording, true)

        SnapshotTesting.record = false
        XCTAssertEqual(isRecording, false)
    }
}
