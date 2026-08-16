#if canImport(SwiftUI)
import SnapshotPreviews
@testable import SnapshotTesting
import SwiftUI
import XCTest

@MainActor final class SnapshotPreviewsTests: XCTestCase {
    func testSnapshotBuilderPreservesOrderingAndMetadata() {
        let snapshots = BuilderProvider.snapshots

        XCTAssertEqual(
            snapshots.map(\.name),
            ["first", "array-first", "array-second", "conditional", "loop-1", "loop-2", "last"]
        )
        XCTAssertTrue(matchesSizeThatFits(snapshots[0].layout))
        XCTAssertTrue(matchesFixed(snapshots[1].layout, width: 320, height: 240))
        XCTAssertTrue(matchesDevice(snapshots[2].layout))
    }

    func testPreviewSnapshotCreatesTypeErasedView() {
        let snapshot = PreviewSnapshot("text") { Text("Hello") }

        XCTAssertTrue(type(of: snapshot.view()) == AnyView.self)
    }

    func testPreviewSnapshotUsesSizeThatFitsAsItsRawLayoutFallback() {
        let snapshot = PreviewSnapshot("default") { Text("Default") }

        XCTAssertTrue(matchesSizeThatFits(snapshot.layout))
    }

    func testSnapshotProviderResolvesDefaultLayoutsAndKeepsExplicitLayouts() {
        let snapshots = DefaultLayoutProvider.resolvedSnapshots

        XCTAssertTrue(matchesFixed(snapshots[0].layout, width: 320, height: 240))
        XCTAssertTrue(matchesSizeThatFits(snapshots[1].layout))
    }

    func testSnapshotProviderLayoutResolutionIsIdempotent() {
        let firstResolution = DefaultLayoutProvider.resolvedSnapshots
        let secondResolution = DefaultLayoutProvider.resolvedSnapshots

        XCTAssertEqual(firstResolution.map(\.name), secondResolution.map(\.name))
        XCTAssertTrue(matchesFixed(firstResolution[0].layout, width: 320, height: 240))
        XCTAssertTrue(matchesFixed(secondResolution[0].layout, width: 320, height: 240))
        XCTAssertTrue(matchesSizeThatFits(firstResolution[1].layout))
        XCTAssertTrue(matchesSizeThatFits(secondResolution[1].layout))
    }

    func testMapViewPreservesMetadataAndIsLazy() {
        let originalViews = Counter()
        let transforms = Counter()
        let snapshot = PreviewSnapshot("fixed", layout: .fixed(width: 320, height: 240)) {
            CountingView(counter: originalViews)
        }
        .mapView { view in
            countingTransform(view, counter: transforms)
        }

        XCTAssertEqual(snapshot.name, "fixed")
        XCTAssertTrue(matchesFixed(snapshot.layout, width: 320, height: 240))
        XCTAssertEqual(originalViews.value, 0)
        XCTAssertEqual(transforms.value, 0)

        _ = snapshot.view()
        XCTAssertEqual(originalViews.value, 1)
        XCTAssertEqual(transforms.value, 1)

        _ = snapshot.view()
        XCTAssertEqual(originalViews.value, 2)
        XCTAssertEqual(transforms.value, 2)
    }

    func testTransformingViewsComposesInOrder() {
        let transforms = Events()
        let snapshots = [
            PreviewSnapshot("implicit") { Text("Implicit") },
            PreviewSnapshot("explicit", layout: .sizeThatFits) { Text("Explicit") }
        ]
        .transformingViews { view in
            recordingTransform(view, events: transforms, label: "first")
        }
        .transformingViews { view in
            recordingTransform(view, events: transforms, label: "second")
        }

        XCTAssertEqual(snapshots.map(\.name), ["implicit", "explicit"])
        XCTAssertTrue(matchesSizeThatFits(snapshots[0].layout))
        XCTAssertTrue(matchesSizeThatFits(snapshots[1].layout))
        XCTAssertTrue(transforms.values.isEmpty)

        _ = snapshots[0].view()
        XCTAssertEqual(transforms.values, ["first", "second"])
    }

    func testTransformingViewsPreservesImplicitAndExplicitLayoutIntent() {
        let snapshots = TransformedDefaultLayoutProvider.resolvedSnapshots

        XCTAssertTrue(matchesFixed(snapshots[0].layout, width: 320, height: 240))
        XCTAssertTrue(matchesSizeThatFits(snapshots[1].layout))
    }

    func testSnapshotProviderPreviewWitnessIsAvailable() {
        let previews = PreviewAndSnapshotProvider.previews

        XCTAssertFalse(String(reflecting: type(of: previews)).isEmpty)
    }

