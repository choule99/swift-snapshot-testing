#if canImport(Testing)
    import Foundation
    import Testing
    @_spi(Internals) import SnapshotTesting

    extension BaseSuite {
        struct SnapshotsTraitTests {
            @Test(.snapshots(snapshotNaming: .testName)) func testSnapshotNaming() {
                #expect(SnapshotTestingConfiguration.current?.snapshotNaming == .testName)
            }

            @Test(
                .snapshots(
                    referenceStorage: .directory("__Snapshots__", relativeTo: .testTarget)
                )
            ) func referenceStorage() {
                #expect(
                    SnapshotTestingConfiguration.current?.referenceStorage
                        == .directory("__Snapshots__", relativeTo: .testTarget)
                )
            }

            @Test(
                .snapshots(
                    locale: Locale(identifier: "fr_CA"),
                    timeZone: TimeZone(secondsFromGMT: 3600),
                    calendar: Calendar(identifier: .hebrew)
                )
            ) func snapshotEnvironment() {
                #expect(SnapshotTestingConfiguration.current?.locale?.identifier == "fr_CA")
                #expect(SnapshotTestingConfiguration.current?.timeZone?.secondsFromGMT() == 3600)
                #expect(SnapshotTestingConfiguration.current?.calendar?.identifier == .hebrew)
            }

            @Test(.snapshots(diffTool: "ksdiff")) func testDiffTool() {
                #expect(
                    _diffTool(currentFilePath: "old.png", failedFilePath: "new.png")
                        == "ksdiff old.png new.png"
                )
            }

            @Suite(.snapshots(diffTool: "ksdiff")) struct OverrideDiffTool {
                @Test(.snapshots(diffTool: "difftool")) func diffToolOverride() {
                    #expect(
                        _diffTool(currentFilePath: "old.png", failedFilePath: "new.png")
                            == "difftool old.png new.png"
                    )
                }

                @Suite(.snapshots(record: .all)) struct OverrideRecord {
                    @Test func config() {
                        #expect(
                            _diffTool(currentFilePath: "old.png", failedFilePath: "new.png")
                                == "ksdiff old.png new.png"
                        )
                        #expect(_record == .all)
                    }

                    @Suite(.snapshots(record: .failed, diffTool: "diff")) struct OverrideDiffToolAndRecord {
                        @Test func config() {
                            #expect(
                                _diffTool(currentFilePath: "old.png", failedFilePath: "new.png")
                                    == "diff old.png new.png"
                            )
                            #expect(_record == .failed)
                        }
                    }
                }
            }
        }
    }
#endif
