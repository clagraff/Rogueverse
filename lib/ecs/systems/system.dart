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

/// A base class for all systems that operate over a [World] of ECS data.
///
/// ## System Ordering
///
/// Systems declare their dependencies explicitly via [runAfter], which specifies
/// which other systems must execute before this one. The World uses topological
/// sorting to determine execution order at startup.
///
/// Example:
/// ```dart
/// class MovementSystem extends System {
///   @override
///   Set<Type> get runAfter => {CollisionSystem};
///   // MovementSystem will always run after CollisionSystem
/// }
/// ```
///
/// For systems with no dependencies, execution order relative to other
/// independent systems is undefined but consistent within a session.
///
/// Circular dependencies are detected at startup and will throw an error.
@MappableClass()
abstract class System with SystemMappable {
  /// Systems that must run before this one.
  ///
  /// Override this getter to declare dependencies on other systems.
  /// The World will ensure all listed systems execute before this one.
  ///
  /// Returns an empty set by default (no dependencies).
  Set<Type> get runAfter => const {};

  void update(World world);
}

/// A base class for all systems which can operate with a time budget, outside
/// of normal ECS ticks.
@MappableClass()
abstract class BudgetedSystem extends System with BudgetedSystemMappable {
  bool budget(World world, Duration budget); // TODO return boolean to indicate if more processing is needed between game ticks?
}
