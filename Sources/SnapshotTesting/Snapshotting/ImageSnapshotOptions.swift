/// Options controlling image snapshot comparison.
public struct ImageSnapshotOptions: Sendable {
    /// The percentage of pixels that must match.
    public var precision: Float

    #if !os(watchOS)
    /// The percentage a pixel must match the source pixel to be considered a match.
    public var perceptualPrecision: Float
    #endif

    #if os(watchOS)
    public init(precision: Float = 1) {
        self.precision = precision
    }
    #else
    public init(precision: Float = 1, perceptualPrecision: Float = 1) {
        self.precision = precision
        self.perceptualPrecision = perceptualPrecision
    }
    #endif

    /// Returns a copy requiring the given pixel precision.
    public func requiringPixelPrecision(_ precision: Float) -> Self {
        var copy = self
        copy.precision = precision
        return copy
    }

    #if !os(watchOS)
    /// Returns a copy requiring the given perceptual precision.
    public func requiringPerceptualPrecision(_ perceptualPrecision: Float) -> Self {
        var copy = self
        copy.perceptualPrecision = perceptualPrecision
        return copy
    }
    #endif
}
