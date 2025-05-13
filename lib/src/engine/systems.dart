import 'components.dart';
import 'ecs.dart';

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

    if (blocks.components.isEmpty) return;

    for (final id in movingEntityIds) {
      final e = world.entity(id);
      final pos = e.get<LocalPosition>();
      final intent = e.get<MoveByIntent>();

      if (pos == null || intent == null) continue;

      final dest = LocalPosition(x: pos.x + intent.dx, y: pos.y + intent.dy);
      var blocked = false;

      positions.components.forEach((key, value) {
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
    final ids = List<int>.from(moveIntents.components.keys);

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
    var sortedSystems = systems
      ..sort((a, b) => a.priority.compareTo(b.priority)); // TODO: move this elsewhere? Just sort once? Or when new systems are added?

    for (var chunk in chunks) {
      chunk.tick(sortedSystems);
    }
  }
}