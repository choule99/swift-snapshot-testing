#if canImport(SwiftUI)
    import Foundation
    public import SnapshotPreviews
    import SwiftUI

    #if os(iOS) || os(tvOS)
        import UIKit

        /// A device configuration with a stable name for provider snapshot matrices.
        public struct NamedViewImageConfig: Sendable {
            /// The configuration name used in the snapshot reference file name.
            public let name: String

            /// The device configuration used to render device-layout snapshots.
            public let device: ViewImageConfig

            /// Creates a named device configuration.
            public init(name: String, device: ViewImageConfig) {
                self.name = name
                self.device = device
            }
        }

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
            for snapshot in provider.resolvedSnapshots {
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

        /// Asserts every provider snapshot for every named device configuration.
        ///
        /// Snapshots are asserted in configuration-major order. Each reference file name contains the test,
        /// configuration, and snapshot names as separately sanitized segments.
        @MainActor public func assertSnapshots(
            of provider: (some SnapshotProvider).Type,
            configurations: [NamedViewImageConfig],
            imageOptions: ImageSnapshotOptions = .init(),
            drawHierarchyInKeyWindow: Bool = false,
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
            let snapshots = provider.resolvedSnapshots
            guard validateSnapshotMatrix(
                configurations: configurations,
                snapshots: snapshots,
                testName: testName,
                fileID: fileID,
                filePath: filePath,
                line: line,
                column: column
            ) else {
                return
            }

            for configuration in configurations {
                for snapshot in snapshots {
                    guard let layout = snapshot.layout.snapshotTestingLayout(on: configuration.device) else {
                        recordMissingDeviceConfiguration(
                            snapshot: snapshot,
                            fileID: fileID,
                            filePath: filePath,
                            line: line,
                            column: column
                        )
                        continue
                    }
                    SegmentedSnapshotName.$components.withValue([configuration.name, snapshot.name]) {
                        let traits = switch snapshot.layout {
                            case .device:
                                UITraitCollection()
                            case .fixed,
                                 .sizeThatFits:
                                configuration.device.traits
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
                            options: assertionOptions,
                            fileID: fileID,
                            file: filePath,
                            testName: testName,
                            line: line,
                            column: column
                        )
                    }
                }
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

        @MainActor private func validateSnapshotMatrix(
            configurations: [NamedViewImageConfig],
            snapshots: [PreviewSnapshot],
            testName: String,
            fileID: StaticString,
            filePath: StaticString,
            line: UInt,
            column: UInt
        ) -> Bool {
            guard !configurations.isEmpty else {
                recordIssue(
                    "Snapshot configuration matrix must not be empty.",
                    fileID: fileID,
                    filePath: filePath,
                    line: line,
                    column: column
                )
                return false
            }

            let testSegment = sanitizePathComponent(testName)
            guard !testSegment.isEmpty else {
                recordIssue(
                    "Snapshot test name must contain at least one path-safe character.",
                    fileID: fileID,
                    filePath: filePath,
                    line: line,
                    column: column
                )
                return false
            }

            var configurationNames = Set<String>()
            var identities = Set<String>()
            for configuration in configurations {
                let configurationSegment = sanitizePathComponent(configuration.name)
                guard !configurationSegment.isEmpty else {
                    recordIssue(
                        "Snapshot configuration name '\(configuration.name)' must contain at least one path-safe character.",
                        fileID: fileID,
                        filePath: filePath,
                        line: line,
                        column: column
                    )
                    return false
                }
                guard configurationNames.insert(configurationSegment).inserted else {
                    recordIssue(
                        "Snapshot configuration matrix generated duplicate configuration name '\(configurationSegment)'.",
                        fileID: fileID,
                        filePath: filePath,
                        line: line,
                        column: column
                    )
                    return false
                }
                for snapshot in snapshots {
                    let snapshotSegment = sanitizePathComponent(snapshot.name)
                    guard !snapshotSegment.isEmpty else {
                        recordIssue(
                            "Snapshot name '\(snapshot.name)' must contain at least one path-safe character.",
                            fileID: fileID,
                            filePath: filePath,
                            line: line,
                            column: column
                        )
                        return false
                    }
                    let identity = [testSegment, configurationSegment, snapshotSegment].joined(separator: ".")
                    guard identities.insert(identity).inserted else {
                        recordIssue(
                            "Snapshot matrix generated duplicate identity '\(identity)'.",
                            fileID: fileID,
                            filePath: filePath,
                            line: line,
                            column: column
                        )
                        return false
                    }
                }
            }
            return true
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
            for snapshot in provider.resolvedSnapshots {
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
            for snapshot in provider.resolvedSnapshots {
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
