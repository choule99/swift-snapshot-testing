import Foundation
import XCTest

public extension Snapshotting where Value == String, Format == String {
    /// A snapshot strategy for comparing UTF-8 strings by line, treating LF, CRLF, and CR line
    /// endings as equivalent.
    static let lines = Snapshotting(pathExtension: "txt", diffing: .lines)
}

extension String {
    init(lossyUTF8 bytes: some Collection<UInt8>) {
        self.init(decoding: bytes, as: UTF8.self)
    }
}

public extension Diffing where Value == String {
    /// A line-diffing strategy for UTF-8 text that treats LF, CRLF, and CR line endings as
    /// equivalent.
    static let lines = Diffing.diff(
        toData: { Data($0.utf8) },
        fromData: { String(lossyUTF8: $0) },
        diffV2: { old, new in
            let old = old.normalizedLineEndings
            let new = new.normalizedLineEndings
            guard old != new else {
                return nil
            }
            let hunks = chunk(
                diff: SnapshotTesting.diff(
                    old.split(separator: "\n", omittingEmptySubsequences: false).map(String.init),
                    new.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
                )
            )
            let failure =
                hunks
                    .flatMap { [$0.patchMark] + $0.lines }
                    .joined(separator: "\n")
            let attachment = DiffAttachment.data(Data(failure.utf8), name: "difference.patch")
            return (failure, [attachment])
        }
    )
}

private extension String {
    var normalizedLineEndings: String {
        replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
    }
}
