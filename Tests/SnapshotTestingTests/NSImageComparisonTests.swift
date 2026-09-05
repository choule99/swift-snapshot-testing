#if os(macOS)
import AppKit
import SnapshotTesting
import XCTest

final class NSImageComparisonTests: XCTestCase {
    @MainActor func testIdenticalPixelsWithDifferentRowStrides() throws {
        let packed = try image(bytesPerRow: 16, color: .red)
        let padded = try image(bytesPerRow: 64, color: .red)
        for options in [ImageSnapshotOptions(), .init(precision: 0.99)] {
            let diffing = Diffing<NSImage>.image(options: options)
            XCTAssertNil(diffing.diffV2(packed, padded))
            XCTAssertNil(diffing.diffV2(padded, packed))
        }
    }

    @MainActor func testChangedPixelsBeyondFirstPaddedRowAreDetected() throws {
        let packed = try image(bytesPerRow: 16, color: .clear)
        let padded = try image(bytesPerRow: 64, color: .red, height: 1)
        for options in [ImageSnapshotOptions(), .init(precision: 0.99)] {
            let diffing = Diffing<NSImage>.image(options: options)
            XCTAssertNotNil(diffing.diffV2(packed, padded))
            XCTAssertNotNil(diffing.diffV2(padded, packed))
        }
    }

    @MainActor func testExactPrecisionCountsRGBAComponents() throws {
        let red = try image(bytesPerRow: 16, color: .red)
        let blue = try image(bytesPerRow: 64, color: .blue)
        // Red and blue differ in two of four components at every pixel.
        XCTAssertNil(Diffing<NSImage>.image(options: .init(precision: 0.5)).diffV2(red, blue))
        XCTAssertNotNil(Diffing<NSImage>.image(options: .init(precision: 0.51)).diffV2(red, blue))
    }

    @MainActor private func image(bytesPerRow: Int, color: NSColor, height: Int = 2) throws -> NSImage {
        let context = try XCTUnwrap(CGContext(
            data: nil,
            width: 4,
            height: 2,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB)),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ))
        context.clear(CGRect(x: 0, y: 0, width: 4, height: 2))
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: 4, height: height))
        return NSImage(cgImage: try XCTUnwrap(context.makeImage()), size: NSSize(width: 4, height: 2))
    }
}
#endif
