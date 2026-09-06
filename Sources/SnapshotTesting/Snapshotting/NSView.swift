#if os(macOS)
    import AppKit
    import Cocoa

    @MainActor public extension Snapshotting where Value: NSView, Format == NSImage {
        /// A snapshot strategy for comparing views based on pixel equality.
        static var image: Snapshotting {
            .image()
        }

        /// A snapshot strategy for comparing views based on pixel equality.
        ///
        /// > Note: Snapshots must be compared on the same OS as the device that originally took the
        /// > reference to avoid discrepancies between images.
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
            SimplySnapshotting.image(
                options: options,
                isOpaque: isOpaque
            ).asyncPullback { view in
                let initialSize = view.frame.size
                if let size {
                    view.frame.size = size
                }
                guard view.frame.width > 0, view.frame.height > 0 else {
                    fatalError("View not renderable to image at size \(view.frame.size)")
                }
                view.layoutSubtreeIfNeeded()
                prepare?()
                return view.snapshot
                    ?? Async { callback in
                        addImagesForRenderedViews(view).sequence().run { views in
                            callback(snapshotImage(view))
                            views.forEach { $0.removeFromSuperview() }
                            view.frame.size = initialSize
                        }
                    }
            }
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

    @MainActor public extension Snapshotting where Value: NSView, Format == String {
        /// A snapshot strategy for comparing views based on a recursive description of their properties
        /// and hierarchies.
        ///
        /// ``` swift
        /// assertSnapshot(of: view, as: .recursiveDescription)
        /// ```
        ///
        /// Records:
        ///
        /// ```
        /// [   AF      LU ] h=--- v=--- NSButton "Push Me" f=(0,0,77,32) b=(-)
        ///   [   A       LU ] h=--- v=--- NSButtonBezelView f=(0,0,77,32) b=(-)
        ///   [   AF      LU ] h=--- v=--- NSButtonTextField "Push Me" f=(10,6,57,16) b=(-)
        /// ```
        static var recursiveDescription: Snapshotting {
            SimplySnapshotting.lines.pullback { view in
                let description = view.perform(Selector(("_subtreeDescription"))).retain().takeUnretainedValue()
                guard let description = description as? String else {
                    preconditionFailure("Expected _subtreeDescription to return a string")
                }
                return purgePointers(description)
            }
        }
    }

    @MainActor func snapshotImage(_ view: NSView) -> NSImage {
        let proxy = NSView(frame: view.bounds)
        let bitmapRep = withScaledWindow(proxy) {
            guard let representation = proxy.bitmapImageRepForCachingDisplay(in: proxy.bounds) else {
                preconditionFailure("Could not create bitmap representation")
            }
            return representation
        }
        view.cacheDisplay(in: view.bounds, to: bitmapRep)
        let image = NSImage(size: view.bounds.size)
        image.addRepresentation(bitmapRep)
        return image
    }

    @MainActor func snapshotImage(
        size: CGSize,
        drawing: @escaping @MainActor () -> Void
    ) -> NSImage {
        snapshotImage(SnapshotDrawingView(size: size, drawing: drawing))
    }

    @MainActor private final class SnapshotDrawingView: NSView {
        let drawing: @MainActor () -> Void

        init(size: CGSize, drawing: @escaping @MainActor () -> Void) {
            self.drawing = drawing
            super.init(frame: CGRect(origin: .zero, size: size))
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func draw(_ dirtyRect: NSRect) {
            drawing()
        }
    }
#endif
