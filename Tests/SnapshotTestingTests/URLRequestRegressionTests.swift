#if !os(WASI)
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import SnapshotTesting
import XCTest

// SwiftPM's Linux XCTest discovery requires async wrappers for @MainActor test methods.
// swiftformat:disable redundantAsync

final class URLRequestRegressionTests: XCTestCase {
    @MainActor func testBinaryBodiesRemainDistinct() async throws {
        var request = URLRequest(url: try XCTUnwrap(URL(string: "https://example.com")))
        request.httpMethod = "POST"
        for pretty in [false, true] {
            request.httpBody = Data([0x80])
            let first = try snapshot(request, as: .raw(pretty: pretty))
            request.httpBody = Data([0x81])
            let second = try snapshot(request, as: .raw(pretty: pretty))
            XCTAssertNotEqual(first, second)
            XCTAssertTrue(first.hasSuffix("\n\n[Base64] gA=="))
            XCTAssertTrue(second.hasSuffix("\n\n[Base64] gQ=="))
            request.httpBody = Data("[Base64] gA==".utf8)
            XCTAssertNotEqual(first, try snapshot(request, as: .raw(pretty: pretty)))
        }
        request.httpBody = Data("Hello 🌍".utf8)
        XCTAssertTrue(try snapshot(request, as: .raw).hasSuffix("\n\nHello 🌍"))
        request.httpBody = Data()
        XCTAssertTrue(try snapshot(request, as: .raw).hasSuffix("\n\n"))
        request.httpBody = nil
        XCTAssertEqual(try snapshot(request, as: .raw), "POST https://example.com")
    }

    @MainActor private func snapshot(
        _ request: URLRequest,
        as strategy: Snapshotting<URLRequest, String>
    ) throws -> String {
        var result: String?
        strategy.snapshot(request).run { result = $0 }
        return try XCTUnwrap(result)
    }
}
#endif
