import 'package:meta/meta.dart';

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

/// Base class for components with a limited lifespan that can expire
/// after a certain number of ticks. When lifetime reaches 0, the component
/// is removed when processed.
abstract class Lifetime {
  int _lifetime;

  Lifetime(this._lifetime);

  /// Remaining lifetime of the current component.
  int get lifetime => _lifetime;

  /// Check if the lifetime of the current component has expired.
  /// Otherwise, decrement it by one.
  bool tick() {
    if (_lifetime <= 0) return true;
    _lifetime--;
    return false;
  }
}

/// Component that is removed before a tick update if its [lifetime]
/// has expired.
///
/// Used for temporary effects that should be cleared at start of tick.
abstract class BeforeTick extends Lifetime {
  BeforeTick([super.lifetime = 0]);
}

/// Component that is removed after a tick update if its [lifetime]
/// has expired.
///
/// Used for temporary effects that should be cleared at end of tick.
abstract class AfterTick extends Lifetime {
  AfterTick([super.lifetime = 0]);
}

/// A user-friendly, non-unique label for an entity.
///
/// Useful for debugging, UI display, or tagging entities.
class Name {
  final String name;

  Name({required this.name});
}

/// The grid-based position of an entity within the game world.
///
/// Currently represents a global position until region support is added.
class LocalPosition {
  final int x, y;

  LocalPosition({required this.x, required this.y});
}

/// Component that signals an intent to move the entity by a relative offset.
class MoveByIntent extends AfterTick {
  final int dx, dy;

  MoveByIntent({required this.dx, required this.dy});
}

/// Component added when an entity has successfully moved in a tick.
///
/// Stores the previous and new positions for downstream logic.
class DidMove extends BeforeTick {
  final LocalPosition from, to;

  DidMove({required this.from, required this.to}) : super(1);
}

/// Marker component indicating this entity blocks movement.
class BlocksMovement {}

/// Component added when an entity's movement was blocked by another entity.
class BlockedMove extends BeforeTick {
  final LocalPosition attempted;

  BlockedMove(this.attempted);
}

/// Marker component indicating the entity is controlled by the player.
class PlayerControlled {}

class AiControlled {}

/// Component that provides a visual asset path for rendering the entity.
class Renderable {
  final String svgAssetPath;

  Renderable(this.svgAssetPath);
}

class Transaction {
  final Chunk chunk;
  final int entityId;
  final List<void Function()> _handlers = [];

  Transaction(this.chunk, this.entityId);

  void set<T>(T value) {
    final store = chunk.components<T>();
    final isInit = !store.has(entityId);
    store.unhandledSet(entityId, value);

    if (isInit) {
      store._initCallbacks[entityId]
          ?.forEach((cb) => _handlers.add(() => cb(entityId, value)));
      for (final cb in store._anyInitCallbacks) {
        _handlers.add(() {
          cb(entityId, value);
        });
      }
    }
    store._setCallbacks[entityId]
        ?.forEach((cb) => _handlers.add(() => cb(entityId, value)));
    for (final cb in store._anySetCallbacks) {
      _handlers.add(() => cb(entityId, value));
    }
  }

  void remove<T>() {
    final store = chunk.components<T>();
    final old = store.get(entityId);
    store.unhandledRemove(entityId);

    store._removeCallbacks[entityId]
        ?.forEach((cb) => _handlers.add(() => cb(entityId, old)));
    for (final cb in store._anyRemoveCallbacks) {
      _handlers.add(() => cb(entityId, old));
    }
  }

  void commit() {
    for (final h in _handlers) h();
    _handlers.clear();
  }
}

/// Stores and manages multiple components of type [T] mapped to entity IDs.
class ComponentStorage<T> {
  final Map<int, T> _comps = {};

  final Map<int, List<void Function(int entityId, T comp)>> _setCallbacks = {};
  final Map<int, List<void Function(int entityId, T comp)>> _initCallbacks = {};
  final Map<int, List<void Function(int entityId, T? comp)>> _removeCallbacks = {};

  final List<void Function(int entityId, T comp)> _anySetCallbacks = [];
  final List<void Function(int entityId, T comp)> _anyInitCallbacks = [];
  final List<void Function(int entityId, T? comp)> _anyRemoveCallbacks = [];

  T? get(int id) => _comps[id];

  List<int> get ids {
    return _comps.keys.toList();
  }

  void unhandledSet(int id, T c) {
    _comps[id] = c;
  }

  void set(int id, T c) {
    var isInit = _comps[id] == null;

    _comps[id] = c;

    if (isInit) {
      _initCallbacks[id]?.forEach((fn) => fn(id, c));
      for (final fn in _anyInitCallbacks) {
        fn(id, c);
      }
    }

    _setCallbacks[id]?.forEach((fn) => fn(id, c));
    for (final fn in _anySetCallbacks) {
      fn(id, c);
    }
  }

