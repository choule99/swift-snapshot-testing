#if os(macOS)
import AppKit
import Cocoa

@MainActor public extension Snapshotting where Value: NSViewController, Format == NSImage {
    /// A snapshot strategy for comparing view controller views based on pixel equality.
    static var image: Snapshotting {
        .image()
    }

    /// A snapshot strategy for comparing view controller views based on pixel equality.
    ///
    /// - Parameters:
    ///   - precision: The percentage of pixels that must match.
    ///   - perceptualPrecision: The percentage a pixel must match the source pixel to be considered a
    ///     match. 98-99% mimics
    ///     [the precision](http://zschuessler.github.io/DeltaE/learn/#toc-defining-delta-e) of the
    ///     human eye.
    ///   - size: A view size override.
    static func image(
        precision: Float = 1, perceptualPrecision: Float = 1, size: CGSize? = nil
    ) -> Snapshotting {
        Snapshotting<NSView, NSImage>.image(
            precision: precision, perceptualPrecision: perceptualPrecision, size: size
        ).pullback { $0.view }
    }
}

@MainActor public extension Snapshotting where Value: NSViewController, Format == String {
    /// A snapshot strategy for comparing view controller views based on a recursive description of
    /// their properties and hierarchies.
    static var recursiveDescription: Snapshotting {
        Snapshotting<NSView, String>.recursiveDescription.pullback { $0.view }
    }
}
#endif
