#if canImport(Testing)
import SnapshotTesting
import Testing

@Suite(.snapshots(record: .failed, diffTool: .ksdiff)) struct BaseSuite {}
#endif