  void unhandledRemove(int id) {
    _comps.remove(id);
  }

  void remove(int id) {
    final c = _comps.remove(id);
    _removeCallbacks[id]?.forEach((fn) => fn(id, c));
    for (final fn in _anyRemoveCallbacks) {
      fn(id, c);
    }
  }

  bool has(int id) => _comps.containsKey(id);

  void Function() onSet(int id, void Function(int entityId, T comp) fn) {
    _setCallbacks[id] ??= [];
    _setCallbacks[id]!.add(fn);
    return () => _setCallbacks[id]?.remove(fn);
  }

  void Function() onSetAny(void Function(int entityId, T comp) fn) {
    _anySetCallbacks.add(fn);
    return () => _anySetCallbacks.remove(fn);
  }


  void Function() onInit(int id, void Function(int entityId, T comp) fn) {
    _initCallbacks[id] ??= [];
    _initCallbacks[id]!.add(fn);
    return () => _initCallbacks[id]?.remove(fn);
  }

  void Function() onInitAny(void Function(int entityId, T comp) fn) {
    _anyInitCallbacks.add(fn);
    return () => _anyInitCallbacks.remove(fn);
  }

  void Function() onRemove(int id, void Function(int entityId, T? comp) fn) {
    _removeCallbacks[id] ??= [];
    _removeCallbacks[id]!.add(fn);
    return () => _removeCallbacks[id]?.remove(fn);
  }

  void Function() onRemoveAny(void Function(int entityId, T? comp) fn) {
    _anyRemoveCallbacks.add(fn);
    return () => _anyRemoveCallbacks.remove(fn);
  }
}

/// A utility wrapper around an entity ID, scoped to a specific [Chunk].
///
/// Provides convenience methods to access and mutate components
/// for the associated entity.
class Entity {
  final Chunk world;
  final int id;

  Entity(this.world, this.id);

  T? get<T>() => world.components<T>().get(id);

  void set<T>(T c) => world.components<T>().set(id, c);

  void remove<T>() => world.components<T>().remove(id);
  void destroy() => world.destroy(id);

  bool has<T>() => world.components<T>().has(id);

  bool has2<T1, T2>() =>
      world.components<T1>().has(id) && world.components<T2>().has(id);

  void Function() onSet<T>(void Function(int entityId, T comp) fn) =>
      world.components<T>().onSet(id, fn);

  void Function() onRemove<T>(void Function(int entityId, T? comp) fn) =>
      world.components<T>().onRemove(id, fn);

  void Function() onDelete(Function(int entityId) fn) {
    return world.onDestroy((e) => {
      if (e == id) {
        fn(id)
      }
    });
  }

  /// Registers a callback to be fired when this entity satisfies [query]
  /// due to a component being set.
  Disposable onSetQuery(Query query, void Function(Entity entity) fn) {
    return world.onSetQuery(query, (e) {
      if (e.id == id) fn(e);
    });
  }

  /// Registers a callback to be fired when this entity satisfies [query]
  /// due to a component being initialized for the first time.
  Disposable onInitQuery(Query query, void Function(Entity entity) fn) {
    return world.onInitQuery(query, (e) {
      if (e.id == id) fn(e);
    });
  }
}


// Replace the _stores map to use string keys instead of Type keys
final Map<String, ComponentStorage> _stores = {};

// Replace _typeName function for consistency
String _typeName<T>() => T.toString();


/// A container for entities and their components that provides methods for creation,
/// component access, and querying.
///
/// This is the primary data structure for storing and updating ECS state.
class Chunk {
  int _nextId = 0;
  final Map<Type, ComponentStorage> _stores = {};

  final List<void Function(Chunk chunk)> _onPreTick = [];
  final List<void Function(Chunk chunk)> _onPostTick = [];

  final List<void Function(int entityId)> _onCreate = [];
  final List<void Function(int entityId)> _onDestroy = [];


  void Function() onBeforeTick(Function(Chunk chunk) fn) {
    _onPreTick.add(fn);
    return () => _onPreTick.remove(fn);
  }

  void Function() onAfterTick(Function(Chunk chunk) fn) {
    _onPostTick.add(fn);
    return () => _onPostTick.remove(fn);
  }

  void Function() onCreate(Function(int entityId) fn) {
    _onCreate.add(fn);
    return () => _onCreate.remove(fn);
  }

  void Function() onDestroy(Function(int entityId) fn) {
    _onDestroy.add(fn);
    return () => _onDestroy.remove(fn);
  }

  int create() {
    var entityId = _nextId++;
    for (var fn in _onCreate) {
      fn(entityId);
    }

    return entityId;
  }

