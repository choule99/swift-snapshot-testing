import Foundation
@testable import SnapshotTesting
import SwiftUI
import XCTest

#if os(macOS)
import AppKit
#elseif os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#endif

@MainActor final class PrepareTests: BaseTestCase {
    #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    func testSwiftUISnapshotEnvironment() throws {
        let defaultState = renderSnapshotEnvironment()
        XCTAssertEqual(defaultState.locale?.identifier, "en_US_POSIX")
        XCTAssertEqual(defaultState.timeZone?.secondsFromGMT(), 0)
        XCTAssertEqual(defaultState.calendar?.identifier, .gregorian)
        XCTAssertEqual(defaultState.calendar?.locale?.identifier, "en_US_POSIX")
        XCTAssertEqual(defaultState.calendar?.timeZone.secondsFromGMT(), 0)

        let locale = Locale(identifier: "fr_CA")
        let timeZone = try XCTUnwrap(TimeZone(identifier: "America/Toronto"))
        var calendar = Calendar(identifier: .hebrew)
        calendar.locale = locale
        calendar.timeZone = timeZone
        let state = renderSnapshotEnvironment(locale: locale, timeZone: timeZone, calendar: calendar)

        XCTAssertEqual(state.locale, locale)
        XCTAssertEqual(state.timeZone, timeZone)
        XCTAssertEqual(state.calendar, calendar)
    }

    private func renderSnapshotEnvironment(
        locale: Locale? = nil,
        timeZone: TimeZone? = nil,
        calendar: Calendar? = nil
    ) -> SnapshotEnvironmentState {
        let state = SnapshotEnvironmentState()
        withSnapshotTesting(locale: locale, timeZone: timeZone, calendar: calendar) {
            let tookSnapshot = XCTestExpectation(description: "Took snapshot")
            #if os(macOS)
            let strategy = Snapshotting<SnapshotEnvironmentProbe, NSImage>.image(
                layout: .fixed(width: 10, height: 10)
            )
            #elseif os(watchOS)
            let strategy = Snapshotting<SnapshotEnvironmentProbe, UIImage>.image(
                layout: .fixed(width: 10, height: 10)
            )
            #else
            let strategy = Snapshotting<SnapshotEnvironmentProbe, UIImage>.image(
                layout: .fixed(width: 10, height: 10),
                traits: .init(displayScale: 1)
            )
            #endif
            strategy.snapshot(SnapshotEnvironmentProbe(state: state)).run { _ in
                tookSnapshot.fulfill()
            }
            XCTAssertEqual(XCTWaiter.wait(for: [tookSnapshot], timeout: 1), .completed)
        }
        return state
    }
    #endif

    #if os(iOS) || os(tvOS)
    func testUIKitPrepareRunsAfterLayoutAndBeforeRendering() async {
        let state = PrepareState()
        let view = PrepareUIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        let traits = UITraitCollection(displayScale: 1)
        let strategy = Snapshotting<PrepareUIView, UIImage>.image(
            traits: traits,
            prepare: {
                state.callCount += 1
                state.didObserveLayout = view.didLayout
                view.backgroundColor = .red
            }
        )
        let image = await snapshot(view, as: strategy)

        let expectedView = UIView(frame: view.frame)
        expectedView.backgroundColor = .red
        let expected = await snapshot(
            expectedView,
            as: Snapshotting<UIView, UIImage>.image(traits: traits)
        )

        XCTAssertEqual(state.callCount, 1)
        XCTAssertTrue(state.didObserveLayout)
        XCTAssertNil(Diffing<UIImage>.image(scale: 1).diffV2(expected, image))

        let _: Snapshotting<UIViewController, UIImage> = .image(prepare: {})
        #if os(iOS)
        let _: Snapshotting<UIViewController, UIImage> = .image(on: .iPhoneSe, prepare: {})
        #else
        let _: Snapshotting<UIViewController, UIImage> = .image(on: .tv, prepare: {})
        #endif
    }

    func testUIKitSwiftUIPrepareRunsOnce() async {
        let state = PrepareState()
        Task { @MainActor in state.didSettle = true }
        let strategy = Snapshotting<SwiftUI.Color, UIImage>.image(
            layout: .fixed(width: 10, height: 10),
            traits: .init(displayScale: 1),
            settlingDelay: 0.01,
            prepare: {
                state.callCount += 1
                state.didObserveSettling = state.didSettle
            }
        )

        let image = await snapshot(.blue, as: strategy)

        XCTAssertEqual(state.callCount, 1)
        XCTAssertTrue(state.didObserveSettling)
        XCTAssertEqual(image.size, CGSize(width: 10, height: 10))
    }
    #elseif os(macOS)
    func testAppKitPrepareRunsAfterLayoutAndBeforeRendering() async {
        let state = PrepareState()
        let view = PrepareNSView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        view.needsLayout = true
        let strategy = Snapshotting<PrepareNSView, NSImage>.image(
            prepare: {
                state.callCount += 1
                state.didObserveLayout = view.didLayout
                view.color = .red
                view.needsDisplay = true
            }
        )
        let image = await snapshot(view, as: strategy)

        let expectedView = PrepareNSView(frame: view.frame)
        expectedView.color = .red
        let expected = await snapshot(
            expectedView,
            as: Snapshotting<PrepareNSView, NSImage>.image()
        )

        XCTAssertEqual(state.callCount, 1)
        XCTAssertTrue(state.didObserveLayout)
        XCTAssertNil(Diffing<NSImage>.image.diffV2(expected, image))

        let _: Snapshotting<NSViewController, NSImage> = .image(prepare: {})
    }

    func testMacSwiftUIPrepareRunsOnce() async {
        let state = PrepareState()
        let strategy = Snapshotting<SwiftUI.Color, NSImage>.image(
            layout: .fixed(width: 10, height: 10),
            prepare: { state.callCount += 1 }
        )

        let image = await snapshot(.blue, as: strategy)

        XCTAssertEqual(state.callCount, 1)
        XCTAssertEqual(image.size, CGSize(width: 10, height: 10))
    }
    #endif

    #if os(iOS) || os(tvOS)
    private func snapshot<Value>(
        _ value: Value,
        as strategy: Snapshotting<Value, UIImage>
    ) async -> UIImage {
        await withCheckedContinuation { continuation in
            strategy.snapshot(value).run {
                continuation.resume(returning: $0)
            }
        }
    }
    #elseif os(macOS)
    private func snapshot<Value>(
        _ value: Value,
        as strategy: Snapshotting<Value, NSImage>
    ) async -> NSImage {
        await withCheckedContinuation { continuation in
            strategy.snapshot(value).run {
                continuation.resume(returning: $0)
            }
        }
    }
    #endif
}

@MainActor private final class PrepareState {
    var callCount = 0
    var didObserveLayout = false
    var didObserveSettling = false
    var didSettle = false
}

@MainActor private final class SnapshotEnvironmentState {
    var calendar: Calendar?
    var locale: Locale?
    var timeZone: TimeZone?
}

private struct SnapshotEnvironmentProbe: SwiftUI.View {
    @Environment(\.calendar) private var calendar
    @Environment(\.locale) private var locale
    @Environment(\.timeZone) private var timeZone

    let state: SnapshotEnvironmentState

    var body: some SwiftUI.View {
        state.calendar = calendar
        state.locale = locale
        state.timeZone = timeZone
        return SwiftUI.Color.clear
    }
}

#if os(iOS) || os(tvOS)
@MainActor private final class PrepareUIView: UIView {
    var didLayout = false

    override func layoutSubviews() {
        super.layoutSubviews()
        didLayout = true
    }
}
#elseif os(macOS)
@MainActor private final class PrepareNSView: NSView {
    var color = NSColor.blue
    var didLayout = false

    override func layout() {
        super.layout()
        didLayout = true
    }

    override func draw(_ dirtyRect: NSRect) {
        color.setFill()
        dirtyRect.fill()
    }
}
#endif
