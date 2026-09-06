#if canImport(UniformTypeIdentifiers)
    import CustomDump
    import UniformTypeIdentifiers
    import XCTest

    class UniformTypeIdentifiersTests: XCTestCase {
        func testUniformTypeIdentifiers() {
            XCTAssertEqual(
                String(customDumping: [UTType.data, .jpeg, .pdf]),
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
#endif
