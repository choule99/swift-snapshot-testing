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
        ///   - options: The image comparison options.
        ///   - size: A view size override.
        ///   - isOpaque: Whether to composite transparency onto white and omit the alpha channel.
        ///   - prepare: A closure to run after layout and before rendering.
        static func image(
            options: ImageSnapshotOptions = .init(),
            size: CGSize? = nil,
            isOpaque: Bool = false,
            prepare: (@MainActor @Sendable () -> Void)? = nil
        ) -> Snapshotting {
            Snapshotting<NSView, NSImage>.image(
                options: options,
                size: size,
                isOpaque: isOpaque,
                prepare: prepare
            ).pullback { $0.view }
        }

        @available(*, deprecated, message: "Use image(options:size:isOpaque:prepare:) instead") static func image(
            precision: Float = 1,
            perceptualPrecision: Float = 1,
            size: CGSize? = nil,
            isOpaque: Bool = false,
            prepare: (@MainActor @Sendable () -> Void)? = nil
        ) -> Snapshotting {
            .image(
                options: .init(precision: precision, perceptualPrecision: perceptualPrecision),
                size: size,
                isOpaque: isOpaque,
                prepare: prepare
            )
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
