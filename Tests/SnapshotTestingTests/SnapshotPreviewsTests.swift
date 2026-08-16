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
#endif
