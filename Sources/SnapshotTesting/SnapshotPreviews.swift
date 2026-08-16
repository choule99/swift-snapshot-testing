#if canImport(SwiftUI)
import Foundation
public import SnapshotPreviews
import SwiftUI

#if os(iOS) || os(tvOS)
import UIKit

/// Asserts that every snapshot supplied by a preview provider matches its image reference.
///
/// Snapshots using the ``PreviewSnapshotLayout/device`` layout require the overload that accepts a
/// `ViewImageConfig`.
@MainActor public func assertSnapshots(
    of provider: (some SnapshotProvider).Type,
    imageOptions: ImageSnapshotOptions = .init(),
    drawHierarchyInKeyWindow: Bool = false,
    traits: UITraitCollection = .init(),
    settlingDelay: TimeInterval = 0,
    isOpaque: Bool = false,
    prepare: (@MainActor @Sendable () -> Void)? = nil,
    assertionOptions: SnapshotAssertionOptions = .init(),
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    assertSnapshots(
        of: provider,
        on: nil,
        imageOptions: imageOptions,
        drawHierarchyInKeyWindow: drawHierarchyInKeyWindow,
        traits: traits,
        settlingDelay: settlingDelay,
        isOpaque: isOpaque,
        prepare: prepare,
        assertionOptions: assertionOptions,
        fileID: fileID,
        file: filePath,
        testName: testName,
        line: line,
        column: column
    )
}

/// Asserts that every snapshot supplied by a preview provider matches its image reference.
///
/// The device configuration is used by snapshots whose layout is
/// ``PreviewSnapshotLayout/device``. Fixed and size-to-fit snapshots keep their declared layouts.
@MainActor public func assertSnapshots(
    of provider: (some SnapshotProvider).Type,
    on deviceConfig: ViewImageConfig,
    imageOptions: ImageSnapshotOptions = .init(),
    drawHierarchyInKeyWindow: Bool = false,
    traits: UITraitCollection = .init(),
    settlingDelay: TimeInterval = 0,
    isOpaque: Bool = false,
    prepare: (@MainActor @Sendable () -> Void)? = nil,
    assertionOptions: SnapshotAssertionOptions = .init(),
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    assertSnapshots(
        of: provider,
        on: Optional(deviceConfig),
        imageOptions: imageOptions,
        drawHierarchyInKeyWindow: drawHierarchyInKeyWindow,
        traits: traits,
        settlingDelay: settlingDelay,
        isOpaque: isOpaque,
        prepare: prepare,
        assertionOptions: assertionOptions,
        fileID: fileID,
        file: filePath,
        testName: testName,
        line: line,
        column: column
    )
}

// swiftlint:disable:next function_parameter_count
@MainActor private func assertSnapshots(
    of provider: (some SnapshotProvider).Type,
    on deviceConfig: ViewImageConfig?,
    imageOptions: ImageSnapshotOptions,
    drawHierarchyInKeyWindow: Bool,
    traits: UITraitCollection,
    settlingDelay: TimeInterval,
    isOpaque: Bool,
    prepare: (@MainActor @Sendable () -> Void)?,
    assertionOptions: SnapshotAssertionOptions,
    fileID: StaticString,
    file filePath: StaticString,
    testName: String,
    line: UInt,
    column: UInt
) {
    for snapshot in provider.snapshots {
        guard let layout = snapshot.layout.snapshotTestingLayout(on: deviceConfig) else {
            recordMissingDeviceConfiguration(
                snapshot: snapshot,
                fileID: fileID,
                filePath: filePath,
                line: line,
                column: column
            )
            continue
        }
        assertSnapshot(
            of: snapshot.view(),
            as: .image(
                options: imageOptions,
                drawHierarchyInKeyWindow: drawHierarchyInKeyWindow,
                layout: layout,
                traits: traits,
                settlingDelay: settlingDelay,
                isOpaque: isOpaque,
                prepare: prepare
            ),
            named: snapshot.name,
            options: assertionOptions,
            fileID: fileID,
            file: filePath,
            testName: testName,
            line: line,
            column: column
        )
    }
}

