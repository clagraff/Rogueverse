import 'dart:developer';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:rogueverse/ecs/systems/system.dart';
import 'package:rogueverse/ecs/world.dart';

part 'hierarchy_system.mapper.dart';

/// System that maintains the hierarchy cache for fast parent-child queries.
///
/// This system rebuilds the World's hierarchyCache each tick from HasParent components.
/// Runs first (priority 0) to ensure cache is fresh for other systems.
@MappableClass()
class HierarchySystem extends System with HierarchySystemMappable {
  @override
  int get priority => 0; // Must run before other systems use hierarchy cache

  @override
  void update(World world) {
    Timeline.timeSync("HierarchySystem: update", () {
      world.hierarchyCache.rebuild(world);
    });
  }
}
