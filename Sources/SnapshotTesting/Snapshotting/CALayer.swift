#if os(macOS)
import AppKit
import Cocoa
import QuartzCore

@MainActor public extension Snapshotting where Value == CALayer, Format == NSImage {
    /// A snapshot strategy for comparing layers based on pixel equality.
    ///
    /// ``` swift
    /// // Match reference perfectly.
    /// assertSnapshot(of: layer, as: .image)
    ///
    /// // Allow for a 1% pixel difference.
    /// assertSnapshot(of: layer, as: .image(precision: 0.99))
    /// ```
    static var image: Snapshotting {
        .image(precision: 1)
    }

    /// A snapshot strategy for comparing layers based on pixel equality.
    ///
    /// - Parameters:
    ///   - precision: The percentage of pixels that must match.
    ///   - perceptualPrecision: The percentage a pixel must match the source pixel to be considered a
    ///     match. 98-99% mimics
    ///     [the precision](http://zschuessler.github.io/DeltaE/learn/#toc-defining-delta-e) of the
    ///     human eye.
    static func image(precision: Float, perceptualPrecision: Float = 1) -> Snapshotting {
        SimplySnapshotting.image(
            precision: precision, perceptualPrecision: perceptualPrecision
        ).pullback { layer in
            let image = NSImage(size: layer.bounds.size)
            image.lockFocus()
            defer { image.unlockFocus() }
            guard let context = NSGraphicsContext.current?.cgContext else {
                preconditionFailure("Expected a graphics context after locking focus")
            }
            layer.setNeedsLayout()
            layer.layoutIfNeeded()
            layer.render(in: context)
            return image
        }
    }
}
#elseif os(iOS) || os(tvOS)
import UIKit

@MainActor public extension Snapshotting where Value == CALayer, Format == UIImage {
    /// A snapshot strategy for comparing layers based on pixel equality.
    static var image: Snapshotting {
        .image()
    }

    /// A snapshot strategy for comparing layers based on pixel equality.
    ///
    /// - Parameters:
    ///   - precision: The percentage of pixels that must match.
    ///   - perceptualPrecision: The percentage a pixel must match the source pixel to be considered a
    ///     match. 98-99% mimics
    ///     [the precision](http://zschuessler.github.io/DeltaE/learn/#toc-defining-delta-e) of the
    ///     human eye.
    ///   - traits: A trait collection override.
    static func image(
        precision: Float = 1, perceptualPrecision: Float = 1, traits: UITraitCollection = .init()
    )
        -> Snapshotting {
        SimplySnapshotting.image(
            precision: precision, perceptualPrecision: perceptualPrecision, scale: traits.displayScale
        ).pullback { layer in
            renderer(bounds: layer.bounds, for: traits).image { ctx in
                layer.setNeedsLayout()
                layer.layoutIfNeeded()
                layer.render(in: ctx.cgContext)
            }
        }
    }
}
#endif
