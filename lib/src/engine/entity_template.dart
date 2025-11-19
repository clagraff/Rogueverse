import 'components.dart';

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
class EntityTemplate {
  EntityTemplate();

  final List<void Function(Entity)> _builders = [];

  void set<C extends Comp>(C comp) {
    _builders.add((Entity e) => e.upsert<C>(comp));
  }

  void merge(EntityTemplate other) {
    _builders.addAll(other._builders);
  }

  Entity build(Registry registry, {List<dynamic> baseComponents = const []}) {
    final e = registry.add([...baseComponents]);
    for (final builder in _builders) {
      builder(e);
    }
    return e;
  }

  List<Entity> buildMany(Registry registry, int count) {
    return List.generate(count, (_) => build(registry));
  }

  EntityTemplate clone() {
    final copy = EntityTemplate();
    copy._builders.addAll(_builders);
    return copy;
  }
}
