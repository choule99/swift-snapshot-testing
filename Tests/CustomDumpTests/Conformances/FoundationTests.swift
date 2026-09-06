import CustomDump
import Foundation
import XCTest

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

final class FoundationTests: XCTestCase {
    func testAttributedString() {
        #if !targetEnvironment(macCatalyst) && (os(iOS) || os(tvOS) || os(watchOS))
            let dump = String(customDumping: try? AttributedString(markdown: "Hello, **Blob**!"))
            expectNoDifference(
                dump,
                """
                "Hello, Blob!"
                """
            )
        #endif
    }

    func testCFNumber() {
        // NB: `CFNumber` is unavailable on Linux
        #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
            let dump = String(customDumping: 42 as CFNumber)
            expectNoDifference(
                dump,
                """
                42
                """
            )
        #endif
    }

    #if !os(WASI)
        func testDate() {
            let dump = String(customDumping: Date(timeIntervalSince1970: 0))
            expectNoDifference(
                dump,
                """
                Date(1970-01-01T00:00:00.000Z)
                """
            )

            let nestedDump = String(customDumping: NestedDate(date: Date(timeIntervalSince1970: 0)))
            expectNoDifference(
                nestedDump,
                """
                NestedDate(date: Date(1970-01-01T00:00:00.000Z))
                """
            )
        }
    #endif

    func testDecimal() {
        let dump = String(customDumping: Decimal(string: "1.23"))
        expectNoDifference(
            dump,
            """
            1.23
            """
        )
    }

    func testNSArray() {
        let dump = String(customDumping: [1, 2, 3] as NSArray)
        expectNoDifference(
            dump,
            """
            [
              [0]: 1,
              [1]: 2,
              [2]: 3
            ]
            """
        )
    }

    func testNSAttributedString() {
        let attributedString = NSMutableAttributedString(string: "")
        attributedString.append(NSAttributedString(string: "Hello, "))
        attributedString.append(
            NSAttributedString(string: "Blob", attributes: [.init(rawValue: "name"): true])
        )
        attributedString.append(NSAttributedString(string: "!"))
        let dump = String(customDumping: attributedString)
        expectNoDifference(
            dump,
            """
            "Hello, Blob!"
            """
        )
    }

    func testNSCalendar() throws {
        let calendar = try XCTUnwrap(NSCalendar(calendarIdentifier: .gregorian))
        calendar.timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
        let dump = String(customDumping: calendar)
        expectNoDifference(
            dump,
            """
            Calendar(
              identifier: .gregorian,
              locale: Locale(),
              timeZone: TimeZone(
                identifier: "GMT",
                abbreviation: "GMT",
                secondsFromGMT: 0,
                isDaylightSavingTime: false
              ),
              firstWeekday: 1,
              minimumDaysInFirstWeek: 1
            )
            """
        )
    }

    func testNSCountedSet() {
        let dump = String(customDumping: NSCountedSet(array: [1, 2, 2, 3, 3, 3]))
        expectNoDifference(
            dump,
            """
            Set([
              1,
              2,
              3
            ])
            """
        )
    }

    #if !os(WASI)
        func testNSData() {
            let dump = String(customDumping: NSData(data: .init(repeating: 0, count: 4)))
            expectNoDifference(
                dump,
                """
                Data(4 bytes)
                """
            )
        }
    #endif

    #if !os(WASI)
        func testNSDate() {
            let dump = String(customDumping: NSDate(timeIntervalSince1970: 0))
            expectNoDifference(
                dump,
                """
                Date(1970-01-01T00:00:00.000Z)
                """
            )
        }
    #endif

    func testNSDictionary() {
        let dump = String(customDumping: [1: "1", 2: "2", 3: "3"] as NSDictionary)
        expectNoDifference(
            dump,
            """
            [
              1: "1",
              2: "2",
              3: "3"
            ]
            """
        )
    }

    func testNSError() {
        let dump = String(
            customDumping: NSError(
                domain: "co.pointfree",
                code: 42,
                userInfo: [
                    NSLocalizedDescriptionKey: "An error occurred" as NSString
                ]
            )
        )
        expectNoDifference(
            dump,
            """
            NSError(
              domain: "co.pointfree",
              code: 42,
              userInfo: [
                "NSLocalizedDescription": "An error occurred"
              ]
            )
            """
        )

        #if !os(Windows) && !os(WASI)
            class SubclassedError: NSError, @unchecked Sendable {}

            let subclassedDump = String(
                customDumping: SubclassedError(
                    domain: "co.pointfree",
                    code: 43,
                    userInfo: [
                        NSLocalizedDescriptionKey: "An error occurred" as NSString
                    ]
                )
            )
            expectNoDifference(
                subclassedDump,
                """
                NSError(
                  domain: "co.pointfree",
                  code: 43,
                  userInfo: [
                    "NSLocalizedDescription": "An error occurred"
                  ]
                )
                """
            )
        #endif

        enum BridgedError: Error {
            case thisIsFine(Int)
        }

        let bridgedDump = String(customDumping: BridgedError.thisIsFine(94) as NSError)
        #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
            expectNoDifference(
                bridgedDump,
                """
                FoundationTests.BridgedError.thisIsFine(94)
                """
            )
        #else
            // Can't unwrap bridged Errors on Linux: https://bugs.swift.org/browse/SR-15191
            expectNoDifference(
                bridgedDump.replacingOccurrences(
                    of: #"\(unknown context at \$[[:xdigit:]]+\)\."#,
                    with: "",
                    options: .regularExpression
                ),
                """
                NSError(
                  domain: "CustomDumpTests.FoundationTests.BridgedError",
                  code: 0,
                  userInfo: [:]
                )
                """
            )
        #endif
    }

