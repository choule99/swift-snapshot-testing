#if canImport(SwiftUI)
    import SwiftUI

    /// A SwiftUI view and its preview metadata.
    public struct PreviewSnapshot {
        /// The name displayed for this preview.
        public let name: String

        /// The layout used for this preview.
        public let layout: PreviewSnapshotLayout

        private let specifiedLayout: PreviewSnapshotLayout?
        private var makeView: @MainActor () -> AnyView

        /// Creates a preview snapshot.
        public init(
            _ name: String,
            @ViewBuilder view: @escaping @MainActor () -> some View
        ) {
            self.name = name
            layout = .sizeThatFits
            specifiedLayout = nil
            makeView = { AnyView(view()) }
        }

        /// Creates a preview snapshot with an explicit layout.
        public init(
            _ name: String,
            layout: PreviewSnapshotLayout,
            @ViewBuilder view: @escaping @MainActor () -> some View
        ) {
            self.name = name
            self.layout = layout
            specifiedLayout = layout
            makeView = { AnyView(view()) }
        }

        private init(
            name: String,
            layout: PreviewSnapshotLayout,
            specifiedLayout: PreviewSnapshotLayout?,
            makeView: @escaping @MainActor () -> AnyView
        ) {
            self.name = name
            self.layout = layout
            self.specifiedLayout = specifiedLayout
            self.makeView = makeView
        }

        /// Creates the type-erased view for this preview.
        @MainActor public func view() -> AnyView {
            makeView()
        }

        /// Returns a copy whose view is transformed lazily.
        @MainActor public func mapView(
            @ViewBuilder _ transform: @escaping @MainActor (AnyView) -> some View
        ) -> Self {
            var copy = self
            let makeView = makeView
            copy.makeView = {
                AnyView(transform(makeView()))
            }
            return copy
        }

        func resolvingLayout(defaultLayout: PreviewSnapshotLayout) -> Self {
            guard specifiedLayout == nil else {
                return self
            }
            return Self(
                name: name,
                layout: defaultLayout,
                specifiedLayout: defaultLayout,
                makeView: makeView
            )
        }
    }

    /// The layout used to render a preview snapshot.
    public enum PreviewSnapshotLayout {
        /// Fits the preview to its content.
        case sizeThatFits

        /// Renders the preview at a fixed size.
        case fixed(width: CGFloat, height: CGFloat)

        /// Renders the preview in a device frame.
        case device

        @MainActor var previewLayout: PreviewLayout {
            switch self {
                case .sizeThatFits:
                    .sizeThatFits
                case let .fixed(width, height):
                    .fixed(width: width, height: height)
                case .device:
                    .device
            }
        }
    }

    /// A result builder for an ordered collection of preview snapshots.
    @MainActor
    @resultBuilder public enum SnapshotBuilder {
        public static func buildExpression(_ snapshot: PreviewSnapshot) -> [PreviewSnapshot] {
            [snapshot]
        }

        public static func buildExpression(_ snapshots: [PreviewSnapshot]) -> [PreviewSnapshot] {
            snapshots
        }

        public static func buildBlock(_ components: [PreviewSnapshot]...) -> [PreviewSnapshot] {
            components.flatMap(\.self)
        }

        public static func buildOptional(_ component: [PreviewSnapshot]?) -> [PreviewSnapshot] {
            component ?? []
        }

        public static func buildEither(first component: [PreviewSnapshot]) -> [PreviewSnapshot] {
            component
        }

        public static func buildEither(second component: [PreviewSnapshot]) -> [PreviewSnapshot] {
            component
        }

        public static func buildArray(_ components: [[PreviewSnapshot]]) -> [PreviewSnapshot] {
            components.flatMap(\.self)
        }
    }

    /// A collection of snapshots that can also be displayed as SwiftUI previews.
    @MainActor public protocol SnapshotProvider {
        /// The layout used by snapshots that do not declare one.
        static var defaultLayout: PreviewSnapshotLayout { get }

        /// The snapshots provided by this type.
        @SnapshotBuilder static var snapshots: [PreviewSnapshot] { get }
    }

    public extension SnapshotProvider {
        /// The default layout for snapshots that do not declare one.
        static var defaultLayout: PreviewSnapshotLayout {
            .sizeThatFits
        }

        /// The snapshots with the provider's default layout applied.
        static var resolvedSnapshots: [PreviewSnapshot] {
            snapshots.map { $0.resolvingLayout(defaultLayout: defaultLayout) }
        }
    }

    public extension SnapshotProvider where Self: PreviewProvider {
        /// The SwiftUI previews corresponding to ``snapshots``.
        static var previews: some View {
            ForEach(Array(resolvedSnapshots.enumerated()), id: \.offset) { _, snapshot in
                snapshot.view()
                    .previewDisplayName(snapshot.name)
                    .previewLayout(snapshot.layout.previewLayout)
            }
        }
    }

    @MainActor public extension Collection<PreviewSnapshot> {
        /// Returns snapshots whose views are transformed lazily.
        func transformingViews(
            @ViewBuilder _ transform: @escaping @MainActor (AnyView) -> some View
        ) -> [PreviewSnapshot] {
            map { $0.mapView(transform) }
        }
    }
#endif
