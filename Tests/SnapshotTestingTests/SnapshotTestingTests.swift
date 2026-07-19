import Foundation
@testable import SnapshotTesting
import XCTest

// SwiftPM's Linux XCTest discovery requires async wrappers for @MainActor test methods.
// swiftformat:disable redundantAsync

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
#if canImport(SceneKit)
import SceneKit
#endif
#if canImport(SpriteKit)
import SpriteKit
import SwiftUI
#endif
#if canImport(WebKit)
@preconcurrency import WebKit
#endif
#if canImport(UIKit)
#if canImport(CoreImage)
import CoreImage
#endif
import UIKit
#endif

final class SnapshotTestingTests: BaseTestCase {
    func testCoreTypesAreSendable() async {
        // swiftformat:disable:next opaqueGenericParameters
        func requireSendable<T: Sendable>(_: T.Type) {}

        requireSendable(Async<String>.self)
        requireSendable(Diffing<String>.self)
        requireSendable(Snapshotting<String, String>.self)
    }

    func testLineEndings() async {
        let lf = "one\ntwo\n"
        let crlf = "one\r\ntwo\r\n"

        XCTAssertEqual(Diffing<String>.lines.toData(crlf), Data(crlf.utf8))
        XCTAssertEqual(Diffing<String>.lines.fromData(Data(crlf.utf8)), crlf)
        XCTAssertNil(Diffing<String>.lines.diffV2(lf, crlf))
        XCTAssertNil(Diffing<String>.lines.diffV2(crlf, lf))
        XCTAssertNil(Diffing<String>.lines.diffV2("one\rtwo\r", lf))
        XCTAssertNotNil(Diffing<String>.lines.diffV2(lf, "one\r\nthree\r\n"))
    }

    func testModernIPhoneConfigs() async {
        #if os(iOS)
        func assertDevice(
            _ name: String,
            portrait: ViewImageConfig,
            landscape: ViewImageConfig,
            portraitSize: CGSize,
            portraitSafeArea: UIEdgeInsets,
            landscapeSafeArea: UIEdgeInsets,
            landscapeHorizontalSizeClass: UIUserInterfaceSizeClass
        ) {
            XCTAssertEqual(portrait.size, portraitSize, name)
            XCTAssertEqual(portrait.safeArea, portraitSafeArea, name)
            XCTAssertEqual(portrait.traits.horizontalSizeClass, .compact, name)
            XCTAssertEqual(portrait.traits.verticalSizeClass, .regular, name)
            XCTAssertEqual(portrait.traits.forceTouchCapability, .unavailable, name)
            XCTAssertEqual(
                landscape.size,
                .init(width: portraitSize.height, height: portraitSize.width),
                name
            )
            XCTAssertEqual(landscape.safeArea, landscapeSafeArea, name)
            XCTAssertEqual(
                landscape.traits.horizontalSizeClass,
                landscapeHorizontalSizeClass,
                name
            )
            XCTAssertEqual(landscape.traits.verticalSizeClass, .compact, name)
            XCTAssertEqual(landscape.traits.forceTouchCapability, .unavailable, name)
        }

        assertDevice(
            "iPhone 14",
            portrait: .iPhone14,
            landscape: .iPhone14(.landscape),
            portraitSize: .init(width: 390, height: 844),
            portraitSafeArea: .init(top: 47, left: 0, bottom: 34, right: 0),
            landscapeSafeArea: .init(top: 0, left: 47, bottom: 21, right: 47),
            landscapeHorizontalSizeClass: .compact
        )
        assertDevice(
            "iPhone 14 Plus",
            portrait: .iPhone14Plus,
            landscape: .iPhone14Plus(.landscape),
            portraitSize: .init(width: 428, height: 926),
            portraitSafeArea: .init(top: 47, left: 0, bottom: 34, right: 0),
            landscapeSafeArea: .init(top: 0, left: 47, bottom: 21, right: 47),
            landscapeHorizontalSizeClass: .regular
        )
        assertDevice(
            "iPhone 14 Pro",
            portrait: .iPhone14Pro,
            landscape: .iPhone14Pro(.landscape),
            portraitSize: .init(width: 393, height: 852),
            portraitSafeArea: .init(top: 59, left: 0, bottom: 34, right: 0),
            landscapeSafeArea: .init(top: 0, left: 59, bottom: 21, right: 59),
            landscapeHorizontalSizeClass: .compact
        )
        assertDevice(
            "iPhone 14 Pro Max",
            portrait: .iPhone14ProMax,
            landscape: .iPhone14ProMax(.landscape),
            portraitSize: .init(width: 430, height: 932),
            portraitSafeArea: .init(top: 59, left: 0, bottom: 34, right: 0),
            landscapeSafeArea: .init(top: 0, left: 59, bottom: 21, right: 59),
            landscapeHorizontalSizeClass: .regular
        )
        assertDevice(
            "iPhone 15",
            portrait: .iPhone15,
            landscape: .iPhone15(.landscape),
            portraitSize: .init(width: 393, height: 852),
            portraitSafeArea: .init(top: 59, left: 0, bottom: 34, right: 0),
            landscapeSafeArea: .init(top: 0, left: 59, bottom: 21, right: 59),
            landscapeHorizontalSizeClass: .compact
        )
        assertDevice(
            "iPhone 15 Plus",
            portrait: .iPhone15Plus,
            landscape: .iPhone15Plus(.landscape),
            portraitSize: .init(width: 430, height: 932),
            portraitSafeArea: .init(top: 59, left: 0, bottom: 34, right: 0),
            landscapeSafeArea: .init(top: 0, left: 59, bottom: 21, right: 59),
            landscapeHorizontalSizeClass: .regular
        )
        assertDevice(
            "iPhone 15 Pro",
            portrait: .iPhone15Pro,
            landscape: .iPhone15Pro(.landscape),
            portraitSize: .init(width: 393, height: 852),
            portraitSafeArea: .init(top: 59, left: 0, bottom: 34, right: 0),
            landscapeSafeArea: .init(top: 0, left: 59, bottom: 21, right: 59),
            landscapeHorizontalSizeClass: .compact
        )
        assertDevice(
            "iPhone 15 Pro Max",
            portrait: .iPhone15ProMax,
            landscape: .iPhone15ProMax(.landscape),
            portraitSize: .init(width: 430, height: 932),
            portraitSafeArea: .init(top: 59, left: 0, bottom: 34, right: 0),
            landscapeSafeArea: .init(top: 0, left: 59, bottom: 21, right: 59),
            landscapeHorizontalSizeClass: .regular
        )
        assertDevice(
            "iPhone 16",
            portrait: .iPhone16,
            landscape: .iPhone16(.landscape),
            portraitSize: .init(width: 393, height: 852),
            portraitSafeArea: .init(top: 59, left: 0, bottom: 34, right: 0),
            landscapeSafeArea: .init(top: 0, left: 59, bottom: 21, right: 59),
            landscapeHorizontalSizeClass: .compact
        )
        assertDevice(
            "iPhone 16 Plus",
            portrait: .iPhone16Plus,
            landscape: .iPhone16Plus(.landscape),
            portraitSize: .init(width: 430, height: 932),
            portraitSafeArea: .init(top: 59, left: 0, bottom: 34, right: 0),
            landscapeSafeArea: .init(top: 0, left: 59, bottom: 21, right: 59),
            landscapeHorizontalSizeClass: .regular
        )
        assertDevice(
            "iPhone 16 Pro",
            portrait: .iPhone16Pro,
            landscape: .iPhone16Pro(.landscape),
            portraitSize: .init(width: 402, height: 874),
            portraitSafeArea: .init(top: 62, left: 0, bottom: 34, right: 0),
            landscapeSafeArea: .init(top: 0, left: 62, bottom: 21, right: 62),
            landscapeHorizontalSizeClass: .compact
        )
        assertDevice(
            "iPhone 16 Pro Max",
            portrait: .iPhone16ProMax,
            landscape: .iPhone16ProMax(.landscape),
            portraitSize: .init(width: 440, height: 956),
            portraitSafeArea: .init(top: 62, left: 0, bottom: 34, right: 0),
            landscapeSafeArea: .init(top: 0, left: 62, bottom: 21, right: 62),
            landscapeHorizontalSizeClass: .regular
        )
        assertDevice(
            "iPhone 16e",
            portrait: .iPhone16e,
            landscape: .iPhone16e(.landscape),
            portraitSize: .init(width: 390, height: 844),
            portraitSafeArea: .init(top: 47, left: 0, bottom: 34, right: 0),
            landscapeSafeArea: .init(top: 0, left: 47, bottom: 21, right: 47),
            landscapeHorizontalSizeClass: .compact
        )
        assertDevice(
            "iPhone 17",
            portrait: .iPhone17,
            landscape: .iPhone17(.landscape),
            portraitSize: .init(width: 402, height: 874),
            portraitSafeArea: .init(top: 62, left: 0, bottom: 34, right: 0),
            landscapeSafeArea: .init(top: 20, left: 62, bottom: 20, right: 62),
            landscapeHorizontalSizeClass: .compact
        )
        assertDevice(
            "iPhone 17 Pro",
            portrait: .iPhone17Pro,
            landscape: .iPhone17Pro(.landscape),
            portraitSize: .init(width: 402, height: 874),
            portraitSafeArea: .init(top: 62, left: 0, bottom: 34, right: 0),
            landscapeSafeArea: .init(top: 20, left: 62, bottom: 20, right: 62),
            landscapeHorizontalSizeClass: .compact
        )
        assertDevice(
            "iPhone 17 Pro Max",
            portrait: .iPhone17ProMax,
            landscape: .iPhone17ProMax(.landscape),
            portraitSize: .init(width: 440, height: 956),
            portraitSafeArea: .init(top: 62, left: 0, bottom: 34, right: 0),
            landscapeSafeArea: .init(top: 20, left: 62, bottom: 20, right: 62),
            landscapeHorizontalSizeClass: .regular
        )
        assertDevice(
            "iPhone Air",
            portrait: .iPhoneAir,
            landscape: .iPhoneAir(.landscape),
            portraitSize: .init(width: 420, height: 912),
            portraitSafeArea: .init(top: 68, left: 0, bottom: 34, right: 0),
            landscapeSafeArea: .init(top: 20, left: 68, bottom: 29, right: 68),
            landscapeHorizontalSizeClass: .regular
        )
        #endif
    }