    #if os(macOS) || os(watchOS)
    func testSnapshotTestingLayoutTranslation() {
        XCTAssertTrue(matchesSizeThatFits(PreviewSnapshotLayout.sizeThatFits.snapshotTestingLayout))
        XCTAssertTrue(
            matchesFixed(
                PreviewSnapshotLayout.fixed(width: 320, height: 240).snapshotTestingLayout,
                width: 320,
                height: 240
            )
        )
        XCTAssertNil(PreviewSnapshotLayout.device.snapshotTestingLayout)
    }
    #elseif os(iOS) || os(tvOS)
    func testSnapshotTestingLayoutTranslation() {
        let deviceConfig = ViewImageConfig(size: .init(width: 390, height: 844))

        XCTAssertTrue(
            matchesSizeThatFits(PreviewSnapshotLayout.sizeThatFits.snapshotTestingLayout(on: nil))
        )
        XCTAssertTrue(
            matchesFixed(
                PreviewSnapshotLayout.fixed(width: 320, height: 240).snapshotTestingLayout(on: nil),
                width: 320,
                height: 240
            )
        )
        XCTAssertNil(PreviewSnapshotLayout.device.snapshotTestingLayout(on: nil))
        guard case let .device(config)? = PreviewSnapshotLayout.device.snapshotTestingLayout(on: deviceConfig) else {
            return XCTFail("Expected device layout")
        }
        XCTAssertEqual(config.size, deviceConfig.size)
    }
    #endif

    private func matchesSizeThatFits(_ layout: PreviewSnapshotLayout) -> Bool {
        if case .sizeThatFits = layout {
            return true
        }
        return false
    }

    private func matchesFixed(_ layout: PreviewSnapshotLayout, width: CGFloat, height: CGFloat) -> Bool {
        guard case let .fixed(actualWidth, actualHeight) = layout else {
            return false
        }
        return actualWidth == width && actualHeight == height
    }

    private func matchesDevice(_ layout: PreviewSnapshotLayout) -> Bool {
        if case .device = layout {
            return true
        }
        return false
    }

    private func matchesSizeThatFits(_ layout: SwiftUISnapshotLayout?) -> Bool {
        guard case .sizeThatFits? = layout else {
            return false
        }
        return true
    }

    private func matchesFixed(
        _ layout: SwiftUISnapshotLayout?,
        width: CGFloat,
        height: CGFloat
    ) -> Bool {
        guard case let .fixed(actualWidth, actualHeight)? = layout else {
            return false
        }
        return actualWidth == width && actualHeight == height
    }
}

@MainActor private enum BuilderProvider: SnapshotProvider {
    @SnapshotBuilder static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("first") { Text("First") }
        [
            PreviewSnapshot("array-first", layout: .fixed(width: 320, height: 240)) { Text("Array first") },
            PreviewSnapshot("array-second", layout: .device) { Text("Array second") }
        ]
        if true {
            PreviewSnapshot("conditional") { Text("Conditional") }
        }
        for number in 1 ... 2 {
            PreviewSnapshot("loop-\(number)") { Text("Loop \(number)") }
        }
        PreviewSnapshot("last") { Text("Last") }
    }
}

@MainActor private enum PreviewAndSnapshotProvider: PreviewProvider, SnapshotProvider {
    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("default previews witness") { Text("Preview") }
    }
}

@MainActor private enum DefaultLayoutProvider: SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .fixed(width: 320, height: 240)

    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("implicit") { Text("Implicit") }
        PreviewSnapshot("explicit", layout: .sizeThatFits) { Text("Explicit") }
    }
}

@MainActor private enum TransformedDefaultLayoutProvider: SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .fixed(width: 320, height: 240)

    static var snapshots: [PreviewSnapshot] {
        [
            PreviewSnapshot("implicit") { Text("Implicit") },
            PreviewSnapshot("explicit", layout: .sizeThatFits) { Text("Explicit") }
        ]
        .transformingViews { $0 }
    }
}

@MainActor private final class Counter {
    var value = 0

    func increment() {
        value += 1
    }
}

@MainActor private struct CountingView: SwiftUI.View {
    init(counter: Counter) {
        counter.increment()
    }

    var body: some SwiftUI.View {
        EmptyView()
    }
}

@MainActor private final class Events {
    var values: [String] = []

    func append(_ value: String) {
        values.append(value)
    }
}

@MainActor private func countingTransform(_ view: AnyView, counter: Counter) -> AnyView {
    counter.increment()
    return view
}

@MainActor private func recordingTransform(_ view: AnyView, events: Events, label: String) -> AnyView {
    events.append(label)
    return view
}
#endif
