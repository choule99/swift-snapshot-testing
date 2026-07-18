#if os(iOS) || os(tvOS)
import UIKit

@MainActor public extension Snapshotting where Value == UIBezierPath, Format == UIImage {
    /// A snapshot strategy for comparing bezier paths based on pixel equality.
    static var image: Snapshotting {
        .image()
    }

    /// A snapshot strategy for comparing bezier paths based on pixel equality.
    ///
    /// - Parameters:
    ///   - options: The image comparison options.
    ///   - scale: The scale to use when loading the reference image from disk.
    static func image(
        options: ImageSnapshotOptions = .init(), scale: CGFloat = 1
    ) -> Snapshotting {
        SimplySnapshotting.image(
            options: options, scale: scale
        ).pullback { path in
            let bounds = path.bounds
            let format = if #available(iOS 11.0, tvOS 11.0, *) {
                UIGraphicsImageRendererFormat.preferred()
            } else {
                UIGraphicsImageRendererFormat.default()
            }
            format.scale = scale
            return UIGraphicsImageRenderer(bounds: bounds, format: format).image { _ in
                path.fill()
            }
        }
    }

    @available(*, deprecated, message: "Use image(options:scale:) instead") static func image(
        precision: Float = 1, perceptualPrecision: Float = 1, scale: CGFloat = 1
    ) -> Snapshotting {
        .image(
            options: .init(precision: precision, perceptualPrecision: perceptualPrecision),
            scale: scale
        )
    }
}

@available(iOS 11.0, tvOS 11.0, *) @MainActor public extension Snapshotting where Value == UIBezierPath, Format == String {
    /// A snapshot strategy for comparing bezier paths based on pixel equality.
    static var elementsDescription: Snapshotting {
        Snapshotting<CGPath, String>.elementsDescription.pullback { path in path.cgPath }
    }

    /// A snapshot strategy for comparing bezier paths based on pixel equality.
    ///
    /// - Parameter numberFormatter: The number formatter used for formatting points.
    static func elementsDescription(numberFormatter: NumberFormatter) -> Snapshotting {
        Snapshotting<CGPath, String>.elementsDescription(
            numberFormatter: numberFormatter
        ).pullback { path in path.cgPath }
    }
}
#endif
