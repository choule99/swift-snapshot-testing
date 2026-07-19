#if canImport(UIKit) && !os(watchOS)
import CustomDump
import UIKit
import XCTest

final class UIKitTests: XCTestCase {
    func testUIControlState() {
        XCTAssertEqual(
            String(customDumping: [.selected, .highlighted] as UIControl.State),
            """
            Set([
              UIControl.State.highlighted,
              UIControl.State.normal,
              UIControl.State.selected
            ])
            """
        )

        XCTAssertEqual(
            String(customDumping: UIControl.State.normal),
            """
            Set([
              UIControl.State.normal
            ])
            """
        )
    }
}
#endif
