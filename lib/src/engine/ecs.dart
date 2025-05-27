import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'systems.dart';
import 'entity.dart';

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


T? cast<T>(x) => x is T ? x : null;
void mustBe<T>(x) => x is T == false ? throw Exception("Invalid types") : '';

/// A reusable filter that can be built ahead of time to select
/// entities with specific component requirements.
///
/// You can require components (with optional predicates) or exclude
/// them (also with optional predicates).
///
/// Example:
/// ```dart
/// final query = Query()
///   ..require<LocalPosition>((pos) => pos.x == 3 && pos.y == 5)
///   ..require<Renderable>()
///   ..exclude<PlayerControlled>();
///
/// for (final entity in query.find(chunk)) {
///   // Only entities at (3,5) with Renderable and not PlayerControlled
/// }
/// ```
class Query {
  final Map<Type, bool Function(dynamic comp)?> _required = {};
  final Map<Type, bool Function(dynamic comp)?> _excluded = {};

  /// Require component [T] with optional [predicate].
  Query require<T>([bool Function(T comp)? predicate]) {
    _required[T] =
        predicate != null ? (dynamic comp) => predicate(comp as T) : null;
    return this;
  }

  /// Exclude component [T] with optional [predicate].
  Query exclude<T>([bool Function(T comp)? predicate]) {
    _excluded[T] =
        predicate != null ? (dynamic comp) => predicate(comp as T) : null;
    return this;
  }

  /// Returns all matching entities in the [chunk].
  Iterable<Entity> find(Registry registry) sync* {
    if (_required.isEmpty) {
      throw StateError('Query must have at least one required component.');
    }

    final firstRequiredType = _required.keys.first;
    final store = registry.components.putIfAbsent(firstRequiredType.toString(), () => {});

    for (final id in store.keys) {
      if (isMatching(registry, id)) {
        yield registry.getEntity(id);
      }
    }
  }

  /// Returns matching entities in the [chunk] from the provided list of allowed entity IDs.
  Iterable<Entity> findFromIds(Registry registry, List<int> possibleIds) sync* {
    if (_required.isEmpty) {
      throw StateError('Query must have at least one required component.');
    }

    final firstRequiredType = _required.keys.first;
    final store = registry.components.putIfAbsent(firstRequiredType.toString(), () => {});

    for (final id in store.keys) {
      if (!possibleIds.contains(id)) {
        continue;
      }

      if (isMatching(registry, id)) {
        yield registry.getEntity(id);
      }
    }
  }

  /// Returns the first matching entity or null.
  Entity? first(Registry registry) => find(registry).firstOrNull;

  bool any(Registry registry) => find(registry).firstOrNull != null;


  bool isMatching(Registry registry, int entityId) {
    for (final entry in _required.entries) {
      final type = entry.key;
      final predicate = entry.value;
      final store = registry.components.putIfAbsent(type.toString(), () => {});
      if (!store.containsKey(entityId)) return false;

      if (predicate != null && !predicate(store[entityId])) {
        return false;
      }
    }

    for (final entry in _excluded.entries) {
      final type = entry.key;
      final predicate = entry.value;
      final store = registry.components.putIfAbsent(type.toString(), () => {});
      if (!store.containsKey(entityId)) continue;

      if (predicate == null || predicate(store[entityId])) {
        return false;
      }
    }

    return true;
  }


  /// Returns true if the given [entity] matches the query.
  bool isMatchEntity(Entity entity) => isMatching(entity.parentCell, entity.id);

  /// Returns a copy of this query.
  Query copy() {
    final q = Query();
    q._required.addAll(_required);
    q._excluded.addAll(_excluded);
    return q;
  }
}

/// A template for spawning entities with a predefined set of components.
///
/// This allows you to define reusable "blueprints" for game objects
/// (e.g., a player, wall, item) that can be instantiated multiple times.
///
/// Example:
/// ```dart
/// final playerArchetype = Archetype()
///   ..set(Name(name: 'Player'))
///   ..set(PlayerControlled())
///   ..set(Renderable('images/player.svg'));
///
/// final player = playerArchetype.build(chunk);
/// ```
class Archetype {
  final List<Function(Entity e)> _builders = [];

  /// Adds a component to this archetype.
  ///
  /// This component will be included when [build] is called.
  void set<T>(T comp) {
    _builders.add((Entity e) => e.upsert<T>(comp));
  }

  /// Instantiates a new entity in the given [chunk] using this archetype's components.
  ///
  /// Returns the newly created [Entity].
  Entity build(Registry registry) {
    final e = registry.add([]);

    for (var builder in _builders) {
      builder(e);
    }
    return e;
  }
}