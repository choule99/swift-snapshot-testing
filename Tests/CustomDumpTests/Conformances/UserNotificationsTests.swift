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

        #if os(iOS) || os(watchOS)
            func testLegacyAnnouncementAuthorizationOption() {
                XCTAssertEqual(
                    String(customDumping: UNAuthorizationOptions(rawValue: 1 << 7)),
                    """
                    Set([
                      UNAuthorizationOptions.announcement
                    ])
                    """
                )
            }
        #endif

        func testLegacyAlertPresentationOption() {
            XCTAssertEqual(
                String(customDumping: UNNotificationPresentationOptions(rawValue: 1 << 2)),
                """
                Set([
                  UNNotificationPresentationOptions.alert
                ])
                """
            )
        }
    }
#endif
