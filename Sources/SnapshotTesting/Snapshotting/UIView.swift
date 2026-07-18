#if os(iOS) || os(tvOS)
import UIKit

@MainActor public extension Snapshotting where Value: UIView, Format == UIImage {
    /// A snapshot strategy for comparing views based on pixel equality.
    static var image: Snapshotting {
        .image()
    }

    /// A snapshot strategy for comparing views based on pixel equality.
    ///
    /// If your tests run in a host application, use `.image(drawHierarchyInKeyWindow: true)` to
    /// capture the most accurate image. Rendering without the host window can produce incorrect
    /// unselected tab-bar colors, rounded corners on every list row instead of only the first and
    /// last, and artifacts around SwiftUI rounded rectangles.
    ///
    /// Framework and package test targets do not have a host application and must leave
    /// `drawHierarchyInKeyWindow` set to `false`.
    ///
    /// - Parameters:
    ///   - drawHierarchyInKeyWindow: Utilize the simulator's key window in order to render
    ///     `UIAppearance` and `UIVisualEffect`s. This option requires a host application for your
    ///     tests and will not work for framework or package test targets.
    ///   - precision: The percentage of pixels that must match.
    ///   - perceptualPrecision: The percentage a pixel must match the source pixel to be considered a
    ///     match. 98-99% mimics
    ///     [the precision](http://zschuessler.github.io/DeltaE/learn/#toc-defining-delta-e) of the
    ///     human eye.
    ///   - size: A view size override.
    ///   - traits: A trait collection override.
    ///   - isOpaque: Whether to composite transparency onto white and omit the alpha channel.
    static func image(
        drawHierarchyInKeyWindow: Bool = false,
        precision: Float = 1,
        perceptualPrecision: Float = 1,
        size: CGSize? = nil,
        traits: UITraitCollection = .init(),
        isOpaque: Bool = false
    )
        -> Snapshotting {

        SimplySnapshotting.image(
            precision: precision,
            perceptualPrecision: perceptualPrecision,
            scale: traits.displayScale,
            isOpaque: isOpaque
        ).asyncPullback { view in
            snapshotView(
                config: .init(safeArea: .zero, size: size ?? view.frame.size, traits: .init()),
                drawHierarchyInKeyWindow: drawHierarchyInKeyWindow,
                traits: traits,
                view: view,
                viewController: .init()
            )
        }
    }
}

@MainActor public extension Snapshotting where Value: UIView, Format == String {
    /// A snapshot strategy for comparing views based on a recursive description of their properties
    /// and hierarchies.
    ///
    /// ``` swift
    /// s// Layout on the current device.
    /// assertSnapshot(of: view, as: .recursiveDescription)
    ///
    /// // Layout with a certain size.
    /// assertSnapshot(of: view, as: .recursiveDescription(size: .init(width: 22, height: 22)))
    ///
    /// // Layout with a certain trait collection.
    /// assertSnapshot(of: view, as: .recursiveDescription(traits: .init(horizontalSizeClass: .regular)))
    /// ```
    ///
    /// Records:
    ///
    /// ```
    /// <UIButton; frame = (0 0; 22 22); opaque = NO; layer = <CALayer>>
    ///    | <UIImageView; frame = (0 0; 22 22); clipsToBounds = YES; opaque = NO; userInteractionEnabled = NO; layer = <CALayer>>
    /// ```
    static var recursiveDescription: Snapshotting {
        Snapshotting.recursiveDescription()
    }

    /// A snapshot strategy for comparing views based on a recursive description of their properties
    /// and hierarchies.
    static func recursiveDescription(
        size: CGSize? = nil,
        traits: UITraitCollection = .init()
    )
        -> Snapshotting {
        SimplySnapshotting.lines.pullback { view in
            let dispose = prepareView(
                config: .init(safeArea: .zero, size: size ?? view.frame.size, traits: traits),
                drawHierarchyInKeyWindow: false,
                traits: .init(),
                view: view,
                viewController: .init()
            )
            defer { dispose() }
            let description = view.perform(Selector(("recursiveDescription"))).retain().takeUnretainedValue()
            guard let description = description as? String else {
                preconditionFailure("Expected recursiveDescription to return a string")
            }
            return purgePointers(description)
        }
    }
}
#endif
