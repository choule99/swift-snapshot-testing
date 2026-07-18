@testable import SnapshotTesting
import XCTest

// SwiftPM's Linux XCTest discovery requires async wrappers for @MainActor test methods.
// swiftformat:disable redundantAsync

class WaitTests: BaseTestCase {
    func testWait() async {
        let value = LockIsolated("Hello")
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            value.withLock { $0 = "Goodbye" }
        }

        let strategy = Snapshotting.lines.pullback { (_: Void) in
            value.withLock { $0 }
        }

        assertSnapshot(of: (), as: .wait(for: 1.5, on: strategy))
    }
}
