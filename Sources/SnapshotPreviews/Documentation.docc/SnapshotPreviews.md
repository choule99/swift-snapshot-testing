# ``SnapshotPreviews``

Share named SwiftUI views between Xcode previews and snapshot tests.

Declare a concrete type that explicitly conforms to both `PreviewProvider` and
``SnapshotProvider``. Xcode discovers the former, while the latter supplies the reusable snapshots
and a default `previews` implementation.

```swift
struct MyView_Previews: PreviewProvider, SnapshotProvider {
    @SnapshotBuilder
    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("Default") {
            MyView()
        }
    }
}
```

Import `SnapshotTesting` in a test target and pass the provider type to `assertSnapshots(of:)`, or
iterate ``SnapshotProvider/snapshots`` to use custom strategies.

## Topics

### Preview snapshots

- ``PreviewSnapshot``
- ``PreviewSnapshotLayout``
- ``SnapshotBuilder``
- ``SnapshotProvider``
