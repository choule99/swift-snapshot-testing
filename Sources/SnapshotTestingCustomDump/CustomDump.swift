#if canImport(CustomDump)
import CustomDump
import SnapshotTesting

public extension Snapshotting where Format == String {
    /// A snapshot strategy for comparing any structure based on a
    /// Custom dump.
    ///
    /// ```swift
    /// assertSnapshot(of: user, as: .customDump)
    /// ```
    ///
    /// Records:
    ///
    /// ```
    /// User(
    ///   bio: "Blobbed around the world.",
    ///   id: 1,
    ///   name: "Blobby"
    /// )
    /// ```
    static var customDump: Snapshotting {
        SimplySnapshotting.lines.pullback(String.init(customDumping:))
    }
}
#endif
