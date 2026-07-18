#if canImport(SwiftUI)
import Foundation
import SwiftUI

#if os(watchOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// The size constraint for a snapshot (similar to `PreviewLayout`).
public enum SwiftUISnapshotLayout {
    #if os(iOS) || os(tvOS)
    /// Center the view in a device container described by`config`.
    case device(config: ViewImageConfig)
    #endif
    /// Center the view in a fixed size container.
    case fixed(width: CGFloat, height: CGFloat)
    /// Fit the view to the ideal size that fits its content.
    case sizeThatFits
}

#if os(iOS) || os(tvOS)
@available(iOS 13.0, tvOS 13.0, *) @MainActor public extension Snapshotting where Value: SwiftUI.View, Format == UIImage {

    /// A snapshot strategy for comparing SwiftUI Views based on pixel equality.
    static var image: Snapshotting {
        .image()
    }

    /// A snapshot strategy for comparing SwiftUI Views based on pixel equality.
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
    ///   - layout: A view layout override.
    ///   - traits: A trait collection override.
    ///   - settlingDelay: The time to wait after the hosting view appears and before rendering. Keep
    ///     this value shorter than the snapshot assertion's timeout.
    ///   - isOpaque: Whether to composite transparency onto white and omit the alpha channel.
    static func image(
        drawHierarchyInKeyWindow: Bool = false,
        precision: Float = 1,
        perceptualPrecision: Float = 1,
        layout: SwiftUISnapshotLayout = .sizeThatFits,
        traits: UITraitCollection = .init(),
        settlingDelay: TimeInterval = 0,
        isOpaque: Bool = false
    )
        -> Snapshotting {
        let config: ViewImageConfig

        switch layout {
            #if os(iOS) || os(tvOS)
            case let .device(config: deviceConfig):
                config = deviceConfig
            #endif
        case .sizeThatFits:
                config = .init(safeArea: .zero, size: nil, traits: traits)
        case let .fixed(width: width, height: height):
                let size = CGSize(width: width, height: height)
                config = .init(safeArea: .zero, size: size, traits: traits)
        }

        return SimplySnapshotting.image(
            precision: precision,
            perceptualPrecision: perceptualPrecision,
            scale: traits.displayScale,
            isOpaque: isOpaque
        ).asyncPullback { view in
            var config = config

            let controller: UIViewController

            if config.size != nil {
                controller = UIHostingController(
                    rootView: view
                )
            } else {
                let hostingController = UIHostingController(rootView: view.fixedSize())

                if config.safeArea == .zero {
                    if #available(iOS 16.4, tvOS 16.4, *) {
                        hostingController.safeAreaRegions = []
                    } else {
                        hostingController._disableSafeArea = true
                    }
                }

                let maxSize = CGSize(width: 0.0, height: 0.0)
                config.size = hostingController.sizeThatFits(in: maxSize)

                controller = hostingController
            }

            return snapshotView(
                config: config,
                drawHierarchyInKeyWindow: drawHierarchyInKeyWindow,
                traits: traits,
                view: controller.view,
                viewController: controller,
                settlingDelay: settlingDelay
            )
        }
    }
}
#endif

#if os(macOS)
@available(macOS 13.0, *) @MainActor public extension Snapshotting where Value: SwiftUI.View, Format == NSImage {
    /// A snapshot strategy for comparing SwiftUI views rendered with `ImageRenderer`.
    ///
    /// Views render at a deterministic 2x scale. Compare snapshots on the same OS version to avoid
    /// differences in system rendering.
    static var image: Snapshotting {
        .image()
    }

    /// A snapshot strategy for comparing SwiftUI views rendered with `ImageRenderer`.
    ///
    /// Views render at a deterministic 2x scale. Compare snapshots on the same OS version to avoid
    /// differences in system rendering.
    ///
    /// - Parameters:
    ///   - precision: The percentage of pixels that must match.
    ///   - perceptualPrecision: The percentage a pixel must match the source pixel to be considered a
    ///     match.
    ///   - layout: A view layout override. `sizeThatFits` uses the view's ideal size, while `fixed`
    ///     centers the view in the requested point size.
    ///   - isOpaque: Whether to composite transparency onto white and omit the alpha channel.
    static func image(
        precision: Float = 1,
        perceptualPrecision: Float = 1,
        layout: SwiftUISnapshotLayout = .sizeThatFits,
        isOpaque: Bool = false
    ) -> Snapshotting {
        SimplySnapshotting.image(
            precision: precision,
            perceptualPrecision: perceptualPrecision,
            isOpaque: isOpaque
        ).pullback { view in
            let renderer = ImageRenderer(
                content: MacSnapshottingView(layout: layout, content: view)
            )
            renderer.scale = 2
            guard let image = renderer.nsImage else {
                preconditionFailure("Could not render SwiftUI view as an image.")
            }
            return image
        }
    }
}

@available(macOS 13.0, *) private struct MacSnapshottingView<Content: SwiftUI.View>: SwiftUI.View {
    let layout: SwiftUISnapshotLayout
    let content: Content

    var body: some SwiftUI.View {
        switch layout {
            case let .fixed(width, height):
                content.frame(width: width, height: height)
            case .sizeThatFits:
                content
        }
    }
}
#endif

#if os(watchOS)
@available(watchOS 10.0, *) @MainActor public extension Snapshotting where Value: SwiftUI.View, Format == UIImage {
    /// A snapshot strategy for comparing SwiftUI views rendered with `ImageRenderer`.
    ///
    /// `ImageRenderer` renders SwiftUI-native content. Views backed by native platform frameworks
    /// may render placeholders. Perceptual precision is unavailable on watchOS.
    static var image: Snapshotting {
        .image()
    }

    /// A snapshot strategy for comparing SwiftUI views rendered with `ImageRenderer`.
    ///
    /// `ImageRenderer` renders SwiftUI-native content. Views backed by native platform frameworks
    /// may render placeholders. Perceptual precision is unavailable on watchOS.
    ///
    /// - Parameters:
    ///   - precision: The percentage of image bytes that must match.
    ///   - layout: A view layout override.
    ///   - isOpaque: Whether to composite transparency onto white and omit the alpha channel.
    static func image(
        precision: Float = 1,
        layout: SwiftUISnapshotLayout = .sizeThatFits,
        isOpaque: Bool = false
    ) -> Snapshotting {
        SimplySnapshotting.image(precision: precision, scale: 1, isOpaque: isOpaque).pullback { view in
            let renderer = ImageRenderer(content: WatchSnapshottingView(layout: layout, content: view))
            renderer.scale = 1
            guard let image = renderer.uiImage else {
                preconditionFailure("Could not render SwiftUI view as an image.")
            }
            return image
        }
    }
}

@available(watchOS 10.0, *) private struct WatchSnapshottingView<Content: SwiftUI.View>: SwiftUI.View {
    let layout: SwiftUISnapshotLayout
    let content: Content

    var body: some SwiftUI.View {
        switch layout {
            case let .fixed(width, height):
                content.frame(width: width, height: height)
            case .sizeThatFits:
                content
        }
    }
}
#endif
#endif
