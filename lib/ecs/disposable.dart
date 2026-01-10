import 'package:flutter/widgets.dart';

/// A lightweight wrapper around a teardown function, providing a consistent
/// interface for managing and invoking resource cleanup logic.
///
/// This is useful for tracking callbacks, subscriptions, or other disposable
/// resources in a way that is easy to register and clean up later.
///
/// You can also call `.disposeLater()` to automatically register this
/// [Disposable] with a [Disposer] mixin.
class Disposable {
  final void Function() _fn;

  /// Creates a [Disposable] that wraps the given function.
  ///
  /// This function will be called when [dispose] is invoked.
  Disposable(this._fn);

  /// Immediately invokes the wrapped teardown function.
  void dispose() => _fn();

  /// Syntactic sugar to call the teardown function like a regular function.
  void call() => _fn();

  /// Registers this [Disposable] with the provided [Disposer] for automatic
  /// cleanup later (e.g., during `onRemove()` or `dispose()`).
  void disposeLater(Disposer disposer) {
    disposer.toDispose(this);
  }
}

/// A mixin that tracks multiple [Disposable] instances and ensures they
/// are all cleaned up when [disposeAll] is called.
///
/// This is useful in components or objects that manage multiple subscriptions,
/// listeners, or callbacks and want a single teardown method to clean them up.
///
/// Use [toDispose] to register each [Disposable] you want tracked,
/// and call [disposeAll] during the object's lifecycle end.
mixin Disposer on Object {
  final List<Disposable> _disposables = [];

  /// Registers a [Disposable] instance to be cleaned up later.
  void toDispose(Disposable d) {
    _disposables.add(d);
  }

  /// Disposes all registered [Disposable] instances and clears the list.
  @mustCallSuper
  void disposeAll() {
    for (final d in _disposables) {
      d.dispose();
    }
    _disposables.clear();
  }
}

/// Extension to allow a bare `void Function()` to be converted into
/// a [Disposable] instance.
///
/// This is helpful when working with APIs that return an anonymous
/// unsubscribe function.
extension DisposableFunction on void Function() {
  /// Wraps this function in a [Disposable] so it can be registered
  /// with a [Disposer] or manually disposed later.
  Disposable asDisposable() => Disposable(this);
}


T? cast<T>(Object? x) => x is T ? x : null;
void mustBe<T>(Object? x) => x is T == false ? throw Exception("Invalid types") : '';