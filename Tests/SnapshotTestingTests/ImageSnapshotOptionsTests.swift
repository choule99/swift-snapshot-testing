import SnapshotTesting
import XCTest
#if os(macOS)
import AppKit
import QuartzCore
import SceneKit
import SpriteKit
#endif

final class ImageSnapshotOptionsTests: XCTestCase {
    func testDefaultsAndBuilderValueSemantics() {
        let defaults = ImageSnapshotOptions()
        #if os(watchOS)
        let customized = defaults.requiringPixelPrecision(0.99)
        #else
        let customized = defaults
            .requiringPixelPrecision(0.99)
            .requiringPerceptualPrecision(0.98)
        #endif

        XCTAssertEqual(defaults.precision, 1)
        XCTAssertEqual(customized.precision, 0.99)
        #if !os(watchOS)
        XCTAssertEqual(defaults.perceptualPrecision, 1)
        XCTAssertEqual(customized.perceptualPrecision, 0.98)
        #endif
    }

    #if os(macOS)
    @MainActor func testMacOSImageStrategiesAcceptOptions() {
        let options = ImageSnapshotOptions(precision: 0.99, perceptualPrecision: 0.98)

        _ = Diffing<NSImage>.image(options: options)
        _ = Snapshotting<NSImage, NSImage>.image(options: options)
        _ = Snapshotting<NSView, NSImage>.image(options: options)
        _ = Snapshotting<NSViewController, NSImage>.image(options: options)
        _ = Snapshotting<CALayer, NSImage>.image(options: options)
        _ = Snapshotting<CGPath, NSImage>.image(options: options)
        _ = Snapshotting<NSBezierPath, NSImage>.image(options: options)
        _ = Snapshotting<SCNScene, NSImage>.image(options: options, size: .init(width: 1, height: 1))
        _ = Snapshotting<SKScene, NSImage>.image(options: options, size: .init(width: 1, height: 1))
    }
    #endif
}
