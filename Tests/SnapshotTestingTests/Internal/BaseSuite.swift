#if canImport(Testing)
    import SnapshotTesting
    import Testing

    @MainActor
    @Suite(.snapshots(record: .failed, diffTool: .ksdiff)) struct BaseSuite {}
#endif
