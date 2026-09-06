---
title: "Swift snapshot testing"
description: "Snapshot testing for Swift projects, with image, text, and custom strategies."
---

A modern Swift testing library

# Catch changes your assertions cannot see.

SnapshotTesting compares a value with a stored reference. Test UIKit and SwiftUI screens, JSON, requests, dumps, and the formats that matter to your project.

[Get started](/docs/swift-snapshot-testing/documentation/getting-started/)

[Browse examples](/docs/swift-snapshot-testing/examples/)

## Latest stable release

{{version}}

Published {{releaseDate}}

Swift Package Manager: `.upToNextMajor(from: "{{version}}")`

[Release notes]({{releaseURL}})

One assertion, a useful result

## Start with the test you already wanted to write.

The first run records a missing reference and tells you where it went. Later runs compare against that file and point to the difference when the value changes.

*ProfileTests.swift*

```swift
import SnapshotTesting
import Testing

@MainActor
struct ProfileTests {
  @Test func profileCard() {
    assertSnapshot(of: ProfileCard(), as: .image)
  }
}
```

Reference = Current: a reference snapshot matching the current rendering.

References that stay readable

## See the change. Keep the proof.

Snapshot files live beside tests by default. They are ordinary files, easy to review in a pull request and simple to update when a visual change is intentional.

What it tests

[Images](/docs/swift-snapshot-testing/examples/#images) — Render UIKit and SwiftUI views at the devices and traits you choose.

[Text formats](/docs/swift-snapshot-testing/examples/#formats) — Compare JSON, property lists, raw requests, and recursive descriptions.

[SwiftUI previews](/docs/swift-snapshot-testing/examples/#previews) — Reuse preview definitions in tests with SnapshotPreviews.

[Your own values](/docs/swift-snapshot-testing/api/snapshottesting/documentation/snapshottesting/) — Write a snapshot strategy for data that has a stable representation.

Built for current Swift

## Swift 6.3, Apple platforms, Linux, and Android.

Image rendering uses native platform frameworks. Text and data snapshots work wherever Swift does.

[Read the documentation](/docs/swift-snapshot-testing/documentation/)

A maintained fork

## Built on Point-Free's original SnapshotTesting.

This project continues the library created by [Point-Free](https://github.com/pointfreeco/swift-snapshot-testing), with Swift 6 support and active maintenance by Modern Swift Development.

Snapshot testing for Swift projects. Maintained by Modern Swift Development.
