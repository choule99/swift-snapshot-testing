---
title: "Getting started"
description: "Install SnapshotTesting and write your first snapshot test."
---

Getting started

# A snapshot test in a few minutes.

Use SnapshotTesting in a test target. It supports Swift 6.3, iOS 17, macOS 13, tvOS 17, watchOS 10, Linux, and Android. Image snapshots need a native UI framework.

## Install the package

In Xcode, add the package URL to the test target that owns your tests. Swift Package Manager projects can add this dependency:

*Package.swift*

```swift
.package(url: "https://github.com/modern-swift-dev/swift-snapshot-testing", from: "{{version}}")
```

## Write the assertion

Import SnapshotTesting and call `assertSnapshot`. Choose a strategy such as `.image`, `.json`, or `.recursiveDescription`.

*WelcomeTests.swift*

```swift
import SnapshotTesting
import Testing

@MainActor
struct WelcomeTests {
  @Test func welcomeScreen() {
    assertSnapshot(of: WelcomeViewController(), as: .image)
  }
}
```

## Record, then compare

A missing reference is recorded automatically and causes the first run to fail. Review the new file, commit it, then run the test again. The next run compares the current value with that reference.

When you intend to replace a reference, record within the smallest useful scope:

*WelcomeTests.swift*

```swift
withSnapshotTesting(record: .all) {
  assertSnapshot(of: WelcomeViewController(), as: .image)
}
```

## Next: explore the examples

See XCTest, Swift Testing, inline snapshots, and SwiftUI previews in context.

[Open examples](/docs/swift-snapshot-testing/examples/)
