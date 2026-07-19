import Foundation

public extension Snapshotting where Format == String {
    /// A snapshot strategy that captures a value's textual description from `String`'s
    /// `init(describing:)` initializer.
    ///
    /// ``` swift
    /// assertSnapshot(of: user, as: .description)
    /// ```
    ///
    /// Records:
    ///
    /// ```
    /// User(bio: "Blobbed around the world.", id: 1, name: "Blobby")
    /// ```
    static var description: Snapshotting {
        SimplySnapshotting.lines.pullback(String.init(describing:))
    }
}

@available(macOS 10.13, watchOS 4.0, tvOS 11.0, *) public extension Snapshotting where Format == String {
    /// A snapshot strategy for comparing any structure based on their JSON representation.
    static var json: Snapshotting {
        let options: JSONSerialization.WritingOptions = [
            .prettyPrinted,
            .sortedKeys
        ]

        var snapshotting = SimplySnapshotting.lines.pullback { (data: Value) in
            do {
                let json = try JSONSerialization.data(
                    withJSONObject: data,
                    options: options
                )
                guard let string = String(bytes: json, encoding: .utf8) else {
                    preconditionFailure("Expected JSONSerialization to produce UTF-8")
                }
                return string
            } catch {
                preconditionFailure("Could not serialize value as JSON: \(error)")
            }
        }
        snapshotting.pathExtension = "json"
        return snapshotting
    }
}

func purgePointers(_ string: String) -> String {
    string.replacingOccurrences(
        of: ":?\\s*0x[\\da-f]+(\\s*)", with: "$1", options: .regularExpression
    )
}
