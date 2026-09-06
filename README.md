# 📸 SnapshotTesting

Delightful Swift snapshot testing.

> This is a fork of [pointfreeco/swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing/). It aims to integrate pull requests and issues more proactively, while making long-overdue changes like Swift 6 support.

## Usage

Once [installed](#installation), _no additional configuration is required_. You can import the
`SnapshotTesting` module and call the `assertSnapshot` function.

``` swift
import SnapshotTesting
import Testing
import UIKit

@MainActor
struct MyViewControllerTests {
  @Test func myViewController() {
    let vc = MyViewController()

    assertSnapshot(of: vc, as: .image)
  }
}
```

When an assertion first runs, a snapshot is automatically recorded to disk and the test will fail,
printing out the file path of any newly-recorded reference.

> ❌ failed - No reference was found on disk. Automatically recorded snapshot: …
>
> open "…/MyAppTests/\_\_Snapshots\_\_/MyViewControllerTests/testMyViewController.png"
>
> Re-run "testMyViewController" to test against the newly-recorded snapshot.

Repeat test runs will load this reference and compare it with the runtime value. If they don't
match, the test will fail and describe the difference. Failures can be inspected from Xcode's Report
Navigator or by inspecting the file URLs of the failure.

You can record a new reference by customizing snapshots inline with the assertion, or using the
`withSnapshotTesting` tool:

```swift
// Record just this one snapshot
assertSnapshot(
  of: vc,
  as: .image,
  options: SnapshotAssertionOptions().recording(.all)
)

// Record all snapshots in a scope:
withSnapshotTesting(record: .all) {
  assertSnapshot(of: vc1, as: .image)
  assertSnapshot(of: vc2, as: .image)
  assertSnapshot(of: vc3, as: .image)
}

// Record all snapshot failures in a Swift Testing suite:
@Suite(.snapshots(record: .failed))
struct FeatureTests {}

// Record all snapshot failures in an 'XCTestCase' subclass:
class FeatureTests: XCTestCase {
  override func invokeTest() {
    withSnapshotTesting(record: .failed) {
      super.invokeTest()
    }
  }
}
```

SwiftUI image snapshots use `en_US_POSIX`, UTC, and the Gregorian calendar by default. Override
them for a scope when needed:

```swift
let configuration = SnapshotTestingConfiguration()
  .usingLocale(Locale(identifier: "fr_CA"))
  .usingTimeZone(TimeZone(identifier: "America/Toronto"))
  .usingCalendar(Calendar(identifier: .gregorian))

withSnapshotTesting(configuration) {
  assertSnapshot(of: view, as: .image)
}
```

References can also be centralized beneath a test target while preserving the source-file
hierarchy:

```swift
let configuration = SnapshotTestingConfiguration(
  referenceStorage: .directory("__Snapshots__", relativeTo: .testTarget)
)

withSnapshotTesting(configuration) {
  assertSnapshot(of: view, as: .image)
}
```

This opt-in policy places a test in `Flows/ChatViewTests.swift` under
`__Snapshots__/Flows/ChatViewTests/`. Move existing references to the new hierarchy before enabling
the policy, and exclude only the centralized `__Snapshots__` directory from the SwiftPM test
target. The test-target directory must match the test module name; use
`SnapshotAssertionOptions.savingSnapshots(in:)` for custom source layouts.

Image comparison precision can be reused independently from assertion and environment options:

```swift
let imageOptions = ImageSnapshotOptions()
  .requiringPixelPrecision(0.99)
  .requiringPerceptualPrecision(0.98)

assertSnapshot(of: view, as: .image(options: imageOptions))
```

### Reuse SwiftUI previews in snapshot tests

Add the lightweight `SnapshotPreviews` product to the target that owns your SwiftUI views. A
concrete preview type must spell both conformances so that Xcode can discover `PreviewProvider`:

```swift
import SnapshotPreviews
import SwiftUI

struct MyView_Previews: PreviewProvider, SnapshotProvider {
  static let defaultLayout: PreviewSnapshotLayout = .device

  @SnapshotBuilder
  static var snapshots: [PreviewSnapshot] {
    PreviewSnapshot("Default") {
      MyView()
    }

    PreviewSnapshot("Compact", layout: .fixed(width: 320, height: 480)) {
      MyView()
    }
  }
}
```

`SnapshotProvider` supplies the `previews` implementation. The same named views can then be image
snapshot-tested from a test target that imports `SnapshotTesting`:

```swift
@testable import MyFeature
import SnapshotTesting
import Testing

@MainActor
struct MyViewTests {
  @Test func snapshots() {
    let compactLight = ViewImageConfig.iPhone17Pro
    var compactDark = compactLight
    compactDark.traits = UITraitCollection(userInterfaceStyle: .dark)

    assertSnapshots(
      of: MyView_Previews.self,
      configurations: [
        NamedViewImageConfig(name: "compact-light", device: compactLight),
        NamedViewImageConfig(name: "compact-dark", device: compactDark)
      ]
    )
  }
}
```

`PreviewSnapshot` uses the provider's `defaultLayout` when no layout is supplied; providers default
to `.sizeThatFits`. Use `resolvedSnapshots` when a custom assertion loop needs the effective
layouts. A `.device` snapshot requires the single `on: ViewImageConfig` overload or a named
configuration matrix on iOS and tvOS. Matrix references use stable names such as
`snapshots.compact-light.Default.png`, and each device configuration's traits apply automatically.
On macOS and watchOS, image snapshot assertions support fixed and size-to-fit layouts.

Transform a snapshot or collection without reconstructing its metadata:

```swift
let snapshots = rawSnapshots.transformingViews {
  $0.injectingPreviewEnvironment()
}
```

Snapshot names must be unique within a provider because they name the reference files. The public
raw `snapshots` and resolved `resolvedSnapshots` collections remain available for custom strategies
or rendering behavior.

## Snapshot Anything

While most snapshot testing libraries in the Swift community are limited to `UIImage`s of `UIView`s,
SnapshotTesting can work with _any_ format of _any_ value on _any_ Swift platform!

The `assertSnapshot` function accepts a value and any snapshot strategy that value supports. This
means that a view or view controller can be tested against an image representation _and_ against a
textual representation of its properties and subview hierarchy.

``` swift
assertSnapshot(of: vc, as: .image)
assertSnapshot(of: vc, as: .recursiveDescription)
```

View testing is highly configurable. You can override trait collections (for specific size classes
and content size categories) and generate device-agnostic snapshots, all from a single simulator.

``` swift
assertSnapshot(of: vc, as: .image(on: .iPhoneSe))
assertSnapshot(of: vc, as: .recursiveDescription(on: .iPhoneSe))

assertSnapshot(of: vc, as: .image(on: .iPhoneSe(.landscape)))
assertSnapshot(of: vc, as: .recursiveDescription(on: .iPhoneSe(.landscape)))

assertSnapshot(of: vc, as: .image(on: .iPhoneX))
assertSnapshot(of: vc, as: .recursiveDescription(on: .iPhoneX))

assertSnapshot(of: vc, as: .image(on: .iPadMini(.portrait)))
assertSnapshot(of: vc, as: .recursiveDescription(on: .iPadMini(.portrait)))
```

> **Warning**
> Snapshots must be compared using the exact same simulator that originally took the reference to
> avoid discrepancies between images.

SnapshotTesting does not enforce a global capture environment because a test suite may intentionally
run references on multiple simulators. The simulator running the test is independent of the
`ViewImageConfig` passed to `.image(on:)`. If a suite requires a fixed simulator, add a client-side
preflight:

``` swift
import Foundation
import SnapshotTesting
import Testing

func assertSnapshotEnvironment(
  simulatorModelIdentifier: String,
  iOSMajorVersion: Int
) -> Bool {
  let processInfo = ProcessInfo.processInfo
  let actualModel = processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"]
  let actualVersion = processInfo.operatingSystemVersion.majorVersion

  guard actualModel == simulatorModelIdentifier, actualVersion == iOSMajorVersion else {
    Issue.record(
      Comment(
        rawValue: "Expected \(simulatorModelIdentifier) on iOS \(iOSMajorVersion); "
          + "used \(actualModel ?? "a non-simulator device") on iOS \(actualVersion)."
      )
    )
    return false
  }
  return true
}

@MainActor @Test func testFeature() {
  guard assertSnapshotEnvironment(
    simulatorModelIdentifier: "iPhone15,4",
    iOSMajorVersion: 17
  ) else { return }
  let vc = MyViewController()
  assertSnapshot(of: vc, as: .image)
}
```

Keep the expected values with the tests that need them. This check is intentionally opt-in and can
be extended by clients that also need to validate display scale or color gamut.

Better yet, SnapshotTesting isn't limited to views and view controllers! There are a number of
available snapshot strategies to choose from.

For example, you can snapshot test URL requests (_e.g._, those that your API client prepares).

``` swift
assertSnapshot(of: urlRequest, as: .raw)
// POST http://localhost:8080/account
// Cookie: pf_session={"userId":"1"}
//
// email=blob%40pointfree.co&name=Blob
```

And you can snapshot test `Encodable` values against their JSON _and_ property list representations.

``` swift
assertSnapshot(of: user, as: .json)
// {
//   "bio" : "Blobbed around the world.",
//   "id" : 1,
//   "name" : "Blobby"
// }

assertSnapshot(of: user, as: .plist)
// <?xml version="1.0" encoding="UTF-8"?>
// <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
//  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
// <plist version="1.0">
// <dict>
//   <key>bio</key>
//   <string>Blobbed around the world.</string>
//   <key>id</key>
//   <integer>1</integer>
//   <key>name</key>
//   <string>Blobby</string>
// </dict>
// </plist>
```

In fact, _any_ value can be snapshot-tested using `SnapshotTestingCustomDump`!

``` swift
import SnapshotTestingCustomDump

assertSnapshot(of: user, as: .customDump)
// User(
//   bio: "Blobbed around the world.",
//   id: 1,
//   name: "Blobby"
// )
```

If your data can be represented as an image, text, or data, you can write a snapshot test for it!

## Documentation

Documentation sources stay in this repository. The [central documentation repository](https://github.com/modern-swift-dev/docs) builds and publishes the site daily. Run `make site-build` to generate a local preview in `.build/site`, then `make site-preview` to serve it.

Read the [documentation site](https://modern-swift-dev.github.io/docs/swift-snapshot-testing/) for
guides, examples, release notes, and API documentation for
[SnapshotTesting](https://modern-swift-dev.github.io/docs/swift-snapshot-testing/api/snapshottesting/documentation/snapshottesting/),
[SnapshotPreviews](https://modern-swift-dev.github.io/docs/swift-snapshot-testing/api/snapshotpreviews/documentation/snapshotpreviews/),
[InlineSnapshotTesting](https://modern-swift-dev.github.io/docs/swift-snapshot-testing/api/inlinesnapshottesting/documentation/inlinesnapshottesting/),
and
[CustomDump](https://modern-swift-dev.github.io/docs/swift-snapshot-testing/api/customdump/documentation/customdump/).

## Requirements

Swift 6.3. Apple platforms require iOS 17, macOS 13, tvOS 17, or watchOS 10 or later. CI also
tests Linux and Android.

On watchOS, image snapshots support `UIImage` values and SwiftUI views rendered by `ImageRenderer`.
Pixel precision is supported, but perceptual precision is not. `ImageRenderer` may use placeholders
for views backed by native platform frameworks.

On macOS 13 and later, SwiftUI views support `.image` snapshots rendered at a fixed 2x scale.
The default `sizeThatFits` layout uses the view's ideal size, while `fixed` centers it in the
requested point size. Compare snapshots on the same OS version to avoid system-rendering differences.

## Installation

### Xcode

> **Warning**
> By default, Xcode will try to add the SnapshotTesting package to your project's main
> application/framework target. Please ensure that SnapshotTesting is added to a _test_ target
> instead, as documented in the last step, below.

 1. From the **File** menu, select **Add Package Dependencies…**.
 2. Enter package repository URL: `https://github.com/modern-swift-dev/swift-snapshot-testing`.
 3. Confirm the version and let Xcode resolve the package.
 4. On the final dialog, update SnapshotTesting's **Add to Target** column to a test target that
    will contain snapshot tests (if you have more than one test target, you can later add
    SnapshotTesting to them by manually linking the library in its build phase).

If you reuse SwiftUI previews, add the package's `SnapshotPreviews` product to the application or
framework target that owns those views. Keep the full `SnapshotTesting` product linked only to test
targets.

### Swift Package Manager

If you want to use SnapshotTesting in any other project that uses
[SwiftPM](https://swift.org/package-manager/), add the package as a dependency in `Package.swift`:

```swift
dependencies: [
  .package(
    url: "https://github.com/modern-swift-dev/swift-snapshot-testing",
    branch: "main"
  ),
]
```

Next, add `SnapshotTesting` as a dependency of your test target:

```swift
targets: [
  .target(name: "MyApp"),
  .testTarget(
    name: "MyAppTests",
    dependencies: [
      "MyApp",
      .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
    ]
  )
]
```

To share SwiftUI preview definitions with snapshot tests, add the lightweight `SnapshotPreviews`
product to the source target as well:

```swift
targets: [
  .target(
    name: "MyApp",
    dependencies: [
      .product(name: "SnapshotPreviews", package: "swift-snapshot-testing"),
    ]
  ),
  .testTarget(
    name: "MyAppTests",
    dependencies: [
      "MyApp",
      .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
    ]
  ),
]
```

### Inline snapshots

The package also includes `InlineSnapshotTesting`. Import it and use `assertInlineSnapshot` to
store string snapshots directly in test source files.

### Custom dumps

The package includes `CustomDump`, a collection of tools for dumping, diffing, and testing Swift
values. Add the `CustomDump` product to use its APIs directly.

For snapshot strategies, add the `SnapshotTestingCustomDump` product and import it to use
`.customDump` with snapshot or inline snapshot assertions.

Custom Dump was imported from
[`pointfreeco/swift-custom-dump`](https://github.com/pointfreeco/swift-custom-dump) at commit
[`924df7d`](https://github.com/pointfreeco/swift-custom-dump/commit/924df7d28207eb4f3528e0ef403d24ef3657671c).

## Features

  - [**Dozens of snapshot strategies**][available-strategies]. Snapshot
    testing isn't just for `UIView`s and `CALayer`s. Write snapshots against _any_ value.
  - [**Write your own snapshot strategies**][defining-strategies].
    If you can convert it to an image, string, data, or your own diffable format, you can snapshot
    test it! Build your own snapshot strategies from scratch or transform existing ones.
  - **No configuration required.** Don't fuss with scheme settings and environment variables.
    Snapshots are automatically saved alongside your tests.
  - **Flexible recording.** Missing snapshots are recorded by default. Use `withSnapshotTesting`
    with `.all`, `.failed`, or `.never` to choose another recording mode.
  - **Subclass-free.** Assert from any XCTest case or Quick spec.
  - **Device-agnostic snapshots.** Render views and view controllers for specific devices and trait
    collections from a single simulator.
  - **First-class Xcode support.** Image differences are captured as XCTest attachments. Text
    differences are rendered in inline error messages.
  - **Modern platform support.** Supports iOS 17+, macOS 13+, tvOS 17+, watchOS 10+, Linux, and
    Android.
  - **SceneKit, SpriteKit, and WebKit support.** Most snapshot testing libraries don't support these
    view subclasses.
  - **`Codable` support**. Snapshot encodable data structures into their JSON and property list
    representations.
  - **Custom diff tool integration**. Configure failure messages to print diff commands for
    [Kaleidoscope](https://kaleidoscope.app) or your diff tool of choice.
    ``` swift
    withSnapshotTesting(diffTool: .ksdiff) {
      assertSnapshot(of: vc, as: .image)
    }
    ```

[available-strategies]: https://github.com/modern-swift-dev/swift-snapshot-testing/blob/main/Sources/SnapshotTesting/Documentation.docc/Extensions/Snapshotting.md
[defining-strategies]: https://github.com/modern-swift-dev/swift-snapshot-testing/blob/main/Sources/SnapshotTesting/Documentation.docc/Articles/CustomStrategies.md

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contributor instructions.

## License

This library is released under the MIT license. See [LICENSE](LICENSE) and
[LICENSE-swift-custom-dump](LICENSE-swift-custom-dump) for details.