    func testModernIPadConfigs() async {
        #if os(iOS)
        func assertDevice(
            _ name: String,
            landscape: ViewImageConfig,
            portrait: ViewImageConfig,
            config: (ViewImageConfig.TabletOrientation) -> ViewImageConfig,
            portraitSize: CGSize,
            portraitOneThirdWidth: CGFloat,
            hasRegularHalfWidth: Bool
        ) {
            let landscapeSize = CGSize(width: portraitSize.height, height: portraitSize.width)
            let expected: [(ViewImageConfig.TabletOrientation, CGSize, UIUserInterfaceSizeClass)] = [
                (
                    .landscape(splitView: .oneThird),
                    .init(width: 375, height: portraitSize.width),
                    .compact
                ),
                (
                    .landscape(splitView: .oneHalf),
                    .init(width: (portraitSize.height - 10) / 2, height: portraitSize.width),
                    hasRegularHalfWidth ? .regular : .compact
                ),
                (
                    .landscape(splitView: .twoThirds),
                    .init(width: portraitSize.height - 385, height: portraitSize.width),
                    .regular
                ),
                (.landscape(splitView: .full), landscapeSize, .regular),
                (
                    .portrait(splitView: .oneThird),
                    .init(width: portraitOneThirdWidth, height: portraitSize.height),
                    .compact
                ),
                (
                    .portrait(splitView: .twoThirds),
                    .init(
                        width: portraitSize.width - 10 - portraitOneThirdWidth,
                        height: portraitSize.height
                    ),
                    .compact
                ),
                (.portrait(splitView: .full), portraitSize, .regular)
            ]

            XCTAssertEqual(landscape.size, landscapeSize, name)
            XCTAssertEqual(portrait.size, portraitSize, name)
            for (orientation, size, horizontalSizeClass) in expected {
                let config = config(orientation)
                XCTAssertEqual(config.size, size, name)
                XCTAssertEqual(
                    config.safeArea,
                    .init(top: 24, left: 0, bottom: 20, right: 0),
                    name
                )
                XCTAssertEqual(config.traits.horizontalSizeClass, horizontalSizeClass, name)
                XCTAssertEqual(config.traits.verticalSizeClass, .regular, name)
                XCTAssertEqual(config.traits.userInterfaceIdiom, .pad, name)
            }
        }

        assertDevice(
            "iPad mini (6th generation)",
            landscape: .iPadMini6thGen,
            portrait: .iPadMini6thGen(.portrait),
            config: { .iPadMini6thGen($0) },
            portraitSize: .init(width: 744, height: 1133),
            portraitOneThirdWidth: 320,
            hasRegularHalfWidth: false
        )
        assertDevice(
            "iPad mini (A17 Pro)",
            landscape: .iPadMiniA17Pro,
            portrait: .iPadMiniA17Pro(.portrait),
            config: { .iPadMiniA17Pro($0) },
            portraitSize: .init(width: 744, height: 1133),
            portraitOneThirdWidth: 320,
            hasRegularHalfWidth: false
        )
        assertDevice(
            "iPad (A16)",
            landscape: .iPadA16,
            portrait: .iPadA16(.portrait),
            config: { .iPadA16($0) },
            portraitSize: .init(width: 820, height: 1180),
            portraitOneThirdWidth: 320,
            hasRegularHalfWidth: false
        )
        assertDevice(
            "iPad Air 11-inch",
            landscape: .iPadAir11,
            portrait: .iPadAir11(.portrait),
            config: { .iPadAir11($0) },
            portraitSize: .init(width: 820, height: 1180),
            portraitOneThirdWidth: 320,
            hasRegularHalfWidth: false
        )
        assertDevice(
            "iPad Air 13-inch",
            landscape: .iPadAir13,
            portrait: .iPadAir13(.portrait),
            config: { .iPadAir13($0) },
            portraitSize: .init(width: 1024, height: 1366),
            portraitOneThirdWidth: 375,
            hasRegularHalfWidth: true
        )
        assertDevice(
            "iPad Pro 11-inch (M4)",
            landscape: .iPadPro11M4,
            portrait: .iPadPro11M4(.portrait),
            config: { .iPadPro11M4($0) },
            portraitSize: .init(width: 834, height: 1210),
            portraitOneThirdWidth: 320,
            hasRegularHalfWidth: true
        )
        assertDevice(
            "iPad Pro 11-inch (M5)",
            landscape: .iPadPro11M5,
            portrait: .iPadPro11M5(.portrait),
            config: { .iPadPro11M5($0) },
            portraitSize: .init(width: 834, height: 1210),
            portraitOneThirdWidth: 320,
            hasRegularHalfWidth: true
        )
        assertDevice(
            "iPad Pro 13-inch (M4)",
            landscape: .iPadPro13M4,
            portrait: .iPadPro13M4(.portrait),
            config: { .iPadPro13M4($0) },
            portraitSize: .init(width: 1032, height: 1376),
            portraitOneThirdWidth: 375,
            hasRegularHalfWidth: true
        )
        assertDevice(
            "iPad Pro 13-inch (M5)",
            landscape: .iPadPro13M5,
            portrait: .iPadPro13M5(.portrait),
            config: { .iPadPro13M5($0) },
            portraitSize: .init(width: 1032, height: 1376),
            portraitOneThirdWidth: 375,
            hasRegularHalfWidth: true
        )
        #endif
    }

    func testLegacyIPadConfigsRemainUnchanged() async {
        #if os(iOS)
        XCTAssertEqual(ViewImageConfig.iPadMini.size, .init(width: 1024, height: 768))
        XCTAssertEqual(
            ViewImageConfig.iPadMini.safeArea,
            .init(top: 20, left: 0, bottom: 0, right: 0)
        )
        XCTAssertEqual(ViewImageConfig.iPadPro11.size, .init(width: 1194, height: 834))
        XCTAssertEqual(ViewImageConfig.iPadPro12_9.size, .init(width: 1366, height: 1024))
        #endif
    }

    func testSubclassSnapshottingStrategies() async {
        #if os(macOS)
        final class View: NSView {}
        final class ViewController<Root>: NSViewController {}

        let _: Snapshotting<View, NSImage> = .image
        let _: Snapshotting<View, String> = .recursiveDescription
        let _: Snapshotting<ViewController<Int>, NSImage> = .image
        let _: Snapshotting<ViewController<Int>, String> = .recursiveDescription
        #elseif os(iOS) || os(tvOS)
        final class View: UIView {}
        final class ViewController<Root>: UIViewController {}

        let _: Snapshotting<View, UIImage> = .image
        let _: Snapshotting<View, String> = .recursiveDescription
        let _: Snapshotting<ViewController<Int>, UIImage> = .image
        let _: Snapshotting<ViewController<Int>, String> = .recursiveDescription
        #endif
    }

    func testAny() async {
        struct User { let id: Int, name: String, bio: String }
        let user = User(id: 1, name: "Blobby", bio: "Blobbed around the world.")
        assertSnapshot(of: user, as: .dump)
    }

    func testRecursion() async {
        withSnapshotTesting {
            class Father {
                var child: Child?
                init(_ child: Child? = nil) {
                    self.child = child
                }
            }
            class Child {
                let father: Father
                init(_ father: Father) {
                    self.father = father
                    father.child = self
                }
            }
            let father = Father()
            let child = Child(father)
            assertSnapshot(of: father, as: .dump)
            assertSnapshot(of: child, as: .dump)
        }
    }

    @available(macOS 10.13, tvOS 11.0, *) func testAnyAsJson() async throws {
        struct User: Encodable { let id: Int, name: String, bio: String }
        let user = User(id: 1, name: "Blobby", bio: "Blobbed around the world.")

        let data = try JSONEncoder().encode(user)
        let any = try JSONSerialization.jsonObject(with: data, options: [])

        assertSnapshot(of: any, as: .json)
    }

    func testAnySnapshotStringConvertible() async throws {
        assertSnapshot(of: "a" as Character, as: .dump, named: "character")
        assertSnapshot(of: Data("Hello, world!".utf8), as: .dump, named: "data")
        assertSnapshot(of: Date(timeIntervalSinceReferenceDate: 0), as: .dump, named: "date")
        assertSnapshot(of: NSObject(), as: .dump, named: "nsobject")
        assertSnapshot(of: "Hello, world!", as: .dump, named: "string")
        assertSnapshot(of: "Hello, world!".dropLast(8), as: .dump, named: "substring")
        assertSnapshot(of: try XCTUnwrap(URL(string: "https://www.pointfree.co")), as: .dump, named: "url")
    }

