import 'package:dart_mappable/dart_mappable.dart';
import 'package:rogueverse/ecs/world.dart';

part 'system.mapper.dart';

// TODO: Example of a potentially better way to do Systems
// abstract class ProcessingSystem extends System {
//   // Define a filter method that returns true for entities this system should process
//   bool filter(Entity entity);
//
//   // Process a single entity
//   void process(Entity entity, double dt);
//
//   @override
//   void update(Chunk world) {
//     // Find all entities that match the filter
//     for (final entity in world.entities.where(filter)) {
//       process(entity, world.deltaTime);
//     }
//   }
// }

/// A base class for all systems that operate over a [Chunk] of ECS data.
///
/// Systems execute in (ascending) priority order during World.tick():
/// - 0-50: Early systems (e.g., cache rebuilding, preprocessing)
/// - 100: Normal gameplay systems (default)
/// - 150+: Late systems (e.g., cleanup, post-processing)
@MappableClass()
abstract class System with SystemMappable {
  /// Execution priority. Lower numbers run first. Default is 100.
  int get priority => 100;

  void update(World world);
}

/// A base class for all systems which can operate with a time budget, outside
/// of normal ECS ticks.
@MappableClass()
abstract class BudgetedSystem extends System with BudgetedSystemMappable {
  bool budget(World world, Duration budget); // TODO return boolean to indicate if more processing is needed between game ticks?
}
