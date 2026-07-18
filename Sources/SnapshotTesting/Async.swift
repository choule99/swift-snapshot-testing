/// A wrapper around an asynchronous operation.
///
/// Snapshot strategies may utilize this type to create snapshots in an asynchronous fashion.
///
/// For example, WebKit's `WKWebView` offers a callback-based API for taking image snapshots
/// (`takeSnapshot`). `Async` allows us to build a value that can pass its callback along to the
/// scope in which the image has been created.
///
/// ```swift
/// Async<UIImage> { callback in
///   webView.takeSnapshot(with: nil) { image, error in
///     callback(image!)
///   }
/// }
/// ```
public struct Async<Value>: Sendable {
    public let run: @MainActor @Sendable (@escaping @MainActor @Sendable (Value) -> Void) -> Void

    /// Creates an asynchronous operation.
    ///
    /// - Parameters:
    ///   - run: A function that, when called, can hand a value to a callback.
    public init(
        run: @escaping @MainActor @Sendable (
            _ callback: @escaping @MainActor @Sendable (Value) -> Void
        ) -> Void
    ) {
        self.run = run
    }

    /// Wraps a pure value in an asynchronous operation.
    ///
    /// - Parameter value: A value to be wrapped in an asynchronous operation.
    @MainActor public init(value: Value) {
        self.init { callback in callback(value) }
    }

    /// Transforms an `Async<Value>` into an `Async<NewValue>` with a function `(Value) -> NewValue`.
    ///
    /// - Parameter transform: A transformation to apply to the value wrapped by the async value.
    public func map<NewValue>(
        _ transform: @escaping @MainActor @Sendable (Value) -> NewValue
    ) -> Async<NewValue> {
        .init { callback in
            self.run { value in callback(transform(value)) }
        }
    }
}
