#if os(iOS) || os(macOS) || os(tvOS)
import SpriteKit
#if os(macOS)
import Cocoa
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

#if os(macOS)
@MainActor public extension Snapshotting where Value == SKScene, Format == NSImage {
    /// A snapshot strategy for comparing SpriteKit scenes based on pixel equality.
    ///
    /// - Parameters:
    ///   - options: The image comparison options.
    ///   - size: The size of the scene.
    static func image(options: ImageSnapshotOptions = .init(), size: CGSize)
        -> Snapshotting {
        .skScene(options: options, size: size)
    }

    @available(*, deprecated, message: "Use image(options:size:) instead") static func image(precision: Float = 1, perceptualPrecision: Float = 1, size: CGSize)
        -> Snapshotting {
        .image(
            options: .init(precision: precision, perceptualPrecision: perceptualPrecision),
            size: size
        )
    }
}

#elseif os(iOS) || os(tvOS)
@MainActor public extension Snapshotting where Value == SKScene, Format == UIImage {
    /// A snapshot strategy for comparing SpriteKit scenes based on pixel equality.
    ///
    /// - Parameters:
    ///   - options: The image comparison options.
    ///   - size: The size of the scene.
    static func image(options: ImageSnapshotOptions = .init(), size: CGSize)
        -> Snapshotting {
        .skScene(options: options, size: size)
    }

    @available(*, deprecated, message: "Use image(options:size:) instead") static func image(precision: Float = 1, perceptualPrecision: Float = 1, size: CGSize)
        -> Snapshotting {
        .image(
            options: .init(precision: precision, perceptualPrecision: perceptualPrecision),
            size: size
        )
    }
}
#endif

@MainActor fileprivate extension Snapshotting where Value == SKScene, Format == Image {
    static func skScene(options: ImageSnapshotOptions, size: CGSize)
        -> Snapshotting {
        Snapshotting<View, Image>.image(
            options: options
        ).pullback { scene in
            let view = SKView(frame: .init(x: 0, y: 0, width: size.width, height: size.height))
            view.presentScene(scene)
            return view
        }
    }
}
#endif
