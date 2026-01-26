/// Barrel file for all ECS systems
///
/// Systems are executed in dependency order determined by their `runAfter` declarations.
/// The World performs a topological sort at startup to determine execution order.
library;

export 'system.dart';
export 'collision_system.dart';
export 'movement_system.dart';
export 'direction_system.dart';
export 'inventory_system.dart';
export 'combat_system.dart';
export 'behavior_system.dart';
export 'vision_system.dart';
export 'control_system.dart';
export 'openable_system.dart';
export 'portal_system.dart';
export 'dialog_system.dart';
export 'save_system.dart';
