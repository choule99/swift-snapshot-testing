# ``SnapshotTesting``

Powerfully flexible snapshot testing.

## Topics

### Essentials

- ``assertSnapshot(of:as:named:options:fileID:file:testName:line:column:)``
- ``SnapshotAssertionOptions``
- <doc:IntegratingWithTestFrameworks>
- <doc:MigrationGuides>

### Strategies

- <doc:CustomStrategies>
- ``Snapshotting``
- ``Diffing``
- ``Async``

### Configuration

- ``Testing/Trait/snapshots(record:diffTool:snapshotNaming:referenceStorage:locale:timeZone:calendar:)``
- ``withSnapshotTesting(record:diffTool:snapshotNaming:referenceStorage:locale:timeZone:calendar:operation:)``
- ``withSnapshotTesting(_:operation:)``
- ``SnapshotTestingConfiguration``
- ``accessedSnapshotPaths``
- ``resetAccessedSnapshotPaths()``

### Image comparison

- ``ImageSnapshotOptions``

### Deprecations

- <doc:SnapshotTestingDeprecations>
