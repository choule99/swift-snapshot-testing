---
title: "Examples"
description: "Examples for Swift Testing, XCTest, SwiftUI previews, inline snapshots, and CustomDump."
---

Examples

# The same assertion, different tests.

A strategy defines what the test stores and compares. Start with the examples closest to your code.

<a id="images"></a>

## Swift Testing

Use SnapshotTesting in a `@Test`. UI snapshots belong on the main actor.

*SettingsTests.swift*

```swift
import SnapshotTesting
import Testing

@MainActor
struct SettingsTests {
  @Test func settings() {
    assertSnapshot(of: SettingsView(), as: .image)
  }
}
```

## XCTest

The assertion works in existing XCTest suites too. A test target can migrate one test at a time.

*SettingsTests.swift*

```swift
import SnapshotTesting
import XCTest

final class SettingsTests: XCTestCase {
  func testSettings() {
    assertSnapshot(of: SettingsView(), as: .image)
  }
}
```

<a id="previews"></a>

## SwiftUI previews

Define a preview once, then test that provider through SnapshotPreviews.

*ProfilePreview.swift*

```swift
import SnapshotPreviews
import SwiftUI

struct ProfilePreview: PreviewProvider, SnapshotProvider {
  @SnapshotBuilder
  static var snapshots: [PreviewSnapshot] {
    PreviewSnapshot("Default") { ProfileView() }
  }
}
```

*ProfileTests.swift*

```swift
@testable import MyFeature
import SnapshotTesting
import Testing

@MainActor
struct ProfileTests {
  @Test func profiles() {
    assertSnapshots(of: ProfilePreview.self)
  }
}
```

<a id="formats"></a>

## Inline snapshots

For short text output, keep the expected result beside the assertion. The inline module can rewrite it when recording is enabled.

*UserTests.swift*

```swift
import InlineSnapshotTesting

assertInlineSnapshot(of: user, as: .json) {
  """
  { "name" : "Blob" }
  """
}
```

## Custom dumps

Use the CustomDump strategy when a structural representation is more useful than JSON or a screenshot.

*ResponseTests.swift*

```swift
import SnapshotTestingCustomDump

assertSnapshot(of: response, as: .customDump)
```
