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
        /// assertSnapshot(of: layer, as: .image(options: .init(precision: 0.99)))
        /// ```
        static var image: Snapshotting {
            .image(options: .init())
        }

        /// A snapshot strategy for comparing layers based on pixel equality.
        ///
        /// - Parameters:
        ///   - options: The image comparison options.
        ///   - isOpaque: Whether to composite transparency onto white and omit the alpha channel.
        static func image(
            options: ImageSnapshotOptions = .init(),
            isOpaque: Bool = false
        ) -> Snapshotting {
            SimplySnapshotting.image(
                options: options,
                isOpaque: isOpaque
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

        @available(*, deprecated, message: "Use image(options:isOpaque:) instead") static func image(
            precision: Float,
            perceptualPrecision: Float = 1,
            isOpaque: Bool = false
        ) -> Snapshotting {
            .image(
                options: .init(precision: precision, perceptualPrecision: perceptualPrecision),
                isOpaque: isOpaque
            )
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
        ///   - options: The image comparison options.
        ///   - traits: A trait collection override.
        ///   - isOpaque: Whether to composite transparency onto white and omit the alpha channel.
        static func image(
            options: ImageSnapshotOptions = .init(),
            traits: UITraitCollection = .init(),
            isOpaque: Bool = false
        )
            -> Snapshotting {
            SimplySnapshotting.image(
                options: options,
                scale: traits.displayScale,
                isOpaque: isOpaque
            ).pullback { layer in
                renderer(bounds: layer.bounds, for: traits).image { ctx in
                    layer.setNeedsLayout()
                    layer.layoutIfNeeded()
                    layer.render(in: ctx.cgContext)
                }
            }
        }

        @available(*, deprecated, message: "Use image(options:traits:isOpaque:) instead") static func image(
            precision: Float = 1,
            perceptualPrecision: Float = 1,
            traits: UITraitCollection = .init(),
            isOpaque: Bool = false
        ) -> Snapshotting {
            .image(
                options: .init(precision: precision, perceptualPrecision: perceptualPrecision),
                traits: traits,
                isOpaque: isOpaque
            )
        }
    }
#endif