  void createWithId(int id) {
    _nextId = _nextId < id ? id + 1 : _nextId;
    for (var fn in _onCreate) {
      fn(id);
    }
  }

  /// Removes all components associated with the given [entityId].
  /// This effectively deletes the entity from the ECS.
  ///
  /// This will invoke all `onRemove` and `onRemoveAny` handlers for each component type.
  void destroy(int entityId) {
    for (var fn in _onDestroy) {
      fn(entityId);
    }

    for (final store in _stores.values) {
      if (store.has(entityId)) {
        store.remove(entityId);
      }
    }
  }


  ComponentStorage<T> components<T>() =>  _stores[T] as ComponentStorage<T>;
  void register<T>() =>  _stores.putIfAbsent(T, () => ComponentStorage<T>()) as ComponentStorage<T>;

  ComponentStorage componentsByType(Type t) => _stores[t] as ComponentStorage;

  void Function() onSet<T>(int entityId, void Function(int, T) fn) =>
      components<T>().onSet(entityId, fn);

  void Function() onSetAny<T>(void Function(int, T) fn) =>
      components<T>().onSetAny(fn);

  void Function() onInit<T>(int entityId, void Function(int, T) fn) =>
      components<T>().onInit(entityId, fn);

  void Function() onInitAny<T>(void Function(int, T) fn) =>
      components<T>().onInitAny(fn);

  void Function() onRemove<T>(int entityId, void Function(int, T?) fn) =>
      components<T>().onRemove(entityId, fn);

  void Function() onRemoveAny<T>(void Function(int, T?) fn) =>
      components<T>().onRemoveAny(fn);

  /// Registers a callback to be fired when an entity satisfies [query]
  /// as a result of any component being added.
  Disposable onSetQuery(Query query, void Function(Entity entity) fn) {
    final disposables = <Disposable>[];

    for (final entry in query._required.entries) {
      final type = entry.key;
      final predicate = entry.value;
      final store = componentsByType(type);

      if (store != null) {
        final disposer = store.onSetAny((id, comp) {
          // Only proceed if this specific component satisfies its predicate
          if (predicate != null && !predicate(comp)) return;

          final entity = this.entity(id);
          if (query.isMatchEntity(entity)) {
            fn(entity);
          }
        });
        disposables.add(disposer.asDisposable());
      }
    }

    return Disposable(() {
      for (final d in disposables) {
        d.dispose();
      }
    });
  }


  /// Registers a callback to be fired when an entity satisfies [query]
  /// as a result of any component being added.
  ///
  /// TODO: add a comment about how only the _last_ added component needs "initialized".
  /// If the other components were already set or intialized doesnt matter, only that the _last_ one
  /// is set as initailized.
  Disposable onInitQuery(Query query, void Function(Entity entity) fn) {
    final disposables = <Disposable>[];

    for (final entry in query._required.entries) {
      final type = entry.key;
      final predicate = entry.value;
      final store = componentsByType(type);
      if (store != null) {
        final disposer = store.onInitAny((id, comp) {
          // Only check the entity if this specific component matches its predicate
          if (predicate != null && !predicate(comp)) return;

          final entity = this.entity(id);
          if (query.isMatchEntity(entity)) {
            fn(entity);
          }
        });
        disposables.add(disposer.asDisposable());
      }
    }

    return Disposable(() {
      for (final d in disposables) {
        d.dispose();
      }
    });
  }


  T? get<T>(int id) => components<T>().get(id);

  void set<T>(int id, T c) => components<T>().set(id, c);

  void remove<T>(int id) => components<T>().remove(id);

  bool has<T>(int id) => components<T>().has(id);

  void clearLifetimeComponents<T extends Lifetime>() {
    final store = _stores[T];
    if (store == null) return;

    final idsToRemove = <int>[];

    for (final entry in store._comps.entries) {
      final component = entry.value as Lifetime;
      if (component.tick()) {
        idsToRemove.add(entry.key);
      }
    }

    for (final id in idsToRemove) {
      store._comps.remove(id);
    }
  }

  Entity entity(int id) => Entity(this, id);

  Iterable<Entity> entitiesWith<A>() sync* {
    final a = components<A>();
    for (final id in a._comps.keys) {
      yield Entity(this, id);
    }
  }

  Iterable<Entity> entitiesWith2<A, B>() sync* {
    final a = components<A>();
    final b = components<B>();
    for (final id in a._comps.keys) {
      if (b._comps.containsKey(id)) {
        yield Entity(this, id);
      }
    }
  }
}

/// A base class for all systems that operate over a [Chunk] of ECS data.
abstract class System {
  static const int defaultPriority = 1;

  /// Systems are executed in ascending order of priority.
  int get priority => System.defaultPriority;

  /// Called once per tick to apply logic to the given [world].
  void update(Chunk world);
}

