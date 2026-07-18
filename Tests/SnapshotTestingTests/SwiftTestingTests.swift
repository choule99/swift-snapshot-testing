#if compiler(>=6) && canImport(Testing)
import SnapshotTesting
import Testing

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

#if os(watchOS)
import SwiftUI
#endif

extension BaseSuite {
    @MainActor @Suite(.serialized, .snapshots(record: .missing)) struct SwiftTestingTests {
        @Test func snapshot() {
            assertSnapshot(of: ["Hello", "World"], as: .dump, named: "snap")
            withKnownIssue {
                assertSnapshot(of: ["Goodbye", "World"], as: .dump, named: "snap")
            } matching: { issue in
                issue.description.hasSuffix(
                    """
                    @@ −1,4 +1,4 @@
                     ▿ 2 elements
                    −  - "Hello"
                    +  - "Goodbye"
                       - "World"
                    """
                )
            }
        }

        #if canImport(UIKit) && !os(watchOS)
        @Test(
            .enabled {
                !ProcessInfo.processInfo.environment.keys.contains("GITHUB_WORKFLOW")
            }
        ) func uIImage() {
            let redPixel = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { context in
                UIColor.red.setFill()
                context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            }
            let bluePixel = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { context in
                UIColor.blue.setFill()
                context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            }
            assertSnapshot(of: redPixel, as: .image, named: "\(platform)-pixel")
            withKnownIssue {
                assertSnapshot(of: bluePixel, as: .image, named: "\(platform)-pixel")
            } matching: { issue in
                issue.description.hasSuffix(
                    "Newly-taken snapshot does not match reference."
                )
            }
        }
        #endif

        #if os(watchOS)
        @Test func watchOSImageStrategies() async throws {
            let red = try watchImage(red: 1, blue: 0)
            let blue = try watchImage(red: 0, blue: 1)

            #expect(Diffing<UIImage>.image.diffV2(red, red) == nil)
            #expect(
                Diffing<UIImage>.image.diffV2(red, blue)?.0
                    == "Newly-taken snapshot does not match reference."
            )
            #expect(Diffing<UIImage>.image(options: .init(precision: 0.5)).diffV2(red, blue) == nil)
            #expect(Diffing<UIImage>.image(options: .init(precision: 0.51)).diffV2(red, blue) != nil)
            #expect(!Diffing<UIImage>.image.toData(UIImage()).isEmpty)

            let strategy: Snapshotting<Text, UIImage> = .image(
                precision: 0.99,
                layout: .fixed(width: 10, height: 10)
            )
            await confirmation { confirmation in
                strategy.snapshot(Text("Watch")).run { image in
                    #expect(image.size == CGSize(width: 10, height: 10))
                    confirmation()
                }
            }
        }

        private func watchImage(red: CGFloat, blue: CGFloat) throws -> UIImage {
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let context = try #require(
                CGContext(
                    data: nil,
                    width: 1,
                    height: 1,
                    bitsPerComponent: 8,
                    bytesPerRow: 4,
                    space: colorSpace,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                )
            )
            context.setFillColor(
                try #require(CGColor(colorSpace: colorSpace, components: [red, 0, blue, 1]))
            )
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            return UIImage(cgImage: try #require(context.makeImage()))
        }
        #endif

        #if canImport(AppKit)
        @Test(
            .enabled {
                !ProcessInfo.processInfo.environment.keys.contains("GITHUB_WORKFLOW")
            }
        ) func nSImage() {
            let redPixel = NSImage(size: NSSize(width: 1, height: 1), flipped: false) { rect in
                NSColor.red.setFill()
                rect.fill()
                return true
            }
            let bluePixel = NSImage(size: NSSize(width: 1, height: 1), flipped: false) { rect in
                NSColor.blue.setFill()
                rect.fill()
                return true
            }
            assertSnapshot(of: redPixel, as: .image, named: "\(platform)-pixel")
            withKnownIssue {
                assertSnapshot(of: bluePixel, as: .image, named: "\(platform)-pixel")
            } matching: { issue in
                issue.description.hasSuffix(
                    "Newly-taken snapshot does not match reference."
                )
            }
        }
        #endif

    }
}
#endif
