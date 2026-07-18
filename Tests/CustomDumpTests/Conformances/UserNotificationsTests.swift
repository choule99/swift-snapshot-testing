#if canImport(UserNotifications)
import CustomDump
import UserNotifications
import XCTest

class UserNotificationsTests: XCTestCase {
    func testUNAuthorizationOptions() {
        var dump = ""
        customDump([.badge, .alert] as UNAuthorizationOptions, to: &dump)
        XCTAssertEqual(
            dump,
            """
            Set([
              UNAuthorizationOptions.alert,
              UNAuthorizationOptions.badge
            ])
            """
        )
    }
}
#endif
