#if canImport(SwiftUI)
import SnapshotPreviews
@testable import SnapshotTesting
import SwiftUI
import XCTest
#if os(iOS) || os(tvOS)
import UIKit
#endif

@MainActor final class NamedViewImageConfigTests: XCTestCase {
    func testResolvedSnapshotsApplyTheProviderDefaultLayout() {
        let snapshots = DefaultDeviceLayoutProvider.resolvedSnapshots

        XCTAssertEqual(snapshots.map(\.name), ["default", "fixed"])
        XCTAssertTrue(matchesDevice(snapshots[0].layout))
        XCTAssertTrue(matchesFixed(snapshots[1].layout))
    }

    #if os(iOS) || os(tvOS)
    func testNamedViewImageConfigPreservesItsNameAndDevice() {
        let device = ViewImageConfig(size: .init(width: 320, height: 568))
        let configuration = NamedViewImageConfig(name: "iPhone SE", device: device)

        XCTAssertEqual(configuration.name, "iPhone SE")
        XCTAssertEqual(configuration.device.size, device.size)
    }

    func testMatrixUsesConfigurationMajorOrderAndSegmentedNames() throws {
        let snapshotDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: snapshotDirectory) }
        MatrixProvider.events = []
        let device = ViewImageConfig(size: .init(width: 40, height: 40))

        XCTExpectFailure {
            assertSnapshots(
                of: MatrixProvider.self,
                configurations: [
                    .init(name: "compact light", device: device),
                    .init(name: "compact dark", device: device)
                ],
                assertionOptions: .init(record: .all, snapshotDirectory: snapshotDirectory.path),
                testName: "test_chat"
            )
        } issueMatcher: {
            $0.compactDescription.hasPrefix(
                "failed - Record mode is on. Automatically recorded snapshot: …"
            )
        }

        XCTAssertEqual(MatrixProvider.events, ["empty", "messages", "empty", "messages"])
        XCTAssertEqual(
            try Set(FileManager.default.contentsOfDirectory(atPath: snapshotDirectory.path)),
            [
                "test_chat.compact-light.empty.png",
                "test_chat.compact-light.messages.png",
                "test_chat.compact-dark.empty.png",
                "test_chat.compact-dark.messages.png"
            ]
        )
    }

    func testInvalidMatrixDoesNotCreateSnapshotDirectory() {
        let snapshotDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: snapshotDirectory) }

        XCTExpectFailure {
            assertSnapshots(
                of: MatrixProvider.self,
                configurations: [],
                assertionOptions: .init(record: .all, snapshotDirectory: snapshotDirectory.path)
            )
        } issueMatcher: {
            $0.compactDescription == "failed - Snapshot configuration matrix must not be empty."
        }

        XCTAssertFalse(FileManager.default.fileExists(atPath: snapshotDirectory.path))
    }

    func testDuplicateSanitizedConfigurationNamesDoNotCreateSnapshotDirectory() {
        let snapshotDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: snapshotDirectory) }
        let device = ViewImageConfig(size: .init(width: 40, height: 40))

        XCTExpectFailure {
            assertSnapshots(
                of: MatrixProvider.self,
                configurations: [
                    .init(name: "compact light", device: device),
                    .init(name: "compact-light", device: device)
                ],
                assertionOptions: .init(record: .all, snapshotDirectory: snapshotDirectory.path)
            )
        } issueMatcher: {
            $0.compactDescription
                == "failed - Snapshot configuration matrix generated duplicate configuration name 'compact-light'."
        }

        XCTAssertFalse(FileManager.default.fileExists(atPath: snapshotDirectory.path))
    }

    func testMatrixAppliesConfigurationDisplayScaleToEveryLayout() throws {
        let snapshotDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: snapshotDirectory) }
        let device = ViewImageConfig(
            size: .init(width: 14, height: 15),
            traits: .init(displayScale: 2)
        )

        XCTExpectFailure {
            assertSnapshots(
                of: MatrixLayoutProvider.self,
                configurations: [.init(name: "scaled", device: device)],
                assertionOptions: .init(record: .all, snapshotDirectory: snapshotDirectory.path),
                testName: "test_layouts"
            )
        } issueMatcher: {
            $0.compactDescription.hasPrefix(
                "failed - Record mode is on. Automatically recorded snapshot: …"
            )
        }

        XCTAssertEqual(
            try imagePixelSize(
                at: snapshotDirectory.appendingPathComponent("test_layouts.scaled.device.png")
            ),
            CGSize(width: 28, height: 30)
        )
        XCTAssertEqual(
            try imagePixelSize(
                at: snapshotDirectory.appendingPathComponent("test_layouts.scaled.fixed.png")
            ),
            CGSize(width: 20, height: 22)
        )
        XCTAssertEqual(
            try imagePixelSize(
                at: snapshotDirectory.appendingPathComponent("test_layouts.scaled.fit.png")
            ),
            CGSize(width: 24, height: 26)
        )
    }

    func testExplicitTraitsOverrideDeviceConfigurationTraits() async throws {
        let device = ViewImageConfig(
            size: .init(width: 14, height: 15),
            traits: .init(displayScale: 2)
        )
        let strategy = Snapshotting<Color, UIImage>.image(
            layout: .device(config: device),
            traits: .init(displayScale: 3)
        )
        let image = await withCheckedContinuation { continuation in
            strategy.snapshot(Color.red).run { continuation.resume(returning: $0) }
        }

        XCTAssertEqual(try XCTUnwrap(image.cgImage).width, 42)
        XCTAssertEqual(try XCTUnwrap(image.cgImage).height, 45)
    }
    #endif

    private func matchesDevice(_ layout: PreviewSnapshotLayout) -> Bool {
        if case .device = layout {
            return true
        }
        return false
    }

    private func matchesFixed(_ layout: PreviewSnapshotLayout) -> Bool {
        if case .fixed = layout {
            return true
        }
        return false
    }
}

#if os(iOS) || os(tvOS)
private func imagePixelSize(at url: URL) throws -> CGSize {
    let image = try XCTUnwrap(UIImage(contentsOfFile: url.path))
    let cgImage = try XCTUnwrap(image.cgImage)
    return CGSize(width: cgImage.width, height: cgImage.height)
}

@MainActor private enum MatrixProvider: SnapshotProvider {
    static var events: [String] = []

    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("empty", layout: .fixed(width: 20, height: 20)) {
            MatrixRecordingView(name: "empty", color: .clear)
        }
        PreviewSnapshot("messages", layout: .fixed(width: 20, height: 20)) {
            MatrixRecordingView(name: "messages", color: .black)
        }
    }
}

@MainActor private enum MatrixLayoutProvider: SnapshotProvider {
    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("device", layout: .device) {
            Color.red
        }
        PreviewSnapshot("fixed", layout: .fixed(width: 10, height: 11)) {
            Color.red
        }
        PreviewSnapshot("fit", layout: .sizeThatFits) {
            Color.red.frame(width: 12, height: 13)
        }
    }
}

@MainActor private struct MatrixRecordingView: SwiftUI.View {
    let color: Color

    init(name: String, color: Color) {
        MatrixProvider.events.append(name)
        self.color = color
    }

    var body: some SwiftUI.View {
        color
    }
}
#endif

@MainActor private enum DefaultDeviceLayoutProvider: SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("default") { Text("Default") }
        PreviewSnapshot("fixed", layout: .fixed(width: 10, height: 10)) { Text("Fixed") }
    }
}
#endif
