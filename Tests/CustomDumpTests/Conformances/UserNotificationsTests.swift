#if canImport(UserNotifications)
import CustomDump
import UserNotifications
import XCTest

class UserNotificationsTests: XCTestCase {
    func testUNAuthorizationOptions() {
        XCTAssertEqual(
            String(customDumping: [.badge, .alert] as UNAuthorizationOptions),
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
