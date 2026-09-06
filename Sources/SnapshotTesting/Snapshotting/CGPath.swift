#if os(macOS)
    import AppKit
    import Cocoa
    import CoreGraphics

    @MainActor public extension Snapshotting where Value == CGPath, Format == NSImage {
        /// A snapshot strategy for comparing bezier paths based on pixel equality.
        static var image: Snapshotting {
            .image()
        }

        /// A snapshot strategy for comparing bezier paths based on pixel equality.
        ///
        /// ``` swift
        /// // Match reference perfectly.
        /// assertSnapshot(of: path, as: .image)
        ///
        /// // Allow for a 1% pixel difference.
        /// assertSnapshot(of: path, as: .image(options: .init(precision: 0.99)))
        /// ```
        ///
        /// - Parameters:
        ///   - options: The image comparison options.
        ///   - drawingMode: The drawing mode.
        static func image(
            options: ImageSnapshotOptions = .init(),
            drawingMode: CGPathDrawingMode = .eoFill
        ) -> Snapshotting {
            SimplySnapshotting.image(
                options: options
            ).pullback { path in
                let bounds = path.boundingBoxOfPath
                var transform = CGAffineTransform(translationX: -bounds.origin.x, y: -bounds.origin.y)
                guard let path = path.copy(using: &transform) else {
                    preconditionFailure("Could not copy path")
                }

                return snapshotImage(size: bounds.size) {
                    guard let context = NSGraphicsContext.current?.cgContext else {
                        preconditionFailure("Expected a graphics context while drawing a path")
                    }
                    context.addPath(path)
                    context.drawPath(using: drawingMode)
                }
            }
        }

        @available(*, deprecated, message: "Use image(options:drawingMode:) instead") static func image(
            precision: Float = 1,
            perceptualPrecision: Float = 1,
            drawingMode: CGPathDrawingMode = .eoFill
        ) -> Snapshotting {
            .image(
                options: .init(precision: precision, perceptualPrecision: perceptualPrecision),
                drawingMode: drawingMode
            )
        }
    }

#elseif os(iOS) || os(tvOS)
    import UIKit

    @MainActor public extension Snapshotting where Value == CGPath, Format == UIImage {
        /// A snapshot strategy for comparing bezier paths based on pixel equality.
        static var image: Snapshotting {
            .image()
        }

        /// A snapshot strategy for comparing bezier paths based on pixel equality.
        ///
        /// - Parameters:
        ///   - options: The image comparison options.
        static func image(
            options: ImageSnapshotOptions = .init(), scale: CGFloat = 1,
            drawingMode: CGPathDrawingMode = .eoFill
        ) -> Snapshotting {
            SimplySnapshotting.image(
                options: options, scale: scale
            ).pullback { path in
                let bounds = path.boundingBoxOfPath
                let format = UIGraphicsImageRendererFormat.preferred()
                format.scale = scale
                return UIGraphicsImageRenderer(bounds: bounds, format: format).image { ctx in
                    let cgContext = ctx.cgContext
                    cgContext.addPath(path)
                    cgContext.drawPath(using: drawingMode)
                }
            }
        }

        @available(*, deprecated, message: "Use image(options:scale:drawingMode:) instead") static func image(
            precision: Float = 1, perceptualPrecision: Float = 1, scale: CGFloat = 1,
            drawingMode: CGPathDrawingMode = .eoFill
        ) -> Snapshotting {
            .image(
                options: .init(precision: precision, perceptualPrecision: perceptualPrecision),
                scale: scale,
                drawingMode: drawingMode
            )
        }
    }
#endif

#if os(macOS) || os(iOS) || os(tvOS)
    @available(iOS 11.0, OSX 10.13, tvOS 11.0, *) @MainActor public extension Snapshotting where Value == CGPath, Format == String {
        /// A snapshot strategy for comparing bezier paths based on element descriptions.
        static var elementsDescription: Snapshotting {
            .elementsDescription(numberFormatter: defaultNumberFormatter)
        }

        /// A snapshot strategy for comparing bezier paths based on element descriptions.
        ///
        /// - Parameter numberFormatter: The number formatter used for formatting points.
        static func elementsDescription(numberFormatter: NumberFormatter) -> Snapshotting {
            let namesByType: [CGPathElementType: String] = [
                .moveToPoint: "MoveTo",
                .addLineToPoint: "LineTo",
                .addQuadCurveToPoint: "QuadCurveTo",
                .addCurveToPoint: "CurveTo",
                .closeSubpath: "Close"
            ]

            let numberOfPointsByType: [CGPathElementType: Int] = [
                .moveToPoint: 1,
                .addLineToPoint: 1,
                .addQuadCurveToPoint: 2,
                .addCurveToPoint: 3,
                .closeSubpath: 0
            ]

            return SimplySnapshotting.lines.pullback { path in
                var string = ""

                path.applyWithBlock { elementPointer in
                    let element = elementPointer.pointee
                    let name = namesByType[element.type] ?? "Unknown"

                    if element.type == .moveToPoint, !string.isEmpty {
                        string += "\n"
                    }

                    string += name

                    if let numberOfPoints = numberOfPointsByType[element.type] {
                        let points = UnsafeBufferPointer(start: element.points, count: numberOfPoints)
                        string +=
                            " "
                            + points.map { point in
                                guard let x = numberFormatter.string(from: point.x as NSNumber),
                                      let y = numberFormatter.string(from: point.y as NSNumber) else {
                                    preconditionFailure("Could not format path point")
                                }
                                return "(\(x), \(y))"
                            }.joined(separator: " ")
                    }

                    string += "\n"
                }

                return string
            }
        }
    }

    private let defaultNumberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.decimalSeparator = "."
        numberFormatter.minimumFractionDigits = 1
        numberFormatter.maximumFractionDigits = 3
        return numberFormatter
    }()
#endif
