@testable import SnapshotTesting
import XCTest

final class StringSpecialCharactersTests: XCTestCase {
    func testEscapedSpecialCharacterLiterals() {
        for literal in [#"\0"#, #"\\"#, #"\t"#, #"\n"#, #"\r"#, #"\""#, #"\'"#, "\"\"\"#"] {
            XCTAssertTrue(literal.hasEscapedSpecialCharactersLiteral())
        }
    }

    func testUnicodeEscapedSpecialCharacterLiterals() {
        XCTAssertTrue("😀\\u{1F600}".hasEscapedSpecialCharactersLiteral())
        XCTAssertFalse(#"\u{}"#.hasEscapedSpecialCharactersLiteral())
        XCTAssertFalse(#"\u{123456789}"#.hasEscapedSpecialCharactersLiteral())
        XCTAssertFalse(#"\u{_}"#.hasEscapedSpecialCharactersLiteral())
        XCTAssertFalse(#"\u{not-hex}"#.hasEscapedSpecialCharactersLiteral())
    }

    func testActualWhitespaceIsNotEscapedSpecialCharacterLiteral() {
        XCTAssertFalse("\t".hasEscapedSpecialCharactersLiteral())
        XCTAssertFalse("\n".hasEscapedSpecialCharactersLiteral())
    }

    func testNumberSignsNeeded() {
        XCTAssertEqual("plain".numberOfNumberSignsNeeded(), 1)
        XCTAssertEqual("😀\"###".numberOfNumberSignsNeeded(), 4)
        XCTAssertEqual("\"# \"#####".numberOfNumberSignsNeeded(), 6)
    }
}