    func testAutolayout() async {
        #if os(iOS)
        let vc = UIViewController()
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        let subview = UIView()
        subview.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(subview)
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: vc.view.topAnchor),
            subview.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),
            subview.leftAnchor.constraint(equalTo: vc.view.leftAnchor),
            subview.rightAnchor.constraint(equalTo: vc.view.rightAnchor)
        ])
        assertSnapshot(of: vc, as: .image)
        #endif
    }

    func testDeterministicDictionaryAndSetSnapshots() async {
        struct Person: Hashable { let name: String }
        struct DictionarySetContainer { let dict: [String: Int], set: Set<Person> }
        let set = DictionarySetContainer(
            dict: ["c": 3, "a": 1, "b": 2],
            set: [.init(name: "Brandon"), .init(name: "Stephen")]
        )
        assertSnapshot(of: set, as: .dump)
    }

    func testCaseIterable() async {
        enum Direction: String, CaseIterable {
            case up, down, left, right
            var rotatedLeft: Direction {
                switch self {
                    case .up: .left
                    case .down: .right
                    case .left: .down
                    case .right: .up
                }
            }
        }

        assertSnapshot(
            of: { $0.rotatedLeft },
            as: Snapshotting<Direction, String>.func(into: .description)
        )
    }

    func testCGPath() async {
        #if os(iOS) || os(tvOS) || os(macOS)
        let path = CGPath.heart

        let osName: String
        #if os(iOS)
        osName = "iOS"
        #elseif os(tvOS)
        osName = "tvOS"
        #elseif os(macOS)
        osName = "macOS"
        #endif

        if !ProcessInfo.processInfo.environment.keys.contains("GITHUB_WORKFLOW") {
            assertSnapshot(of: path, as: .image, named: osName)
        }

        if #available(iOS 11.0, OSX 10.13, tvOS 11.0, *) {
            assertSnapshot(of: path, as: .elementsDescription, named: osName)
        }
        #endif
    }

    func testData() async {
        let data = Data([0xDE, 0xAD, 0xBE, 0xEF])

        assertSnapshot(of: data, as: .data)
    }

    func testEncodable() async {
        struct User: Encodable { let id: Int, name: String, bio: String }
        let user = User(id: 1, name: "Blobby", bio: "Blobbed around the world.")

        if #available(iOS 11.0, macOS 10.13, tvOS 11.0, *) {
            assertSnapshot(of: user, as: .json)
        }
        assertSnapshot(of: user, as: .plist)
    }

    func testPropertyListCodersAreFoundationTypes() {
        XCTAssertTrue(SnapshotTesting.PropertyListEncoder.self == Foundation.PropertyListEncoder.self)
        XCTAssertTrue(SnapshotTesting.PropertyListDecoder.self == Foundation.PropertyListDecoder.self)
    }

    #if os(Linux) || os(tvOS) || os(watchOS)
    func testMixedViews() async {}
    #else
    func testMixedViews() {
        // NB: CircleCI crashes while trying to instantiate SKView.
        if !ProcessInfo.processInfo.environment.keys.contains("GITHUB_WORKFLOW") {
            let webView = WKWebView(frame: .init(x: 0, y: 0, width: 50, height: 50))
            webView.loadHTMLString("🌎", baseURL: nil)

            let skView = SKView(frame: .init(x: 50, y: 0, width: 50, height: 50))
            let scene = SKScene(size: .init(width: 50, height: 50))
            let node = SKShapeNode(circleOfRadius: 15)
            node.fillColor = .red
            node.position = .init(x: 25, y: 25)
            scene.addChild(node)
            skView.presentScene(scene)

            let view = View(frame: .init(x: 0, y: 0, width: 100, height: 50))
            view.addSubview(webView)
            view.addSubview(skView)

            assertSnapshot(of: view, as: .image, named: platform)
        }
    }
    #endif

    func testMultipleSnapshots() async {
        assertSnapshot(of: [1], as: .dump)
        assertSnapshot(of: [1, 2], as: .dump)
    }

    func testNamedAssertion() async {
        struct User { let id: Int, name: String, bio: String }
        let user = User(id: 1, name: "Blobby", bio: "Blobbed around the world.")
        assertSnapshot(of: user, as: .dump, named: "named")
    }

    func testNSBezierPath() async {
        #if os(macOS)
        let path = NSBezierPath.heart

        if !ProcessInfo.processInfo.environment.keys.contains("GITHUB_WORKFLOW") {
            assertSnapshot(of: path, as: .image, named: "macOS")
        }

        assertSnapshot(of: path, as: .elementsDescription, named: "macOS")
        #endif
    }

    func testNSView() async {
        #if os(macOS)
        let button = NSButton()
        button.bezelStyle = .rounded
        button.title = "Push Me"
        button.sizeToFit()
        if !ProcessInfo.processInfo.environment.keys.contains("GITHUB_WORKFLOW") {
            assertSnapshot(of: button, as: .image)
            assertSnapshot(of: button, as: .recursiveDescription)
        }
        #endif
    }

    func testNSViewWithLayer() async {
        #if os(macOS)
        let view = NSView()
        view.frame = CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0)
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.green.cgColor
        view.layer?.cornerRadius = 5
        if !ProcessInfo.processInfo.environment.keys.contains("GITHUB_WORKFLOW") {
            assertSnapshot(of: view, as: .image)
            assertSnapshot(of: view, as: .recursiveDescription)
        }
        #endif
    }

    func testSnapshotImageRunsOnMainThread() async {
        #if os(macOS)
        _ = snapshotImage(size: CGSize(width: 1, height: 1)) {
            XCTAssertTrue(Thread.isMainThread)
        }
        #endif
    }

    func testPrecision() async {
        #if os(iOS) || os(macOS) || os(tvOS)
        #if os(iOS) || os(tvOS)
        let label = UILabel()
        #if os(iOS)
        label.frame = CGRect(origin: .zero, size: CGSize(width: 43.5, height: 20.5))
        #elseif os(tvOS)
        label.frame = CGRect(origin: .zero, size: CGSize(width: 98, height: 46))
        #endif
        label.backgroundColor = .white
        #elseif os(macOS)
        let label = NSTextField()
        label.frame = CGRect(origin: .zero, size: CGSize(width: 37, height: 16))
        label.backgroundColor = .white
        label.isBezeled = false
        label.isEditable = false
        #endif
        if !ProcessInfo.processInfo.environment.keys.contains("GITHUB_WORKFLOW") {
            label.text = "Hello."
            assertSnapshot(of: label, as: .image(options: .init(precision: 0.9)), named: platform)
            label.text = "Hello"
            assertSnapshot(of: label, as: .image(options: .init(precision: 0.9)), named: platform)
        }
        #endif
    }

    func testImagePrecision() async throws {
        #if os(iOS) || os(tvOS) || os(macOS)
        let imageURL = URL(fileURLWithPath: String(#filePath), isDirectory: false)
            .deletingLastPathComponent()
            .appendingPathComponent("__Fixtures__/testImagePrecision.reference.png")
        #if os(iOS) || os(tvOS)
        let image = try XCTUnwrap(UIImage(contentsOfFile: imageURL.path))
        #elseif os(macOS)
        let image = try XCTUnwrap(NSImage(byReferencing: imageURL))
        #endif

        assertSnapshot(
            of: image,
            as: .image(options: .init(precision: 0.995)),
            named: "\(platform)-exact"
        )
        if #available(iOS 11.0, tvOS 11.0, macOS 10.13, *) {
            assertSnapshot(
                of: image,
                as: .image(options: .init(perceptualPrecision: 0.98)),
                named: "\(platform)-perceptual"
            )
        }
        #endif
    }

    func testMacOSImageColorSpacesAreNormalized() async throws {
        #if os(macOS)
        func image(
            in colorSpace: CGColorSpace,
            filledWith color: CGColor,
            differingPixelColor: CGColor? = nil
        ) throws -> NSImage {
            let size = CGSize(width: 16, height: 16)
            let context = try XCTUnwrap(
                CGContext(
                    data: nil,
                    width: Int(size.width),
                    height: Int(size.height),
                    bitsPerComponent: 8,
                    bytesPerRow: Int(size.width) * 4,
                    space: colorSpace,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                )
            )
            context.setFillColor(color)
            context.fill(CGRect(origin: .zero, size: size))
            if let differingPixelColor {
                context.setFillColor(differingPixelColor)
                context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            }
            return NSImage(cgImage: try XCTUnwrap(context.makeImage()), size: size)
        }

        let sRGB = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let displayP3 = try XCTUnwrap(CGColorSpace(name: CGColorSpace.displayP3))
        let color = try XCTUnwrap(
            CGColor(colorSpace: sRGB, components: [1, 0, 0, 1])
        )
        let similarColor = try XCTUnwrap(
            CGColor(colorSpace: sRGB, components: [0.995, 0, 0, 1])
        )
        let sRGBImage = try image(in: sRGB, filledWith: color)
        let displayP3Image = try image(in: displayP3, filledWith: color)
        let similarDisplayP3Image = try image(in: displayP3, filledWith: similarColor)
        let oneDifferentPixelImage = try image(
            in: displayP3,
            filledWith: color,
            differingPixelColor: similarColor
        )

        XCTAssertNil(Diffing<NSImage>.image.diffV2(sRGBImage, displayP3Image))
        XCTAssertNil(
            Diffing<NSImage>.image(options: .init(perceptualPrecision: 0.99))
                .diffV2(sRGBImage, similarDisplayP3Image)
        )
        XCTAssertNil(
            Diffing<NSImage>.image(options: .init(precision: 0.99))
                .diffV2(sRGBImage, oneDifferentPixelImage)
        )
        #endif
    }

    func testImageDiffWithDifferentPixelFormats() async throws {
        #if os(iOS) || os(tvOS)
        let width = 256
        let height = 256
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let referenceData = Data(repeating: 255, count: width * height * 3)
        let referenceProvider = try XCTUnwrap(CGDataProvider(data: referenceData as CFData))
        let referenceCgImage = try XCTUnwrap(
            CGImage(
                width: width,
                height: height,
                bitsPerComponent: 8,
                bitsPerPixel: 24,
                bytesPerRow: width * 3,
                space: colorSpace,
                bitmapInfo: [],
                provider: referenceProvider,
                decode: nil,
                shouldInterpolate: false,
                intent: .defaultIntent
            )
        )
        let failureData = Data(repeating: 0, count: width * height * 4)
        let failureProvider = try XCTUnwrap(CGDataProvider(data: failureData as CFData))
        let failureCgImage = try XCTUnwrap(
            CGImage(
                width: width,
                height: height,
                bitsPerComponent: 8,
                bitsPerPixel: 32,
                bytesPerRow: width * 4,
                space: colorSpace,
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                provider: failureProvider,
                decode: nil,
                shouldInterpolate: false,
                intent: .defaultIntent
            )
        )

        let difference = Diffing<UIImage>.image.diffV2(
            UIImage(cgImage: referenceCgImage),
            UIImage(cgImage: failureCgImage)
        )

        XCTAssertEqual(difference?.0, "Newly-taken snapshot does not match reference.")
        XCTAssertEqual(difference?.1.count, 3)
        #endif
    }

    func testLandscapeImageDiffOrientation() async throws {
        #if os(iOS)
        func image(
            color: CGColor,
            differingPixelColor: CGColor? = nil,
            orientation: UIImage.Orientation
        ) throws -> UIImage {
            let context = try XCTUnwrap(
                CGContext(
                    data: nil,
                    width: 2,
                    height: 3,
                    bitsPerComponent: 8,
                    bytesPerRow: 8,
                    space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                )
            )
            context.setFillColor(color)
            context.fill(CGRect(x: 0, y: 0, width: 2, height: 3))
            if let differingPixelColor {
                context.setFillColor(differingPixelColor)
                context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            }
            return UIImage(
                cgImage: try XCTUnwrap(context.makeImage()),
                scale: 1,
                orientation: orientation
            )
        }

        let reference = try image(color: UIColor.red.cgColor, orientation: .up)
        let matchingLandscape = try image(color: UIColor.red.cgColor, orientation: .right)
        let failure = try image(
            color: UIColor.red.cgColor,
            differingPixelColor: UIColor.blue.cgColor,
            orientation: .right
        )

        XCTAssertNil(Diffing<UIImage>.image(scale: 1).diffV2(reference, matchingLandscape))
        let result = try XCTUnwrap(
            Diffing<UIImage>.image(scale: 1).diffV2(reference, failure)
        )

        XCTAssertEqual(result.0, "Newly-taken snapshot does not match reference.")
        guard case let .data(referenceData, referenceName) = result.1[0],
              case let .data(differenceData, differenceName) = result.1[2] else {
            return XCTFail("Expected image data attachments.")
        }
        XCTAssertEqual(referenceName, "reference.png")
        XCTAssertEqual(differenceName, "difference.png")
        let attachedReference = try XCTUnwrap(UIImage(data: referenceData, scale: 1))
        let difference = try XCTUnwrap(UIImage(data: differenceData, scale: 1))
        XCTAssertEqual(attachedReference.size, CGSize(width: 3, height: 2))
        XCTAssertEqual(difference.size, CGSize(width: 3, height: 2))

        let renderedDiffing = Diffing<UIImage>.image(
            scale: 1,
            orientationComparison: .rendered
        )
        let orientationResult = try XCTUnwrap(
            renderedDiffing.diffV2(reference, matchingLandscape)
        )
        guard case let .data(renderedReferenceData, _) = orientationResult.1[0],
              case let .data(renderedFailureData, _) = orientationResult.1[1] else {
            return XCTFail("Expected rendered image data attachments.")
        }
        let renderedReference = try XCTUnwrap(UIImage(data: renderedReferenceData, scale: 1))
        let renderedFailure = try XCTUnwrap(UIImage(data: renderedFailureData, scale: 1))
        XCTAssertEqual(renderedReference.imageOrientation, .up)
        XCTAssertEqual(renderedReference.size, CGSize(width: 2, height: 3))
        XCTAssertEqual(renderedFailure.imageOrientation, .up)
        XCTAssertEqual(renderedFailure.size, CGSize(width: 3, height: 2))

        let persistedReference = try XCTUnwrap(
            renderedDiffing.fromData(renderedDiffing.toData(matchingLandscape))
        )
        XCTAssertEqual(persistedReference.imageOrientation, .up)
        XCTAssertNil(renderedDiffing.diffV2(persistedReference, matchingLandscape))

        let renderedSnapshotting = Snapshotting<UIImage, UIImage>.image(
            scale: 1,
            orientationComparison: .rendered
        )
        XCTAssertNotNil(renderedSnapshotting.diffing.diffV2(reference, matchingLandscape))
        #endif
    }

    func testUIImageColorSpacesAreNormalized() async throws {
        #if os(iOS) || os(tvOS)
        func image(
            in colorSpace: CGColorSpace,
            filledWith color: CGColor,
            differingPixelColor: CGColor? = nil
        ) throws -> UIImage {
            let size = CGSize(width: 16, height: 16)
            let context = try XCTUnwrap(
                CGContext(
                    data: nil,
                    width: Int(size.width),
                    height: Int(size.height),
                    bitsPerComponent: 8,
                    bytesPerRow: Int(size.width) * 4,
                    space: colorSpace,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                )
            )
            context.setFillColor(color)
            context.fill(CGRect(origin: .zero, size: size))
            if let differingPixelColor {
                context.setFillColor(differingPixelColor)
                context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            }
            return UIImage(cgImage: try XCTUnwrap(context.makeImage()))
        }

        let sRGB = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let displayP3 = try XCTUnwrap(CGColorSpace(name: CGColorSpace.displayP3))
        let red = try XCTUnwrap(CGColor(colorSpace: sRGB, components: [1, 0, 0, 1]))
        let similarRed = try XCTUnwrap(
            CGColor(colorSpace: sRGB, components: [0.995, 0, 0, 1])
        )
        let sRGBImage = try image(in: sRGB, filledWith: red)
        let displayP3Image = try image(in: displayP3, filledWith: red)
        let similarDisplayP3Image = try image(
            in: displayP3,
            filledWith: red,
            differingPixelColor: similarRed
        )

        XCTAssertNil(Diffing<UIImage>.image(scale: 1).diffV2(sRGBImage, displayP3Image))
        XCTAssertNil(
            Diffing<UIImage>.image(
                precision: 0.99,
                perceptualPrecision: 0.99,
                scale: 1
            ).diffV2(sRGBImage, similarDisplayP3Image)
        )

        let renderedImage = renderer(
            bounds: CGRect(origin: .zero, size: CGSize(width: 1, height: 1)),
            for: UITraitCollection(displayGamut: .P3)
        ).image { context in
            context.cgContext.setFillColor(red)
            context.cgContext.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        XCTAssertEqual(renderedImage.cgImage?.colorSpace?.name, CGColorSpace.sRGB as CFString)
        #endif
    }

    func testOpaqueImageSnapshots() async throws {
        #if os(iOS) || os(macOS) || os(tvOS)
        func hasAlpha(_ image: CGImage) -> Bool {
            switch image.alphaInfo {
                case .none,
                     .noneSkipFirst,
                     .noneSkipLast:
                    false
                default:
                    true
            }
        }

        func pixel(_ image: CGImage) throws -> [UInt8] {
            var bytes = [UInt8](repeating: 0, count: 4)
            let context = try XCTUnwrap(
                CGContext(
                    data: &bytes,
                    width: 1,
                    height: 1,
                    bitsPerComponent: 8,
                    bytesPerRow: 4,
                    space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                )
            )
            context.draw(image, in: CGRect(x: 0, y: 0, width: 1, height: 1))
            return bytes
        }

        func assertWhiteComposite(_ image: CGImage) throws {
            let components = try pixel(image)
            XCTAssertEqual(components[0], 255)
            XCTAssertTrue((127 ... 139).contains(components[1]), "\(components)")
            XCTAssertTrue((127 ... 139).contains(components[2]), "\(components)")
            XCTAssertEqual(components[3], 255)
        }
        #endif

        #if os(iOS) || os(tvOS)
        func capture<Value>(_ value: Value, as strategy: Snapshotting<Value, UIImage>) async
            -> UIImage {
            await withCheckedContinuation { continuation in
                strategy.snapshot(value).run { continuation.resume(returning: $0) }
            }
        }

        let size = CGSize(width: 2, height: 2)
        let transparentView = UIView(frame: CGRect(origin: .zero, size: size))
        let defaultStrategy = Snapshotting<UIView, UIImage>.image(size: size)
        let opaqueStrategy = Snapshotting<UIView, UIImage>.image(size: size, isOpaque: true)
        let defaultImage = await capture(transparentView, as: defaultStrategy)
        let opaqueImage = await capture(transparentView, as: opaqueStrategy)
        let decodedOpaqueImage = try XCTUnwrap(
            UIImage(data: opaqueStrategy.diffing.toData(opaqueImage))
        )

        XCTAssertTrue(hasAlpha(try XCTUnwrap(defaultImage.cgImage)))
        XCTAssertFalse(hasAlpha(try XCTUnwrap(decodedOpaqueImage.cgImage)))

        XCTAssertEqual(try pixel(XCTUnwrap(decodedOpaqueImage.cgImage)), [255, 255, 255, 255])

        let directStrategy = Snapshotting<UIImage, UIImage>.image(isOpaque: true)
        let translucentImage = UIGraphicsImageRenderer(size: size).image { _ in
            UIColor(red: 1, green: 0, blue: 0, alpha: 0.5).setFill()
            UIRectFill(CGRect(origin: .zero, size: size))
        }
        let directImage = await capture(translucentImage, as: directStrategy)
        XCTAssertFalse(hasAlpha(try XCTUnwrap(directImage.cgImage)))
        try assertWhiteComposite(XCTUnwrap(directImage.cgImage))

        let ciImage = CIImage(
            color: CIColor(red: 0, green: 0, blue: 1, alpha: 0.5)
        ).cropped(to: CGRect(origin: .zero, size: size))
        let ciBackedImage = UIImage(ciImage: ciImage)
        XCTAssertNil(ciBackedImage.cgImage)
        let opaqueCIImage = await capture(ciBackedImage, as: directStrategy)
        XCTAssertFalse(hasAlpha(try XCTUnwrap(opaqueCIImage.cgImage)))
        #elseif os(macOS)
        func capture<Value>(_ value: Value, as strategy: Snapshotting<Value, NSImage>) async
            -> NSImage {
            await withCheckedContinuation { continuation in
                strategy.snapshot(value).run { continuation.resume(returning: $0) }
            }
        }

        let size = CGSize(width: 2, height: 2)
        let transparentView = NSView(frame: CGRect(origin: .zero, size: size))
        let defaultStrategy = Snapshotting<NSView, NSImage>.image(size: size)
        let opaqueStrategy = Snapshotting<NSView, NSImage>.image(size: size, isOpaque: true)
        let defaultImage = await capture(transparentView, as: defaultStrategy)
        let opaqueImage = await capture(transparentView, as: opaqueStrategy)
        let opaqueData = opaqueStrategy.diffing.toData(opaqueImage)
        let decodedOpaqueImage = try XCTUnwrap(NSImage(data: opaqueData))

        XCTAssertTrue(
            hasAlpha(
                try XCTUnwrap(defaultImage.cgImage(forProposedRect: nil, context: nil, hints: nil))
            )
        )
        XCTAssertFalse(
            hasAlpha(
                try XCTUnwrap(decodedOpaqueImage.cgImage(forProposedRect: nil, context: nil, hints: nil))
            )
        )

        XCTAssertEqual(
            try pixel(
                XCTUnwrap(decodedOpaqueImage.cgImage(forProposedRect: nil, context: nil, hints: nil))
            ),
            [255, 255, 255, 255]
        )

        let directStrategy = Snapshotting<NSImage, NSImage>.image(isOpaque: true)
        let translucentImage = NSImage(size: size)
        translucentImage.lockFocus()
        NSColor(red: 1, green: 0, blue: 0, alpha: 0.5).setFill()
        NSBezierPath(rect: CGRect(origin: .zero, size: size)).fill()
        translucentImage.unlockFocus()
        let directImage = await capture(translucentImage, as: directStrategy)
        let directCGImage = try XCTUnwrap(
            directImage.cgImage(forProposedRect: nil, context: nil, hints: nil)
        )
        XCTAssertFalse(hasAlpha(directCGImage))
        try assertWhiteComposite(directCGImage)
        #endif
    }

    func testSCNView() async {
        #if os(iOS) || os(macOS) || os(tvOS)
        // NB: CircleCI crashes while trying to instantiate SCNView.
        if !ProcessInfo.processInfo.environment.keys.contains("GITHUB_WORKFLOW") {
            let scene = SCNScene()

            let sphereGeometry = SCNSphere(radius: 3)
            sphereGeometry.segmentCount = 200
            let sphereNode = SCNNode(geometry: sphereGeometry)
            sphereNode.position = SCNVector3Zero
            scene.rootNode.addChildNode(sphereNode)

            sphereGeometry.firstMaterial?.diffuse.contents = URL(fileURLWithPath: String(#filePath), isDirectory: false)
                .deletingLastPathComponent()
                .appendingPathComponent("__Fixtures__/earth.png")

            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.position = SCNVector3Make(0, 0, 8)
            scene.rootNode.addChildNode(cameraNode)

            let omniLight = SCNLight()
            omniLight.type = .omni
            let omniLightNode = SCNNode()
            omniLightNode.light = omniLight
            omniLightNode.position = SCNVector3Make(10, 10, 10)
            scene.rootNode.addChildNode(omniLightNode)

            assertSnapshot(
                of: scene,
                as: .image(size: .init(width: 500, height: 500)),
                named: platform
            )
        }
        #endif
    }

    func testSKView() async {
        #if os(iOS) || os(macOS) || os(tvOS)
        // NB: CircleCI crashes while trying to instantiate SKView.
        if !ProcessInfo.processInfo.environment.keys.contains("GITHUB_WORKFLOW") {
            let scene = SKScene(size: .init(width: 50, height: 50))
            let node = SKShapeNode(circleOfRadius: 15)
            node.fillColor = .red
            node.position = .init(x: 25, y: 25)
            scene.addChild(node)

            assertSnapshot(
                of: scene,
                as: .image(size: .init(width: 50, height: 50)),
                named: platform
            )
        }
        #endif
    }

    func testTableViewController() async {
        #if os(iOS)
        class TableViewController: UITableViewController {
            override func viewDidLoad() {
                super.viewDidLoad()
                self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
            }

            override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                10
            }

            override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
                -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                cell.textLabel?.text = "\(indexPath.row)"
                return cell
            }
        }
        let tableViewController = TableViewController()
        assertSnapshot(of: tableViewController, as: .image(on: .iPhoneSe))
        #endif
    }

    func testAssertMultipleSnapshot() async {
        #if os(iOS)
        class TableViewController: UITableViewController {
            override func viewDidLoad() {
                super.viewDidLoad()
                self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
            }

            override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                10
            }

            override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
                -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                cell.textLabel?.text = "\(indexPath.row)"
                return cell
            }
        }
        let tableViewController = TableViewController()
        assertSnapshots(
            of: tableViewController,
            as: ["iPhoneSE-image": .image(on: .iPhoneSe), "iPad-image": .image(on: .iPadMini)]
        )
        assertSnapshots(
            of: tableViewController, as: [.image(on: .iPhoneX), .image(on: .iPhoneXsMax)]
        )
        #endif
    }

    func testTraits() async {
        #if os(iOS) || os(tvOS)
        if #available(iOS 11.0, tvOS 11.0, *) {
            class MyViewController: UIViewController {
                let topLabel = UILabel()
                let leadingLabel = UILabel()
                let trailingLabel = UILabel()
                let bottomLabel = UILabel()

                override func viewDidLoad() {
                    super.viewDidLoad()

                    self.navigationItem.leftBarButtonItem = .init(
                        barButtonSystemItem: .add, target: nil, action: nil
                    )

                    self.view.backgroundColor = .white

                    self.topLabel.text = "What's"
                    self.leadingLabel.text = "the"
                    self.trailingLabel.text = "point"
                    self.bottomLabel.text = "?"

                    self.topLabel.translatesAutoresizingMaskIntoConstraints = false
                    self.leadingLabel.translatesAutoresizingMaskIntoConstraints = false
                    self.trailingLabel.translatesAutoresizingMaskIntoConstraints = false
                    self.bottomLabel.translatesAutoresizingMaskIntoConstraints = false

                    self.view.addSubview(self.topLabel)
                    self.view.addSubview(self.leadingLabel)
                    self.view.addSubview(self.trailingLabel)
                    self.view.addSubview(self.bottomLabel)

                    NSLayoutConstraint.activate([
                        self.topLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
                        self.topLabel.centerXAnchor.constraint(
                            equalTo: self.view.safeAreaLayoutGuide.centerXAnchor
                        ),
                        self.leadingLabel.leadingAnchor.constraint(
                            equalTo: self.view.safeAreaLayoutGuide.leadingAnchor
                        ),
                        self.leadingLabel.trailingAnchor.constraint(
                            lessThanOrEqualTo: self.view.safeAreaLayoutGuide.centerXAnchor
                        ),
                        //            self.leadingLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
                        self.leadingLabel.centerYAnchor.constraint(
                            equalTo: self.view.safeAreaLayoutGuide.centerYAnchor
                        ),
                        self.trailingLabel.leadingAnchor.constraint(
                            greaterThanOrEqualTo: self.view.safeAreaLayoutGuide.centerXAnchor
                        ),
                        self.trailingLabel.trailingAnchor.constraint(
                            equalTo: self.view.safeAreaLayoutGuide.trailingAnchor
                        ),
                        self.trailingLabel.centerYAnchor.constraint(
                            equalTo: self.view.safeAreaLayoutGuide.centerYAnchor
                        ),
                        self.bottomLabel.bottomAnchor.constraint(
                            equalTo: self.view.safeAreaLayoutGuide.bottomAnchor
                        ),
                        self.bottomLabel.centerXAnchor.constraint(
                            equalTo: self.view.safeAreaLayoutGuide.centerXAnchor
                        )
                    ])

                    self.registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (viewController: MyViewController, _) in
                        viewController.updateFonts()
                    }
                    self.updateFonts()
                }

                private func updateFonts() {
                    self.topLabel.font = .preferredFont(
                        forTextStyle: .headline, compatibleWith: self.traitCollection
                    )
                    self.leadingLabel.font = .preferredFont(
                        forTextStyle: .body, compatibleWith: self.traitCollection
                    )
                    self.trailingLabel.font = .preferredFont(
                        forTextStyle: .body, compatibleWith: self.traitCollection
                    )
                    self.bottomLabel.font = .preferredFont(
                        forTextStyle: .subheadline, compatibleWith: self.traitCollection
                    )
                    self.view.setNeedsUpdateConstraints()
                    self.view.updateConstraintsIfNeeded()
                }
            }

            let viewController = MyViewController()

            #if os(iOS)
            assertSnapshot(of: viewController, as: .image(on: .iPhoneSe), named: "iphone-se")
            assertSnapshot(of: viewController, as: .image(on: .iPhone8), named: "iphone-8")
            assertSnapshot(of: viewController, as: .image(on: .iPhone8Plus), named: "iphone-8-plus")
            assertSnapshot(of: viewController, as: .image(on: .iPhoneX), named: "iphone-x")
            assertSnapshot(of: viewController, as: .image(on: .iPhoneXr), named: "iphone-xr")
            assertSnapshot(of: viewController, as: .image(on: .iPhoneXsMax), named: "iphone-xs-max")
            assertSnapshot(of: viewController, as: .image(on: .iPadMini), named: "ipad-mini")
            assertSnapshot(of: viewController, as: .image(on: .iPad9_7), named: "ipad-9-7")
            assertSnapshot(of: viewController, as: .image(on: .iPad10_2), named: "ipad-10-2")
            assertSnapshot(of: viewController, as: .image(on: .iPadPro10_5), named: "ipad-pro-10-5")
            assertSnapshot(of: viewController, as: .image(on: .iPadPro11), named: "ipad-pro-11")
            assertSnapshot(of: viewController, as: .image(on: .iPadPro12_9), named: "ipad-pro-12-9")

            assertSnapshot(
                of: viewController, as: .recursiveDescription(on: .iPhoneSe), named: "iphone-se"
            )
            assertSnapshot(
                of: viewController, as: .recursiveDescription(on: .iPhone8), named: "iphone-8"
            )
            assertSnapshot(
                of: viewController, as: .recursiveDescription(on: .iPhone8Plus), named: "iphone-8-plus"
            )
            assertSnapshot(
                of: viewController, as: .recursiveDescription(on: .iPhoneX), named: "iphone-x"
            )
            assertSnapshot(
                of: viewController, as: .recursiveDescription(on: .iPhoneXr), named: "iphone-xr"
            )
            assertSnapshot(
                of: viewController, as: .recursiveDescription(on: .iPhoneXsMax), named: "iphone-xs-max"
            )
            assertSnapshot(
                of: viewController, as: .recursiveDescription(on: .iPadMini), named: "ipad-mini"
            )
            assertSnapshot(
                of: viewController, as: .recursiveDescription(on: .iPad9_7), named: "ipad-9-7"
            )
            assertSnapshot(
                of: viewController, as: .recursiveDescription(on: .iPad10_2), named: "ipad-10-2"
            )
            assertSnapshot(
                of: viewController, as: .recursiveDescription(on: .iPadPro10_5), named: "ipad-pro-10-5"
            )
            assertSnapshot(
                of: viewController, as: .recursiveDescription(on: .iPadPro11), named: "ipad-pro-11"
            )
            assertSnapshot(
                of: viewController, as: .recursiveDescription(on: .iPadPro12_9), named: "ipad-pro-12-9"
            )

            assertSnapshot(
                of: viewController, as: .image(on: .iPhoneSe(.portrait)), named: "iphone-se"
            )
            assertSnapshot(of: viewController, as: .image(on: .iPhone8(.portrait)), named: "iphone-8")
            assertSnapshot(
                of: viewController, as: .image(on: .iPhone8Plus(.portrait)), named: "iphone-8-plus"
            )
            assertSnapshot(of: viewController, as: .image(on: .iPhoneX(.portrait)), named: "iphone-x")
            assertSnapshot(
                of: viewController, as: .image(on: .iPhoneXr(.portrait)), named: "iphone-xr"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPhoneXsMax(.portrait)), named: "iphone-xs-max"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadMini(.landscape)), named: "ipad-mini"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPad9_7(.landscape)), named: "ipad-9-7"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPad10_2(.landscape)), named: "ipad-10-2"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadPro10_5(.landscape)), named: "ipad-pro-10-5"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadPro11(.landscape)), named: "ipad-pro-11"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadPro12_9(.landscape)), named: "ipad-pro-12-9"
            )

            assertSnapshot(
                of: viewController, as: .image(on: .iPadMini(.landscape(splitView: .oneThird))),
                named: "ipad-mini-33-split-landscape"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadMini(.landscape(splitView: .oneHalf))),
                named: "ipad-mini-50-split-landscape"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadMini(.landscape(splitView: .twoThirds))),
                named: "ipad-mini-66-split-landscape"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadMini(.portrait(splitView: .oneThird))),
                named: "ipad-mini-33-split-portrait"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadMini(.portrait(splitView: .twoThirds))),
                named: "ipad-mini-66-split-portrait"
            )

            assertSnapshot(
                of: viewController, as: .image(on: .iPad9_7(.landscape(splitView: .oneThird))),
                named: "ipad-9-7-33-split-landscape"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPad9_7(.landscape(splitView: .oneHalf))),
                named: "ipad-9-7-50-split-landscape"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPad9_7(.landscape(splitView: .twoThirds))),
                named: "ipad-9-7-66-split-landscape"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPad9_7(.portrait(splitView: .oneThird))),
                named: "ipad-9-7-33-split-portrait"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPad9_7(.portrait(splitView: .twoThirds))),
                named: "ipad-9-7-66-split-portrait"
            )

            assertSnapshot(
                of: viewController, as: .image(on: .iPad10_2(.landscape(splitView: .oneThird))),
                named: "ipad-10-2-split-landscape"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPad10_2(.landscape(splitView: .oneHalf))),
                named: "ipad-10-2-50-split-landscape"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPad10_2(.landscape(splitView: .twoThirds))),
                named: "ipad-10-2-66-split-landscape"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPad10_2(.portrait(splitView: .oneThird))),
                named: "ipad-10-2-33-split-portrait"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPad10_2(.portrait(splitView: .twoThirds))),
                named: "ipad-10-2-66-split-portrait"
            )

            assertSnapshot(
                of: viewController, as: .image(on: .iPadPro10_5(.landscape(splitView: .oneThird))),
                named: "ipad-pro-10inch-33-split-landscape"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadPro10_5(.landscape(splitView: .oneHalf))),
                named: "ipad-pro-10inch-50-split-landscape"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadPro10_5(.landscape(splitView: .twoThirds))),
                named: "ipad-pro-10inch-66-split-landscape"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadPro10_5(.portrait(splitView: .oneThird))),
                named: "ipad-pro-10inch-33-split-portrait"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadPro10_5(.portrait(splitView: .twoThirds))),
                named: "ipad-pro-10inch-66-split-portrait"
            )

            assertSnapshot(
                of: viewController, as: .image(on: .iPadPro11(.landscape(splitView: .oneThird))),
                named: "ipad-pro-11inch-33-split-landscape"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadPro11(.landscape(splitView: .oneHalf))),
                named: "ipad-pro-11inch-50-split-landscape"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadPro11(.landscape(splitView: .twoThirds))),
                named: "ipad-pro-11inch-66-split-landscape"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadPro11(.portrait(splitView: .oneThird))),
                named: "ipad-pro-11inch-33-split-portrait"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadPro11(.portrait(splitView: .twoThirds))),
                named: "ipad-pro-11inch-66-split-portrait"
            )

            assertSnapshot(
                of: viewController, as: .image(on: .iPadPro12_9(.landscape(splitView: .oneThird))),
                named: "ipad-pro-12inch-33-split-landscape"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadPro12_9(.landscape(splitView: .oneHalf))),
                named: "ipad-pro-12inch-50-split-landscape"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadPro12_9(.landscape(splitView: .twoThirds))),
                named: "ipad-pro-12inch-66-split-landscape"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadPro12_9(.portrait(splitView: .oneThird))),
                named: "ipad-pro-12inch-33-split-portrait"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadPro12_9(.portrait(splitView: .twoThirds))),
                named: "ipad-pro-12inch-66-split-portrait"
            )

            assertSnapshot(
                of: viewController, as: .image(on: .iPhoneSe(.landscape)),
                named: "iphone-se-alternative"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPhone8(.landscape)), named: "iphone-8-alternative"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPhone8Plus(.landscape)),
                named: "iphone-8-plus-alternative"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPhoneX(.landscape)), named: "iphone-x-alternative"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPhoneXr(.landscape)),
                named: "iphone-xr-alternative"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPhoneXsMax(.landscape)),
                named: "iphone-xs-max-alternative"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadMini(.portrait)), named: "ipad-mini-alternative"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPad9_7(.portrait)), named: "ipad-9-7-alternative"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPad10_2(.portrait)), named: "ipad-10-2-alternative"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadPro10_5(.portrait)),
                named: "ipad-pro-10-5-alternative"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadPro11(.portrait)),
                named: "ipad-pro-11-alternative"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadPro12_9(.portrait)),
                named: "ipad-pro-12-9-alternative"
            )

            for (name, contentSize) in allContentSizes {
                assertSnapshot(
                    of: viewController,
                    as: .image(on: .iPhoneSe, traits: .init(preferredContentSizeCategory: contentSize)),
                    named: "iphone-se-\(name)"
                )
            }
            #elseif os(tvOS)
            assertSnapshot(
                of: viewController, as: .image(on: .tv), named: "tv"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .tv4K), named: "tv4k"
            )
            #endif
        }
        #endif
    }

    func testTraitsEmbeddedInTabNavigation() async {
        #if os(iOS)
        if #available(iOS 11.0, *) {
            class MyViewController: UIViewController {
                let topLabel = UILabel()
                let leadingLabel = UILabel()
                let trailingLabel = UILabel()
                let bottomLabel = UILabel()

                override func viewDidLoad() {
                    super.viewDidLoad()

                    self.navigationItem.leftBarButtonItem = .init(
                        barButtonSystemItem: .add, target: nil, action: nil
                    )

                    self.view.backgroundColor = .white

                    self.topLabel.text = "What's"
                    self.leadingLabel.text = "the"
                    self.trailingLabel.text = "point"
                    self.bottomLabel.text = "?"

                    self.topLabel.translatesAutoresizingMaskIntoConstraints = false
                    self.leadingLabel.translatesAutoresizingMaskIntoConstraints = false
                    self.trailingLabel.translatesAutoresizingMaskIntoConstraints = false
                    self.bottomLabel.translatesAutoresizingMaskIntoConstraints = false

                    self.view.addSubview(self.topLabel)
                    self.view.addSubview(self.leadingLabel)
                    self.view.addSubview(self.trailingLabel)
                    self.view.addSubview(self.bottomLabel)

                    NSLayoutConstraint.activate([
                        self.topLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
                        self.topLabel.centerXAnchor.constraint(
                            equalTo: self.view.safeAreaLayoutGuide.centerXAnchor
                        ),
                        self.leadingLabel.leadingAnchor.constraint(
                            equalTo: self.view.safeAreaLayoutGuide.leadingAnchor
                        ),
                        self.leadingLabel.trailingAnchor.constraint(
                            lessThanOrEqualTo: self.view.safeAreaLayoutGuide.centerXAnchor
                        ),
                        //            self.leadingLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
                        self.leadingLabel.centerYAnchor.constraint(
                            equalTo: self.view.safeAreaLayoutGuide.centerYAnchor
                        ),
                        self.trailingLabel.leadingAnchor.constraint(
                            greaterThanOrEqualTo: self.view.safeAreaLayoutGuide.centerXAnchor
                        ),
                        self.trailingLabel.trailingAnchor.constraint(
                            equalTo: self.view.safeAreaLayoutGuide.trailingAnchor
                        ),
                        self.trailingLabel.centerYAnchor.constraint(
                            equalTo: self.view.safeAreaLayoutGuide.centerYAnchor
                        ),
                        self.bottomLabel.bottomAnchor.constraint(
                            equalTo: self.view.safeAreaLayoutGuide.bottomAnchor
                        ),
                        self.bottomLabel.centerXAnchor.constraint(
                            equalTo: self.view.safeAreaLayoutGuide.centerXAnchor
                        )
                    ])

                    self.registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (viewController: MyViewController, _) in
                        viewController.updateFonts()
                    }
                    self.updateFonts()
                }

                private func updateFonts() {
                    self.topLabel.font = .preferredFont(
                        forTextStyle: .headline, compatibleWith: self.traitCollection
                    )
                    self.leadingLabel.font = .preferredFont(
                        forTextStyle: .body, compatibleWith: self.traitCollection
                    )
                    self.trailingLabel.font = .preferredFont(
                        forTextStyle: .body, compatibleWith: self.traitCollection
                    )
                    self.bottomLabel.font = .preferredFont(
                        forTextStyle: .subheadline, compatibleWith: self.traitCollection
                    )
                    self.view.setNeedsUpdateConstraints()
                    self.view.updateConstraintsIfNeeded()
                }
            }

            let myViewController = MyViewController()
            let navController = UINavigationController(rootViewController: myViewController)
            let viewController = UITabBarController()
            viewController.setViewControllers([navController], animated: false)

            assertSnapshot(of: viewController, as: .image(on: .iPhoneSe), named: "iphone-se")
            assertSnapshot(of: viewController, as: .image(on: .iPhone8), named: "iphone-8")
            assertSnapshot(of: viewController, as: .image(on: .iPhone8Plus), named: "iphone-8-plus")
            assertSnapshot(of: viewController, as: .image(on: .iPhoneX), named: "iphone-x")
            assertSnapshot(of: viewController, as: .image(on: .iPhoneXr), named: "iphone-xr")
            assertSnapshot(of: viewController, as: .image(on: .iPhoneXsMax), named: "iphone-xs-max")
            assertSnapshot(of: viewController, as: .image(on: .iPadMini), named: "ipad-mini")
            assertSnapshot(of: viewController, as: .image(on: .iPad9_7), named: "ipad-9-7")
            assertSnapshot(of: viewController, as: .image(on: .iPad10_2), named: "ipad-10-2")
            assertSnapshot(of: viewController, as: .image(on: .iPadPro10_5), named: "ipad-pro-10-5")
            assertSnapshot(of: viewController, as: .image(on: .iPadPro11), named: "ipad-pro-11")
            assertSnapshot(of: viewController, as: .image(on: .iPadPro12_9), named: "ipad-pro-12-9")

            assertSnapshot(of: viewController, as: .image(on: .iPhoneSe(.portrait)), named: "iphone-se")
            assertSnapshot(of: viewController, as: .image(on: .iPhone8(.portrait)), named: "iphone-8")
            assertSnapshot(
                of: viewController, as: .image(on: .iPhone8Plus(.portrait)), named: "iphone-8-plus"
            )
            assertSnapshot(of: viewController, as: .image(on: .iPhoneX(.portrait)), named: "iphone-x")
            assertSnapshot(of: viewController, as: .image(on: .iPhoneXr(.portrait)), named: "iphone-xr")
            assertSnapshot(
                of: viewController, as: .image(on: .iPhoneXsMax(.portrait)), named: "iphone-xs-max"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadMini(.landscape)), named: "ipad-mini"
            )
            assertSnapshot(of: viewController, as: .image(on: .iPad9_7(.landscape)), named: "ipad-9-7")
            assertSnapshot(
                of: viewController, as: .image(on: .iPad10_2(.landscape)), named: "ipad-10-2"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadPro10_5(.landscape)), named: "ipad-pro-10-5"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadPro11(.landscape)), named: "ipad-pro-11"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadPro12_9(.landscape)), named: "ipad-pro-12-9"
            )

            assertSnapshot(
                of: viewController, as: .image(on: .iPhoneSe(.landscape)), named: "iphone-se-alternative"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPhone8(.landscape)), named: "iphone-8-alternative"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPhone8Plus(.landscape)),
                named: "iphone-8-plus-alternative"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPhoneX(.landscape)), named: "iphone-x-alternative"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPhoneXr(.landscape)), named: "iphone-xr-alternative"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPhoneXsMax(.landscape)),
                named: "iphone-xs-max-alternative"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadMini(.portrait)), named: "ipad-mini-alternative"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPad9_7(.portrait)), named: "ipad-9-7-alternative"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPad10_2(.portrait)), named: "ipad-10-2-alternative"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadPro10_5(.portrait)),
                named: "ipad-pro-10-5-alternative"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadPro11(.portrait)),
                named: "ipad-pro-11-alternative"
            )
            assertSnapshot(
                of: viewController, as: .image(on: .iPadPro12_9(.portrait)),
                named: "ipad-pro-12-9-alternative"
            )
        }
        #endif
    }

    func testCollectionViewsWithMultipleScreenSizes() async {
        #if os(iOS)

        final class CollectionViewController: UIViewController, UICollectionViewDataSource,
            UICollectionViewDelegateFlowLayout {

            let flowLayout: UICollectionViewFlowLayout = {
                let layout = UICollectionViewFlowLayout()
                layout.scrollDirection = .horizontal
                layout.minimumLineSpacing = 20
                return layout
            }()

            lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)

            override func viewDidLoad() {
                super.viewDidLoad()

                view.backgroundColor = .white
                view.addSubview(collectionView)

                collectionView.backgroundColor = .white
                collectionView.dataSource = self
                collectionView.delegate = self
                collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
                collectionView.translatesAutoresizingMaskIntoConstraints = false

                NSLayoutConstraint.activate([
                    collectionView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
                    collectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
                    collectionView.trailingAnchor.constraint(
                        equalTo: view.layoutMarginsGuide.trailingAnchor
                    ),
                    collectionView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
                ])

                collectionView.reloadData()
            }

            override func viewDidLayoutSubviews() {
                super.viewDidLayoutSubviews()
                collectionView.collectionViewLayout.invalidateLayout()
            }

            func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
                -> UICollectionViewCell {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
                cell.contentView.backgroundColor = .orange
                return cell
            }

            func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int)
                -> Int {
                20
            }

            func collectionView(
                _ collectionView: UICollectionView,
                layout collectionViewLayout: UICollectionViewLayout,
                sizeForItemAt indexPath: IndexPath
            ) -> CGSize {
                CGSize(
                    width: min(collectionView.frame.width - 50, 300),
                    height: collectionView.frame.height
                )
            }

        }

        let viewController = CollectionViewController()

        assertSnapshots(
            of: viewController,
            as: [
                "ipad": .image(on: .iPadPro12_9),
                "iphoneSe": .image(on: .iPhoneSe),
                "iphone8": .image(on: .iPhone8),
                "iphoneMax": .image(on: .iPhoneXsMax)
            ]
        )
        #endif
    }

    func testTraitsWithView() async {
        #if os(iOS)
        if #available(iOS 11.0, *) {
            let label = UILabel()
            label.font = .preferredFont(forTextStyle: .title1)
            label.adjustsFontForContentSizeCategory = true
            label.text = "What's the point?"

            for (name, contentSize) in allContentSizes {
                assertSnapshot(
                    of: label,
                    as: .image(traits: .init(preferredContentSizeCategory: contentSize)),
                    named: "label-\(name)"
                )
            }
        }
        #endif
    }

    func testTraitsWithViewController() async {
        #if os(iOS)
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        label.adjustsFontForContentSizeCategory = true
        label.text = "What's the point?"

        let viewController = UIViewController()
        viewController.view.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(
                equalTo: viewController.view.layoutMarginsGuide.leadingAnchor
            ),
            label.topAnchor.constraint(equalTo: viewController.view.layoutMarginsGuide.topAnchor),
            label.trailingAnchor.constraint(
                equalTo: viewController.view.layoutMarginsGuide.trailingAnchor
            )
        ])

        for (name, contentSize) in allContentSizes {
            assertSnapshot(
                of: viewController,
                as: .recursiveDescription(
                    on: .iPhoneSe, traits: .init(preferredContentSizeCategory: contentSize)
                ),
                named: "label-\(name)"
            )
        }
        #endif
    }

    func testUIBezierPath() async {
        #if os(iOS) || os(tvOS)
        let path = UIBezierPath(cgPath: .heart)

        let osName: String
        #if os(iOS)
        osName = "iOS"
        #elseif os(tvOS)
        osName = "tvOS"
        #endif

        if !ProcessInfo.processInfo.environment.keys.contains("GITHUB_WORKFLOW") {
            assertSnapshot(of: path, as: .image, named: osName)
        }

        if #available(iOS 11.0, tvOS 11.0, *) {
            assertSnapshot(of: path, as: .elementsDescription, named: osName)
        }
        #endif
    }

    func testUIView() async {
        #if os(iOS)
        let view = UIButton(type: .contactAdd)
        assertSnapshot(of: view, as: .image)
        assertSnapshot(of: view, as: .recursiveDescription)
        #endif
    }

    func testPreparedViewUsesKeyWindowScene() async throws {
        #if os(iOS)
        guard let keyWindow = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .filter({ $0.activationState == .foregroundActive })
            .flatMap(\.windows)
            .first(where: \.isKeyWindow) else {
            throw XCTSkip("No active key window scene")
        }

        let viewController = UIViewController()
        let dispose = prepareView(
            config: .init(),
            drawHierarchyInKeyWindow: false,
            traits: .init(),
            view: viewController.view,
            viewController: viewController
        )
        defer { dispose() }

        XCTAssertTrue(viewController.view.window?.windowScene === keyWindow.windowScene)
        #endif
    }

    func testPreparedViewPreservesDirectionalLayoutMargins() async {
        #if os(iOS)
        final class ViewController: UIViewController {
            let contentView = UIView()

            override func viewDidLoad() {
                super.viewDidLoad()
                contentView.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(contentView)
                NSLayoutConstraint.activate([
                    contentView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
                    contentView.leadingAnchor.constraint(
                        equalTo: view.layoutMarginsGuide.leadingAnchor
                    ),
                    contentView.trailingAnchor.constraint(
                        equalTo: view.layoutMarginsGuide.trailingAnchor
                    ),
                    contentView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
                ])
            }
        }

        let config = ViewImageConfig.iPhone8(.landscape)
        let viewController = ViewController()
        let expectedMargins = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        let snapshot = snapshotView(
            config: config,
            drawHierarchyInKeyWindow: false,
            traits: .init(),
            view: viewController.view,
            viewController: viewController
        )
        viewController.view.layoutIfNeeded()
        let preparedMargins = viewController.view.directionalLayoutMargins
        let preparedLeadingEdge = viewController.contentView.frame.minX

        await withCheckedContinuation { continuation in
            snapshot.run { _ in continuation.resume() }
        }

        XCTAssertEqual(preparedMargins, expectedMargins)
        XCTAssertEqual(preparedLeadingEdge, expectedMargins.leading)
        #endif
    }

    func testUIViewControllerLifeCycle() async {
        #if os(iOS)
        class ViewController: UIViewController {
            let viewDidLoadExpectation: XCTestExpectation
            let viewWillAppearExpectation: XCTestExpectation
            let viewDidAppearExpectation: XCTestExpectation
            let viewWillDisappearExpectation: XCTestExpectation
            let viewDidDisappearExpectation: XCTestExpectation
            init(
                viewDidLoadExpectation: XCTestExpectation,
                viewWillAppearExpectation: XCTestExpectation,
                viewDidAppearExpectation: XCTestExpectation,
                viewWillDisappearExpectation: XCTestExpectation,
                viewDidDisappearExpectation: XCTestExpectation
            ) {
                self.viewDidLoadExpectation = viewDidLoadExpectation
                self.viewWillAppearExpectation = viewWillAppearExpectation
                self.viewDidAppearExpectation = viewDidAppearExpectation
                self.viewWillDisappearExpectation = viewWillDisappearExpectation
                self.viewDidDisappearExpectation = viewDidDisappearExpectation
                super.init(nibName: nil, bundle: nil)
            }

            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }

            override func viewDidLoad() {
                super.viewDidLoad()
                viewDidLoadExpectation.fulfill()
            }

            override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
                viewWillAppearExpectation.fulfill()
            }

            override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                viewDidAppearExpectation.fulfill()
            }

            override func viewWillDisappear(_ animated: Bool) {
                super.viewWillDisappear(animated)
                viewWillDisappearExpectation.fulfill()
            }

            override func viewDidDisappear(_ animated: Bool) {
                super.viewDidDisappear(animated)
                viewDidDisappearExpectation.fulfill()
            }
        }

        let viewDidLoadExpectation = expectation(description: "viewDidLoad")
        let viewWillAppearExpectation = expectation(description: "viewWillAppear")
        let viewDidAppearExpectation = expectation(description: "viewDidAppear")
        let viewWillDisappearExpectation = expectation(description: "viewWillDisappear")
        let viewDidDisappearExpectation = expectation(description: "viewDidDisappear")
        viewWillAppearExpectation.expectedFulfillmentCount = 2
        viewDidAppearExpectation.expectedFulfillmentCount = 2
        viewWillDisappearExpectation.expectedFulfillmentCount = 2
        viewDidDisappearExpectation.expectedFulfillmentCount = 2
        viewWillAppearExpectation.assertForOverFulfill = true
        viewDidAppearExpectation.assertForOverFulfill = true
        viewWillDisappearExpectation.assertForOverFulfill = true
        viewDidDisappearExpectation.assertForOverFulfill = true

        let viewController = ViewController(
            viewDidLoadExpectation: viewDidLoadExpectation,
            viewWillAppearExpectation: viewWillAppearExpectation,
            viewDidAppearExpectation: viewDidAppearExpectation,
            viewWillDisappearExpectation: viewWillDisappearExpectation,
            viewDidDisappearExpectation: viewDidDisappearExpectation
        )

        assertSnapshot(of: viewController, as: .image)
        assertSnapshot(of: viewController, as: .image)

        await fulfillment(
            of: [
                viewDidLoadExpectation,
                viewWillAppearExpectation,
                viewDidAppearExpectation,
                viewWillDisappearExpectation,
                viewDidDisappearExpectation
            ], timeout: 1.0, enforceOrder: true
        )

        let window = UIWindow(frame: .init(x: 0, y: 0, width: 100, height: 100))
        let originalRootViewController = UIViewController()
        window.rootViewController = originalRootViewController
        window.isHidden = false
        let existingViewDidLoadExpectation = expectation(description: "existing window viewDidLoad")
        let existingViewWillAppearExpectation = expectation(description: "existing window viewWillAppear")
        let existingViewDidAppearExpectation = expectation(description: "existing window viewDidAppear")
        let existingViewWillDisappearExpectation = expectation(description: "existing window viewWillDisappear")
        let existingViewDidDisappearExpectation = expectation(description: "existing window viewDidDisappear")
        existingViewWillAppearExpectation.assertForOverFulfill = true
        existingViewDidAppearExpectation.assertForOverFulfill = true
        existingViewWillDisappearExpectation.assertForOverFulfill = true
        existingViewDidDisappearExpectation.assertForOverFulfill = true

        let existingViewController = ViewController(
            viewDidLoadExpectation: existingViewDidLoadExpectation,
            viewWillAppearExpectation: existingViewWillAppearExpectation,
            viewDidAppearExpectation: existingViewDidAppearExpectation,
            viewWillDisappearExpectation: existingViewWillDisappearExpectation,
            viewDidDisappearExpectation: existingViewDidDisappearExpectation
        )

        let dispose = addViewController(
            traits: .init(), viewController: existingViewController, to: window
        )
        dispose()

        await fulfillment(
            of: [
                existingViewDidLoadExpectation,
                existingViewWillAppearExpectation,
                existingViewDidAppearExpectation,
                existingViewWillDisappearExpectation,
                existingViewDidDisappearExpectation
            ], timeout: 1.0, enforceOrder: true
        )
        XCTAssertTrue(window.rootViewController === originalRootViewController)
        #endif
    }

    func testUIViewControllerSettlingDelay() async {
        #if os(iOS) || os(tvOS)
        final class ViewController: UIViewController {
            let settlesAfterAppearing: Bool

            init(color: UIColor, settlesAfterAppearing: Bool = false) {
                self.settlesAfterAppearing = settlesAfterAppearing
                super.init(nibName: nil, bundle: nil)
                view.backgroundColor = color
            }

            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }

            override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                guard settlesAfterAppearing else {
                    return
                }
                DispatchQueue.main.async { [weak self] in
                    self?.view.backgroundColor = .blue
                }
            }
        }

        let size = CGSize(width: 10, height: 10)
        let traits = UITraitCollection(displayScale: 1)

        func capture(_ viewController: ViewController, settlingDelay: TimeInterval = 0) async -> UIImage {
            let strategy = Snapshotting<ViewController, UIImage>.image(
                size: size,
                traits: traits,
                settlingDelay: settlingDelay
            )
            return await withCheckedContinuation { continuation in
                strategy.snapshot(viewController).run { continuation.resume(returning: $0) }
            }
        }

        let red = await capture(ViewController(color: .red))
        let blue = await capture(ViewController(color: .blue))
        let immediate = await capture(ViewController(color: .red, settlesAfterAppearing: true))
        let settled = await capture(
            ViewController(color: .red, settlesAfterAppearing: true), settlingDelay: 0.01
        )

        XCTAssertNil(Diffing<UIImage>.image.diffV2(red, immediate))
        XCTAssertNil(Diffing<UIImage>.image.diffV2(blue, settled))
        #endif
    }

    func testKeyboardLayoutGuideSafeArea() async {
        #if os(iOS)
        final class ViewController: UIViewController {
            let contentView = UIView()

            override func viewDidLoad() {
                super.viewDidLoad()
                view.backgroundColor = .blue
                contentView.backgroundColor = .red
                contentView.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(contentView)
                NSLayoutConstraint.activate([
                    contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                    contentView.leadingAnchor.constraint(
                        equalTo: view.safeAreaLayoutGuide.leadingAnchor
                    ),
                    contentView.trailingAnchor.constraint(
                        equalTo: view.safeAreaLayoutGuide.trailingAnchor
                    ),
                    contentView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
                ])
            }
        }

        func config(bottomSafeArea: CGFloat) -> ViewImageConfig {
            .init(
                safeArea: .init(top: 0, left: 0, bottom: bottomSafeArea, right: 0),
                size: .init(width: 20, height: 20),
                traits: .init(displayScale: 3)
            )
        }
        let traits = UITraitCollection(displayScale: 3)

        assertSnapshot(
            of: ViewController(),
            as: .image(on: config(bottomSafeArea: 0), traits: traits),
            named: "zero"
        )
        assertSnapshot(
            of: ViewController(),
            as: .image(on: config(bottomSafeArea: 1), traits: traits),
            named: "nonzero"
        )
        #endif
    }

    func testCALayer() async {
        #if os(iOS)
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        layer.backgroundColor = UIColor.red.cgColor
        layer.borderWidth = 4.0
        layer.borderColor = UIColor.black.cgColor
        assertSnapshot(of: layer, as: .image)
        #endif
    }

    func testCALayerWithGradient() async {
        #if os(iOS)
        let baseLayer = CALayer()
        baseLayer.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.red.cgColor, UIColor.yellow.cgColor]
        gradientLayer.frame = baseLayer.frame
        baseLayer.addSublayer(gradientLayer)
        assertSnapshot(of: baseLayer, as: .image)
        #endif
    }

    func testViewControllerHierarchy() async {
        #if os(iOS)
        let page = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        page.setViewControllers([UIViewController()], direction: .forward, animated: false)
        let tab = UITabBarController()
        tab.viewControllers = [
            UINavigationController(rootViewController: page),
            UINavigationController(rootViewController: UIViewController()),
            UINavigationController(rootViewController: UIViewController()),
            UINavigationController(rootViewController: UIViewController()),
            UINavigationController(rootViewController: UIViewController())
        ]
        assertSnapshot(of: tab, as: .hierarchy)
        #endif
    }

    func testURLRequest() async throws {
        var get = URLRequest(url: try XCTUnwrap(URL(string: "https://www.pointfree.co/")))
        get.addValue("pf_session={}", forHTTPHeaderField: "Cookie")
        get.addValue("text/html", forHTTPHeaderField: "Accept")
        get.addValue("application/json", forHTTPHeaderField: "Content-Type")
        assertSnapshot(of: get, as: .raw, named: "get")
        assertSnapshot(of: get, as: .curl, named: "get-curl")

        var getWithQuery = URLRequest(
            url: try XCTUnwrap(URL(string: "https://www.pointfree.co?key_2=value_2&key_1=value_1&key_3=value_3"))
        )
        getWithQuery.addValue("pf_session={}", forHTTPHeaderField: "Cookie")
        getWithQuery.addValue("text/html", forHTTPHeaderField: "Accept")
        getWithQuery.addValue("application/json", forHTTPHeaderField: "Content-Type")
        assertSnapshot(of: getWithQuery, as: .raw, named: "get-with-query")
        assertSnapshot(of: getWithQuery, as: .curl, named: "get-with-query-curl")

        var post = URLRequest(url: try XCTUnwrap(URL(string: "https://www.pointfree.co/subscribe")))
        post.httpMethod = "POST"
        post.addValue("pf_session={\"user_id\":\"0\"}", forHTTPHeaderField: "Cookie")
        post.addValue("text/html", forHTTPHeaderField: "Accept")
        post.httpBody = Data("pricing[billing]=monthly&pricing[lane]=individual".utf8)
        assertSnapshot(of: post, as: .raw, named: "post")
        assertSnapshot(of: post, as: .curl, named: "post-curl")

        var postWithJSON = URLRequest(
            url: try XCTUnwrap(URL(string: "http://dummy.restapiexample.com/api/v1/create"))
        )
        postWithJSON.httpMethod = "POST"
        postWithJSON.addValue("application/json", forHTTPHeaderField: "Content-Type")
        postWithJSON.addValue("application/json", forHTTPHeaderField: "Accept")
        postWithJSON.httpBody = Data(
            "{\"name\":\"tammy134235345235\", \"salary\":0, \"age\":\"tammy133\"}".utf8
        )
        assertSnapshot(of: postWithJSON, as: .raw, named: "post-with-json")
        assertSnapshot(of: postWithJSON, as: .curl, named: "post-with-json-curl")

        var head = URLRequest(url: try XCTUnwrap(URL(string: "https://www.pointfree.co/")))
        head.httpMethod = "HEAD"
        head.addValue("pf_session={}", forHTTPHeaderField: "Cookie")
        assertSnapshot(of: head, as: .raw, named: "head")
        assertSnapshot(of: head, as: .curl, named: "head-curl")

        post = URLRequest(url: try XCTUnwrap(URL(string: "https://www.pointfree.co/subscribe")))
        post.httpMethod = "POST"
        post.addValue("pf_session={\"user_id\":\"0\"}", forHTTPHeaderField: "Cookie")
        post.addValue("application/json", forHTTPHeaderField: "Accept")
        post.httpBody = Data(
            """
            {"pricing": {"lane": "individual","billing": "monthly"}}
            """.utf8
        )
        assertSnapshot(of: post, as: .raw(pretty: true), named: "post-pretty")
        post.httpBody = Data("not JSON".utf8)
        assertSnapshot(of: post, as: .raw(pretty: true), named: "post-pretty-invalid-json")
    }

    #if os(Linux) || os(tvOS) || os(watchOS)
    func testWebView() async {}
    #else
    func testWebView() throws {
        let fixtureUrl = URL(fileURLWithPath: String(#filePath), isDirectory: false)
            .deletingLastPathComponent()
            .appendingPathComponent("__Fixtures__/pointfree.html")
        let html = try String(contentsOf: fixtureUrl)
        let webView = WKWebView()
        webView.loadHTMLString(html, baseURL: nil)
        if !ProcessInfo.processInfo.environment.keys.contains("GITHUB_WORKFLOW") {
            assertSnapshot(
                of: webView,
                as: .image(size: .init(width: 800, height: 600)),
                named: platform
            )
        }
    }
    #endif

    func testViewWithZeroHeightOrWidth() async {
        #if os(iOS) || os(tvOS)
        var rect = CGRect(x: 0, y: 0, width: 350, height: 0)
        var view = UIView(frame: rect)
        view.backgroundColor = .red
        assertSnapshot(of: view, as: .image, named: "\(platform)-noHeight")

        rect = CGRect(x: 0, y: 0, width: 0, height: 350)
        view = UIView(frame: rect)
        view.backgroundColor = .green
        assertSnapshot(of: view, as: .image, named: "\(platform)-noWidth")

        rect = CGRect(x: 0, y: 0, width: 0, height: 0)
        view = UIView(frame: rect)
        view.backgroundColor = .blue
        assertSnapshot(of: view, as: .image, named: "\(platform)-noWidth.noHeight")
        #endif
    }

    func testViewAgainstEmptyImage() async {
        #if os(iOS) || os(tvOS)
        let rect = CGRect(x: 0, y: 0, width: 0, height: 0)
        let view = UIView(frame: rect)
        view.backgroundColor = .blue

        let failure = verifySnapshot(
            of: view, as: .image, named: "notEmptyImage", record: .never
        )
        XCTAssertNotNil(failure)
        #endif
    }

    #if os(iOS)
    func testEmbeddedWebView() throws {
        let label = UILabel()
        label.text = "Hello, Blob!"

        let fixtureUrl = URL(fileURLWithPath: String(#filePath), isDirectory: false)
            .deletingLastPathComponent()
            .appendingPathComponent("__Fixtures__/pointfree.html")
        let html = try String(contentsOf: fixtureUrl)
        let webView = WKWebView()
        webView.loadHTMLString(html, baseURL: nil)
        webView.isHidden = true

        let stackView = UIStackView(arrangedSubviews: [label, webView])
        stackView.axis = .vertical

        if !ProcessInfo.processInfo.environment.keys.contains("GITHUB_WORKFLOW") {
            assertSnapshot(
                of: stackView,
                as: .image(size: .init(width: 800, height: 600)),
                named: platform
            )
        }
    }
    #else
    func testEmbeddedWebView() async {}
    #endif

    #if os(iOS) || os(macOS)
    final class ManipulatingWKWebViewNavigationDelegate: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.body.children[0].classList.remove(\"hero\")") // Change layout
        }
    }

    func testWebViewWithManipulatingNavigationDelegate() throws {
        let manipulatingWKWebViewNavigationDelegate = ManipulatingWKWebViewNavigationDelegate()
        let webView = WKWebView()
        webView.navigationDelegate = manipulatingWKWebViewNavigationDelegate

        let fixtureUrl = URL(fileURLWithPath: String(#filePath), isDirectory: false)
            .deletingLastPathComponent()
            .appendingPathComponent("__Fixtures__/pointfree.html")
        let html = try String(contentsOf: fixtureUrl)
        webView.loadHTMLString(html, baseURL: nil)
        if !ProcessInfo.processInfo.environment.keys.contains("GITHUB_WORKFLOW") {
            assertSnapshot(
                of: webView,
                as: .image(size: .init(width: 800, height: 600)),
                named: platform
            )
        }
        _ = manipulatingWKWebViewNavigationDelegate
    }

    final class CancellingWKWebViewNavigationDelegate: NSObject, WKNavigationDelegate {
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping @MainActor @Sendable (WKNavigationActionPolicy) -> Void
        ) {
            decisionHandler(.cancel)
        }
    }

    func testWebViewWithCancellingNavigationDelegate() throws {
        let cancellingWKWebViewNavigationDelegate = CancellingWKWebViewNavigationDelegate()
        let webView = WKWebView()
        webView.navigationDelegate = cancellingWKWebViewNavigationDelegate

        let fixtureUrl = URL(fileURLWithPath: String(#filePath), isDirectory: false)
            .deletingLastPathComponent()
            .appendingPathComponent("__Fixtures__/pointfree.html")
        let html = try String(contentsOf: fixtureUrl)
        webView.loadHTMLString(html, baseURL: nil)
        if !ProcessInfo.processInfo.environment.keys.contains("GITHUB_WORKFLOW") {
            assertSnapshot(
                of: webView,
                as: .image(size: .init(width: 800, height: 600)),
                named: platform
            )
        }
        _ = cancellingWKWebViewNavigationDelegate
    }
    #endif

    #if os(macOS)
    @available(macOS 13.0, *) func testSwiftUIView_macOS() async {
        struct MyView: SwiftUI.View {
            var body: some SwiftUI.View {
                HStack(spacing: 0) {
                    Color.red.frame(width: 8, height: 12)
                    Color.blue.frame(width: 8, height: 12)
                }
                .padding(2)
                .background(Color.white)
            }
        }

        let view = MyView()
        let _: Snapshotting<MyView, NSImage> = .image

        assertSnapshot(of: view, as: .image)
        assertSnapshot(
            of: view,
            as: .image(layout: .fixed(width: 40, height: 30)),
            named: "fixed"
        )
    }
    #endif

    #if os(iOS)
    @available(iOS 13.0, *) func testSwiftUIView_iOS() async {
        struct MyView: SwiftUI.View {
            var body: some SwiftUI.View {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Checked").fixedSize()
                }
                .padding(5)
                .background(RoundedRectangle(cornerRadius: 5.0).fill(Color.blue))
                .padding(10)
            }
        }

        let view = MyView().background(Color.yellow)

        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
        assertSnapshot(
            of: view, as: .image(layout: .sizeThatFits, traits: .init(userInterfaceStyle: .light)),
            named: "size-that-fits"
        )
        assertSnapshot(
            of: view,
            as: .image(
                layout: .fixed(width: 200.0, height: 100.0), traits: .init(userInterfaceStyle: .light)
            ),
            named: "fixed"
        )
        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhoneSe), traits: .init(userInterfaceStyle: .light)),
            named: "device"
        )
    }

    @available(iOS 13.0, *) func testSwiftUIViewSizeThatFits_iOS() async {
        let traits = UITraitCollection(userInterfaceStyle: .light)

        assertSnapshot(
            of: Text("Hello, World!").padding(),
            as: .image(layout: .sizeThatFits, traits: traits),
            named: "text"
        )
        assertSnapshot(
            of: HStack {
                Text("Left")
                Spacer()
                Text("Right")
            }
            .padding(),
            as: .image(layout: .sizeThatFits, traits: traits),
            named: "hstack"
        )
    }
    #endif

    #if os(iOS) || os(tvOS)
    @available(iOS 13.0, tvOS 13.0, *) func testSwiftUIViewSizeThatFitsUsesSnapshotTraits() async {
        struct TraitSizedView: SwiftUI.View {
            let expectedStyle: UIUserInterfaceStyle

            var body: some SwiftUI.View {
                Color.red.frame(
                    width: UITraitCollection.current.userInterfaceStyle == expectedStyle ? 20 : 10,
                    height: 10
                )
            }
        }

        let currentStyle = UITraitCollection.current.userInterfaceStyle
        let expectedStyle: UIUserInterfaceStyle = currentStyle == .dark ? .light : .dark
        let traits = UITraitCollection.merging([
            .init(displayScale: 1),
            .init(userInterfaceStyle: expectedStyle)
        ])
        let strategy = Snapshotting<TraitSizedView, UIImage>.image(
            layout: .sizeThatFits,
            traits: traits
        )
        let image = await withCheckedContinuation { continuation in
            strategy.snapshot(TraitSizedView(expectedStyle: expectedStyle)).run {
                continuation.resume(returning: $0)
            }
        }

        XCTAssertEqual(image.size, CGSize(width: 20, height: 10))
    }
    #endif

    #if os(tvOS)
    @available(tvOS 13.0, *) func testSwiftUIView_tvOS() async {
        struct MyView: SwiftUI.View {
            var body: some SwiftUI.View {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Checked").fixedSize()
                }
                .padding(5)
                .background(RoundedRectangle(cornerRadius: 5.0).fill(Color.blue))
                .padding(10)
            }
        }
        let view = MyView().background(Color.yellow)

        assertSnapshot(of: view, as: .image())
        assertSnapshot(of: view, as: .image(layout: .sizeThatFits), named: "size-that-fits")
        assertSnapshot(
            of: view, as: .image(layout: .fixed(width: 300.0, height: 100.0)), named: "fixed"
        )
        assertSnapshot(of: view, as: .image(layout: .device(config: .tv)), named: "device")
    }
    #endif

    @available(iOS 13.0, tvOS 13.0, *) func testSwiftUIViewSettlingDelay() async {
        #if os(iOS) || os(tvOS)
        let traits = UITraitCollection(displayScale: 1)

        func capture<View: SwiftUI.View>(_ view: View, settlingDelay: TimeInterval = 0) async -> UIImage {
            let strategy = Snapshotting<View, UIImage>.image(
                layout: .fixed(width: 10, height: 10),
                traits: traits,
                settlingDelay: settlingDelay
            )
            return await withCheckedContinuation { continuation in
                strategy.snapshot(view).run { continuation.resume(returning: $0) }
            }
        }

        let red = await capture(Color.red)
        let blue = await capture(Color.blue)
        let immediate = await capture(DelayedColorView())
        let settled = await capture(DelayedColorView(), settlingDelay: 0.01)

        XCTAssertNil(Diffing<UIImage>.image.diffV2(red, immediate))
        XCTAssertNil(Diffing<UIImage>.image.diffV2(blue, settled))
        #endif
    }

    #if os(macOS) || os(iOS) || os(tvOS)
    func testReferenceLoadFailure() async {
        let snapshotUrl = URL(fileURLWithPath: String(#filePath), isDirectory: false)
            .deletingLastPathComponent()
            .appendingPathComponent(
                "__Snapshots__/SnapshotTestingTests/testReferenceLoadFailure.1.png"
            )

        XCTExpectFailure {
            withSnapshotTesting(record: .failed) {
                #if canImport(UIKit)
                assertSnapshot(
                    of: UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10)),
                    as: .image
                )
                #else
                assertSnapshot(of: NSImage(size: .init(width: 10, height: 10)), as: .image)
                #endif
            }
        } issueMatcher: {
            #if canImport(UIKit)
            $0.compactDescription.hasPrefix("failed - Failed to serialize \(snapshotUrl) as UIImage")
            #else
            $0.compactDescription.hasPrefix("failed - Failed to serialize \(snapshotUrl) as NSImage")
            #endif
        }
    }
    #endif
}

#if os(iOS) || os(tvOS)
@available(iOS 13.0, tvOS 13.0, *) private struct DelayedColorView: SwiftUI.View {
    @State private var color = Color.red

    var body: some SwiftUI.View {
        color.onAppear {
            DispatchQueue.main.async {
                color = .blue
            }
        }
    }
}
#endif

#if os(iOS)
private let allContentSizes =
    [
        "extra-small": UIContentSizeCategory.extraSmall,
        "small": .small,
        "medium": .medium,
        "large": .large,
        "extra-large": .extraLarge,
        "extra-extra-large": .extraExtraLarge,
        "extra-extra-extra-large": .extraExtraExtraLarge,
        "accessibility-medium": .accessibilityMedium,
        "accessibility-large": .accessibilityLarge,
        "accessibility-extra-large": .accessibilityExtraLarge,
        "accessibility-extra-extra-large": .accessibilityExtraExtraLarge,
        "accessibility-extra-extra-extra-large": .accessibilityExtraExtraExtraLarge
    ]
#endif