/// A system that handles collision detection by checking for blocked movement.
///
/// If an entity attempts to move into an occupied tile, its move is cancelled.
class CollisionSystem extends System {
  @override
  int get priority => 1;

  @override
  void update(Chunk world) {
    final positions = world.components<LocalPosition>();
    final blocks = world.components<BlocksMovement>();
    final moveIntents = world.components<MoveByIntent>();

    final movingEntityIds = moveIntents.ids;

    if (blocks._comps.isEmpty) return;

    for (final id in movingEntityIds) {
      final e = world.entity(id);
      final pos = e.get<LocalPosition>();
      final intent = e.get<MoveByIntent>();

      if (pos == null || intent == null) continue;

      final dest = LocalPosition(x: pos.x + intent.dx, y: pos.y + intent.dy);
      var blocked = false;

      positions._comps.forEach((key, value) {
        if (value.x == dest.x && value.y == dest.y &&
            world.has<BlocksMovement>(key)) {
          blocked = true;
        }
      });

      if (blocked) {
        e.set(BlockedMove(dest));
        e.remove<MoveByIntent>();
      }
    }
  }
}

/// A system that processes unblocked movement requests.
///
/// Updates positions and adds [DidMove] to track movement history.
class MovementSystem extends System {
  @override
  int get priority => CollisionSystem().priority + 1;

  @override
  void update(Chunk world) {
    final moveIntents = world.components<MoveByIntent>();
    final ids = List<int>.from(moveIntents._comps.keys);

    for (final id in ids) {
      final e = world.entity(id);
      final pos = e.get<LocalPosition>();
      final intent = e.get<MoveByIntent>();
      if (pos == null || intent == null) continue;

      final from = LocalPosition(x: pos.x, y: pos.y);
      final to = LocalPosition(x: pos.x + intent.dx, y: pos.y + intent.dy);
      e.set(to);
      e.set(DidMove(from: from, to: to));
      e.remove<MoveByIntent>();
    }
  }
}

/// A high-level coordinator that advances ECS game logic by executing systems.
class GameEngine {
  final List<Chunk> chunks;
  final List<System> systems;

  GameEngine(this.chunks, this.systems);

  /// Executes a single ECS update tick.
  void tick() {
    for (var chunk in chunks) {
      chunk._onPreTick.forEach((fn) => fn(chunk));
      chunk.clearLifetimeComponents<BeforeTick>();

      systems
        ..sort((a, b) => a.priority.compareTo(b.priority))
        ..forEach((s) => s.update(chunk));

      chunk.clearLifetimeComponents<AfterTick>();
    }
  }
}

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
    _required[T] = predicate != null
        ? (dynamic comp) => predicate(comp as T)
        : null;
    return this;
  }

  /// Exclude component [T] with optional [predicate].
  Query exclude<T>([bool Function(T comp)? predicate]) {
    _excluded[T] = predicate != null
        ? (dynamic comp) => predicate(comp as T)
        : null;
    return this;
  }

  /// Returns all matching entities in the [chunk].
  Iterable<Entity> find(Chunk chunk) sync* {
    if (_required.isEmpty) {
      throw StateError('Query must have at least one required component.');
    }

    final firstRequiredType = _required.keys.first;
    final store = chunk.componentsByType(firstRequiredType);

    for (final id in store._comps.keys) {
      if (isMatching(chunk, id)) {
        yield chunk.entity(id);
      }
    }
  }

  /// Returns the first matching entity or null.
  Entity? first(Chunk chunk) => find(chunk).firstOrNull;

  /// Returns true if the given [entityId] matches the query.
  bool isMatching(Chunk chunk, int entityId) {
    for (final entry in _required.entries) {
      final type = entry.key;
      final predicate = entry.value;
      final store = chunk.componentsByType(type);
      if (store == null || !store.has(entityId)) return false;

      if (predicate != null && !predicate(store.get(entityId))) {
        return false;
      }
    }

    for (final entry in _excluded.entries) {
      final type = entry.key;
      final predicate = entry.value;
      final store = chunk.componentsByType(type);
      if (store == null || !store.has(entityId)) continue;

      if (predicate == null || predicate(store.get(entityId))) {
        return false;
      }
    }

    return true;
  }

  /// Returns true if the given [entity] matches the query.
  bool isMatchEntity(Entity entity) => isMatching(entity.world, entity.id);

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
    _builders.add((Entity e) => e.set<T>(comp));
  }

  /// Instantiates a new entity in the given [chunk] using this archetype's components.
  ///
  /// Returns the newly created [Entity].
  Entity build(Chunk chunk) {
    final id = chunk.create();
    final e = Entity(chunk, id);

    for (var builder in _builders) {
      builder(e);
    }
    return e;
  }
}
