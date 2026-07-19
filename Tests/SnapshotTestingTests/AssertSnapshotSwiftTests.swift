#if canImport(Testing)
import Foundation
import SnapshotTesting
import Testing

extension BaseSuite {
    @MainActor struct AssertSnapshotTests {
        @Test(.snapshots(record: .missing)) func dump() {
            struct User { let id: Int, name: String, bio: String }
            let user = User(id: 1, name: "Blobby", bio: "Blobbed around the world.")
            assertSnapshot(of: user, as: .dump)
        }
    }
}
#endif