@MainActor extension PreviewSnapshotLayout {
    func snapshotTestingLayout(on deviceConfig: ViewImageConfig?) -> SwiftUISnapshotLayout? {
        switch self {
            case .device:
                deviceConfig.map(SwiftUISnapshotLayout.device(config:))
            case let .fixed(width, height):
                .fixed(width: width, height: height)
            case .sizeThatFits:
                .sizeThatFits
        }
    }
}
#elseif os(macOS)
import AppKit

/// Asserts that every fixed or size-to-fit snapshot supplied by a preview provider matches its
/// image reference.
@MainActor public func assertSnapshots(
    of provider: (some SnapshotProvider).Type,
    imageOptions: ImageSnapshotOptions = .init(),
    isOpaque: Bool = false,
    prepare: (@MainActor @Sendable () -> Void)? = nil,
    assertionOptions: SnapshotAssertionOptions = .init(),
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    for snapshot in provider.snapshots {
        guard let layout = snapshot.layout.snapshotTestingLayout else {
            recordUnsupportedDeviceLayout(
                snapshot: snapshot,
                fileID: fileID,
                filePath: filePath,
                line: line,
                column: column
            )
            continue
        }
        assertSnapshot(
            of: snapshot.view(),
            as: .image(
                options: imageOptions,
                layout: layout,
                isOpaque: isOpaque,
                prepare: prepare
            ),
            named: snapshot.name,
            options: assertionOptions,
            fileID: fileID,
            file: filePath,
            testName: testName,
            line: line,
            column: column
        )
    }
}

@MainActor extension PreviewSnapshotLayout {
    var snapshotTestingLayout: SwiftUISnapshotLayout? {
        switch self {
            case .device:
                nil
            case let .fixed(width, height):
                .fixed(width: width, height: height)
            case .sizeThatFits:
                .sizeThatFits
        }
    }
}
#elseif os(watchOS)
import UIKit

/// Asserts that every fixed or size-to-fit snapshot supplied by a preview provider matches its
/// image reference.
@MainActor public func assertSnapshots(
    of provider: (some SnapshotProvider).Type,
    imageOptions: ImageSnapshotOptions = .init(),
    isOpaque: Bool = false,
    assertionOptions: SnapshotAssertionOptions = .init(),
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    for snapshot in provider.snapshots {
        guard let layout = snapshot.layout.snapshotTestingLayout else {
            recordUnsupportedDeviceLayout(
                snapshot: snapshot,
                fileID: fileID,
                filePath: filePath,
                line: line,
                column: column
            )
            continue
        }
        assertSnapshot(
            of: snapshot.view(),
            as: .image(options: imageOptions, layout: layout, isOpaque: isOpaque),
            named: snapshot.name,
            options: assertionOptions,
            fileID: fileID,
            file: filePath,
            testName: testName,
            line: line,
            column: column
        )
    }
}

@MainActor extension PreviewSnapshotLayout {
    var snapshotTestingLayout: SwiftUISnapshotLayout? {
        switch self {
            case .device:
                nil
            case let .fixed(width, height):
                .fixed(width: width, height: height)
            case .sizeThatFits:
                .sizeThatFits
        }
    }
}
#endif

#if os(iOS) || os(tvOS)
private func recordMissingDeviceConfiguration(
    snapshot: PreviewSnapshot,
    fileID: StaticString,
    filePath: StaticString,
    line: UInt,
    column: UInt
) {
    recordIssue(
        "Snapshot '\(snapshot.name)' uses the device layout. Pass a ViewImageConfig using the 'on:' overload.",
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
    )
}
#elseif os(macOS) || os(watchOS)
private func recordUnsupportedDeviceLayout(
    snapshot: PreviewSnapshot,
    fileID: StaticString,
    filePath: StaticString,
    line: UInt,
    column: UInt
) {
    recordIssue(
        "Snapshot '\(snapshot.name)' uses the device layout, which image snapshots do not support on this platform.",
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
    )
}
#endif
#else
import SnapshotPreviews
#endif
