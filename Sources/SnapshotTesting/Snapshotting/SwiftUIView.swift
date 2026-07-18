#if canImport(SwiftUI)
import Foundation
import SwiftUI

#if os(watchOS)
import UIKit
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
    /// - Parameters:
    ///   - drawHierarchyInKeyWindow: Utilize the simulator's key window in order to render
    ///     `UIAppearance` and `UIVisualEffect`s. This option requires a host application for your
    ///     tests and will _not_ work for framework test targets.
    ///   - precision: The percentage of pixels that must match.
    ///   - perceptualPrecision: The percentage a pixel must match the source pixel to be considered a
    ///     match. 98-99% mimics
    ///     [the precision](http://zschuessler.github.io/DeltaE/learn/#toc-defining-delta-e) of the
    ///     human eye.
    ///   - layout: A view layout override.
    ///   - traits: A trait collection override.
    static func image(
        drawHierarchyInKeyWindow: Bool = false,
        precision: Float = 1,
        perceptualPrecision: Float = 1,
        layout: SwiftUISnapshotLayout = .sizeThatFits,
        traits: UITraitCollection = .init()
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
            precision: precision, perceptualPrecision: perceptualPrecision, scale: traits.displayScale
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
                viewController: controller
            )
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
    static func image(
        precision: Float = 1,
        layout: SwiftUISnapshotLayout = .sizeThatFits
    ) -> Snapshotting {
        SimplySnapshotting.image(precision: precision, scale: 1).pullback { view in
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
