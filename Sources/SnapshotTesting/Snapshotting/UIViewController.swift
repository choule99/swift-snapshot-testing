#if os(iOS) || os(tvOS)
import UIKit

@MainActor public extension Snapshotting where Value: UIViewController, Format == UIImage {
    /// A snapshot strategy for comparing view controller views based on pixel equality.
    static var image: Snapshotting {
        .image()
    }

    /// A snapshot strategy for comparing view controller views based on pixel equality.
    ///
    /// If your tests run in a host application, use
    /// `.image(on: config, drawHierarchyInKeyWindow: true)` to capture the most accurate image.
    /// Rendering without the host window can produce incorrect unselected tab-bar colors, rounded
    /// corners on every list row instead of only the first and last, and artifacts around SwiftUI
    /// rounded rectangles.
    ///
    /// Framework and package test targets do not have a host application and must leave
    /// `drawHierarchyInKeyWindow` set to `false`.
    ///
    /// - Parameters:
    ///   - config: A set of device configuration settings.
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
    ///   - settlingDelay: The time to wait after the view appears and before rendering. Keep this
    ///     value shorter than the snapshot assertion's timeout.
    ///   - isOpaque: Whether to composite transparency onto white and omit the alpha channel.
    static func image(
        on config: ViewImageConfig,
        drawHierarchyInKeyWindow: Bool = false,
        precision: Float = 1,
        perceptualPrecision: Float = 1,
        size: CGSize? = nil,
        traits: UITraitCollection = .init(),
        settlingDelay: TimeInterval = 0,
        isOpaque: Bool = false
    )
        -> Snapshotting {

        SimplySnapshotting.image(
            precision: precision,
            perceptualPrecision: perceptualPrecision,
            scale: traits.displayScale,
            isOpaque: isOpaque
        ).asyncPullback { viewController in
            snapshotView(
                config: size.map { .init(safeArea: config.safeArea, size: $0, traits: config.traits) }
                    ?? config,
                drawHierarchyInKeyWindow: drawHierarchyInKeyWindow,
                traits: traits,
                view: viewController.view,
                viewController: viewController,
                settlingDelay: settlingDelay
            )
        }
    }

    /// A snapshot strategy for comparing view controller views based on pixel equality.
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
    ///   - settlingDelay: The time to wait after the view appears and before rendering. Keep this
    ///     value shorter than the snapshot assertion's timeout.
    ///   - isOpaque: Whether to composite transparency onto white and omit the alpha channel.
    static func image(
        drawHierarchyInKeyWindow: Bool = false,
        precision: Float = 1,
        perceptualPrecision: Float = 1,
        size: CGSize? = nil,
        traits: UITraitCollection = .init(),
        settlingDelay: TimeInterval = 0,
        isOpaque: Bool = false
    )
        -> Snapshotting {

        SimplySnapshotting.image(
            precision: precision,
            perceptualPrecision: perceptualPrecision,
            scale: traits.displayScale,
            isOpaque: isOpaque
        ).asyncPullback { viewController in
            snapshotView(
                config: .init(safeArea: .zero, size: size, traits: traits),
                drawHierarchyInKeyWindow: drawHierarchyInKeyWindow,
                traits: traits,
                view: viewController.view,
                viewController: viewController,
                settlingDelay: settlingDelay
            )
        }
    }
}

@MainActor public extension Snapshotting where Value: UIViewController, Format == String {
    /// A snapshot strategy for comparing view controllers based on their embedded controller
    /// hierarchy.
    ///
    /// ``` swift
    /// assertSnapshot(of: vc, as: .hierarchy)
    /// ```
    ///
    /// Records:
    ///
    /// ```
    /// <UITabBarController>, state: appeared, view: <UILayoutContainerView>
    ///    | <UINavigationController>, state: appeared, view: <UILayoutContainerView>
    ///    |    | <UIPageViewController>, state: appeared, view: <_UIPageViewControllerContentView>
    ///    |    |    | <UIViewController>, state: appeared, view: <UIView>
    ///    | <UINavigationController>, state: disappeared, view: <UILayoutContainerView> not in the window
    ///    |    | <UIViewController>, state: disappeared, view: (view not loaded)
    ///    | <UINavigationController>, state: disappeared, view: <UILayoutContainerView> not in the window
    ///    |    | <UIViewController>, state: disappeared, view: (view not loaded)
    ///    | <UINavigationController>, state: disappeared, view: <UILayoutContainerView> not in the window
    ///    |    | <UIViewController>, state: disappeared, view: (view not loaded)
    ///    | <UINavigationController>, state: disappeared, view: <UILayoutContainerView> not in the window
    ///    |    | <UIViewController>, state: disappeared, view: (view not loaded)
    /// ```
    static var hierarchy: Snapshotting {
        Snapshotting<String, String>.lines.pullback { viewController in
            let dispose = prepareView(
                config: .init(),
                drawHierarchyInKeyWindow: false,
                traits: .init(),
                view: viewController.view,
                viewController: viewController
            )
            defer { dispose() }
            let hierarchy = viewController.perform(Selector(("_printHierarchy"))).retain().takeUnretainedValue()
            guard let hierarchy = hierarchy as? String else {
                preconditionFailure("Expected _printHierarchy to return a string")
            }
            return purgePointers(hierarchy)
        }
    }

    /// A snapshot strategy for comparing view controller views based on a recursive description of
    /// their properties and hierarchies.
    static var recursiveDescription: Snapshotting {
        Snapshotting.recursiveDescription()
    }

    /// A snapshot strategy for comparing view controller views based on a recursive description of
    /// their properties and hierarchies.
    ///
    /// - Parameters:
    ///   - config: A set of device configuration settings.
    ///   - size: A view size override.
    ///   - traits: A trait collection override.
    static func recursiveDescription(
        on config: ViewImageConfig = .init(),
        size: CGSize? = nil,
        traits: UITraitCollection = .init()
    )
        -> Snapshotting {
        SimplySnapshotting.lines.pullback { viewController in
            let dispose = prepareView(
                config: .init(
                    safeArea: config.safeArea, size: size ?? config.size, traits: config.traits
                ),
                drawHierarchyInKeyWindow: false,
                traits: traits,
                view: viewController.view,
                viewController: viewController
            )
            defer { dispose() }
            let description = viewController.view.perform(Selector(("recursiveDescription"))).retain()
                .takeUnretainedValue()
            guard let description = description as? String else {
                preconditionFailure("Expected recursiveDescription to return a string")
            }
            return purgePointers(description)
        }
    }
}
#endif
