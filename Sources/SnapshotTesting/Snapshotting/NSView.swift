#if os(macOS)
import AppKit
import Cocoa

public extension Snapshotting where Value == NSView, Format == NSImage {
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
    ///   - precision: The percentage of pixels that must match.
    ///   - perceptualPrecision: The percentage a pixel must match the source pixel to be considered a
    ///     match. 98-99% mimics
    ///     [the precision](http://zschuessler.github.io/DeltaE/learn/#toc-defining-delta-e) of the
    ///     human eye.
    ///   - size: A view size override.
    static func image(
        precision: Float = 1, perceptualPrecision: Float = 1, size: CGSize? = nil
    ) -> Snapshotting {
        SimplySnapshotting.image(
            precision: precision, perceptualPrecision: perceptualPrecision
        ).asyncPullback { view in
            let initialSize = view.frame.size
            if let size {
                view.frame.size = size
            }
            guard view.frame.width > 0, view.frame.height > 0 else {
                fatalError("View not renderable to image at size \(view.frame.size)")
            }
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
}

public extension Snapshotting where Value == NSView, Format == String {
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
    static var recursiveDescription: Snapshotting<NSView, String> {
        SimplySnapshotting.lines.pullback { view in
            let description = view.perform(Selector(("_subtreeDescription"))).retain().takeUnretainedValue()
            guard let description = description as? String else {
                preconditionFailure("Expected _subtreeDescription to return a string")
            }
            return purgePointers(description)
        }
    }
}

func snapshotImage(_ view: NSView) -> NSImage {
    onMain {
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
}

func snapshotImage(size: CGSize, drawing: @escaping () -> Void) -> NSImage {
    onMain {
        snapshotImage(SnapshotDrawingView(size: size, drawing: drawing))
    }
}

private final class SnapshotDrawingView: NSView {
    let drawing: () -> Void

    init(size: CGSize, drawing: @escaping () -> Void) {
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
