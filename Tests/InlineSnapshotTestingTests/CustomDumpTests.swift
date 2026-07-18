#if canImport(Testing) && canImport(SnapshotTestingCustomDump)
import InlineSnapshotTesting
import SnapshotTestingCustomDump
import Testing

extension BaseSuite {
    struct CustomDumpSnapshotTests {
        @Test func basics() {
            struct User { let id: Int, name: String, bio: String }
            let user = User(id: 1, name: "Blobby", bio: "Blobbed around the world.")
            assertInlineSnapshot(of: user, as: .customDump) {
                """
                BaseSuite.CustomDumpSnapshotTests.User(
                  id: 1,
                  name: "Blobby",
                  bio: "Blobbed around the world."
                )
                """
            }
        }
    }
}
#endif
