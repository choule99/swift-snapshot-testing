#if canImport(UniformTypeIdentifiers)
import CustomDump
import UniformTypeIdentifiers
import XCTest

class UniformTypeIdentifiersTests: XCTestCase {
    func testUniformTypeIdentifiers() {
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
            var dump = ""
            customDump([UTType.data, .jpeg, .pdf], to: &dump)
            XCTAssertEqual(
                dump,
                """
                [
                  [0]: UTType(public.data),
                  [1]: UTType(public.jpeg),
                  [2]: UTType(com.adobe.pdf)
                ]
                """
            )
        }
    }
}
#endif
