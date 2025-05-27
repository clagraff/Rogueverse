import 'entity.dart';
import 'registry.dart';

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