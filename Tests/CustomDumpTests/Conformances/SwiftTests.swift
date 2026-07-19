import CustomDump
import XCTest

final class SwiftTests: XCTestCase {
    func testCharacter() {
        let character: Character = "a"
        expectNoDifference(
            String(customDumping: character),
            """
            "a"
            """
        )
    }

    func testObjectIdentifier() {
        let user = UserClass(id: 1, name: "")
        let objectIdentifier = ObjectIdentifier(user)

        expectNoDifference(
            String(customDumping: objectIdentifier).replacingOccurrences(
                of: ":?\\s*0x[\\da-f]+(\\s*)", with: "$1", options: .regularExpression
            ),
            """
            ObjectIdentifier()
            """
        )
    }

    func testStaticString() {
        let string: StaticString = "hello world!"
        expectNoDifference(
            String(customDumping: string),
            """
            "hello world!"
            """
        )
    }

    func testUnicodeScalar() throws {
        let scalar = try XCTUnwrap("a".unicodeScalars.first)
        expectNoDifference(
            String(customDumping: scalar),
            """
            "a"
            """
        )
    }

    func testAnyHashable() {
        let user: AnyHashable = HashableUser(id: 1, name: "James")
        expectNoDifference(
            String(customDumping: user),
            """
            HashableUser(
              id: 1,
              name: "James"
            )
            """
        )
    }
}
