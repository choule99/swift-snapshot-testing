# ``SnapshotPreviews``

Share named SwiftUI views between Xcode previews and snapshot tests.

Declare a concrete type that explicitly conforms to both `PreviewProvider` and
``SnapshotProvider``. Xcode discovers the former, while the latter supplies the reusable snapshots
and a default `previews` implementation.

```swift
struct MyView_Previews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    @SnapshotBuilder
    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("Default") {
            MyView()
        }
    }
}
```

Import `SnapshotTesting` in a test target and pass the provider type to `assertSnapshots(of:)`, or
iterate ``SnapshotProvider/resolvedSnapshots`` to use custom strategies with provider layout
defaults applied. The raw ``SnapshotProvider/snapshots`` collection remains available when the
declaration metadata is needed directly.

Transform the views in one snapshot with ``PreviewSnapshot/mapView(_:)`` or in a collection with
``Swift/Collection/transformingViews(_:)``. Transformations preserve snapshot metadata and affect
both Xcode previews and snapshot assertions.

## Topics

### Preview snapshots

- ``PreviewSnapshot``
- ``PreviewSnapshotLayout``
- ``SnapshotBuilder``
- ``SnapshotProvider``
