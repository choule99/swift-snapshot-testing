/// Options controlling image snapshot comparison.
public struct ImageSnapshotOptions: Sendable {
    /// The fraction of matching components required, from `0` to `1`.
    ///
    /// Exact color comparison counts matching 8-bit RGBA components, including alpha.
    /// When perceptual comparison is enabled, this instead counts pixels whose color difference
    /// is within the perceptual threshold.
    public var precision: Float

    #if !os(watchOS)
    /// The perceptual color precision required for each pixel, from `0` to `1`.
    /// Values below `1` enable perceptual comparison; `1` uses exact component comparison.
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

    /// Returns a copy requiring the given matching fraction. See ``precision`` for how matches are counted.
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