    func testNSException() {
        // NB: `NSException` is unavailable on Linux
        #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
            let dump = String(
                customDumping: NSException(name: .genericException, reason: "Oops!", userInfo: nil)
            )
            expectNoDifference(
                dump,
                """
                NSException(
                  name: NSGenericException,
                  reason: "Oops!",
                  userInfo: nil
                )
                """
            )
        #endif
    }

    func testNSExpression() {
        // NB: `NSExpression` is unavailable on Linux
        #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
            let dump = String(customDumping: NSExpression(format: "1 + 1"))
            expectNoDifference(
                dump,
                """
                1 + 1
                """
            )
        #endif
    }

    func testNSIndexPath() {
        let dump = String(customDumping: NSIndexPath())
        expectNoDifference(
            dump,
            """
            []
            """
        )
    }

    func testNSIndexSet() {
        let dump = String(customDumping: NSIndexSet(indexSet: [1, 2, 3, 5, 7]))
        expectNoDifference(
            dump,
            """
            IndexSet(
              ranges: [
                [0]: 1..<4,
                [1]: 5..<6,
                [2]: 7..<8
              ]
            )
            """
        )
    }

    func testNSLocale() {
        let dump = String(customDumping: NSLocale(localeIdentifier: "en_US"))
        expectNoDifference(
            dump,
            """
            Locale(en_US)
            """
        )
    }

    func testNSMeasurement() {
        let dump = String(customDumping: NSMeasurement(doubleValue: 42, unit: Unit(symbol: "kg")))
        expectNoDifference(
            dump,
            """
            Measurement(
              value: 42.0,
              unit: "kg"
            )
            """
        )
    }

    #if !os(WASI)
        func testNSNotification() {
            let dump = String(
                customDumping: NSNotification(
                    name: .init(rawValue: "co.pointfree"), object: nil, userInfo: nil
                )
            )
            expectNoDifference(
                dump,
                """
                Notification(name: "co.pointfree")
                """
            )
        }
    #endif

    func testNSNull() {
        let dump = String(customDumping: NSNull())
        expectNoDifference(
            dump,
            """
            NSNull()
            """
        )
    }

    func testNSNumber() {
        let dump = String(customDumping: 1 as NSNumber)
        expectNoDifference(
            dump,
            """
            1
            """
        )

        #if canImport(ObjectiveC)
            let nullDump = String(customDumping: NSNumber())
            expectNoDifference(
                nullDump,
                """
                (null pointer)
                """
            )
        #endif
    }

    func testNSOrderedSet() {
        let dump = String(customDumping: [1, 2, 3] as NSOrderedSet)
        expectNoDifference(
            dump,
            """
            [
              [0]: 1,
              [1]: 2,
              [2]: 3
            ]
            """
        )
    }

    func testNSRange() {
        let dump = String(customDumping: NSRange(0 ..< 1))
        expectNoDifference(
            dump,
            """
            0..<1
            """
        )
    }

    func testNSSet() {
        let dump = String(customDumping: NSSet(array: [1, 2, 3]))
        expectNoDifference(
            dump,
            """
            Set([
              1,
              2,
              3
            ])
            """
        )
    }

    #if !os(WASI)
        func testNSTimeZone() {
            let dump = String(customDumping: NSTimeZone(forSecondsFromGMT: 0))
            expectNoDifference(
                dump,
                """
                TimeZone(
                  identifier: "GMT",
                  abbreviation: "GMT",
                  secondsFromGMT: 0,
                  isDaylightSavingTime: false
                )
                """
            )
        }
    #endif

    func testNSURL() {
        let dump = String(customDumping: NSURL(fileURLWithPath: "/tmp"))
        #if os(Windows) || os(WASI)
            expectNoDifference(
                dump,
                """
                URL(file:///tmp)
                """
            )
        #else
            expectNoDifference(
                dump,
                """
                URL(file:///tmp/)
                """
            )
        #endif
    }

    func testNSURLComponents() {
        let dump = String(
            customDumping: NSURLComponents(string: "https://www.pointfree.co/login?redirect=episodes")
        )
        expectNoDifference(
            dump,
            """
            URLComponents(
              scheme: "https",
              host: "www.pointfree.co",
              path: "/login",
              queryItems: [
                [0]: URLQueryItem(
                  name: "redirect",
                  value: "episodes"
                )
              ]
            )
            """
        )
    }

    func testNSURLQueryItem() {
        let dump = String(customDumping: NSURLQueryItem(name: "search", value: "composable architecture"))
        expectNoDifference(
            dump,
            """
            URLQueryItem(
              name: "search",
              value: "composable architecture"
            )
            """
        )
    }

    func testNSUUID() {
        let dump = String(customDumping: NSUUID(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef"))
        expectNoDifference(
            dump,
            """
            UUID(DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF)
            """
        )
    }

    func testURL() {
        let dump = String(customDumping: URL(string: "https://www.pointfree.co/"))
        expectNoDifference(
            dump,
            """
            URL(https://www.pointfree.co/)
            """
        )
    }
}
