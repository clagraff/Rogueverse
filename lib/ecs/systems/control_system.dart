import 'dart:developer';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/systems/behavior_system.dart';
import 'package:rogueverse/ecs/systems/system.dart';
import 'package:rogueverse/ecs/world.dart';

part 'control_system.mapper.dart';

/// System that processes control and docking intents.
///
/// Handles:
/// - WantsControlIntent: Grants control of an entity (e.g., vehicle) to an actor
/// - ReleasesControlIntent: Releases control, switching back to actor
/// - DockIntent: Adds Docked component (disables movement/combat)
/// - UndockIntent: Removes Docked component (re-enables movement/combat)
@MappableClass()
class ControlSystem extends System with ControlSystemMappable {
  static final _logger = Logger('ControlSystem');

  @override
  Set<Type> get runAfter => {BehaviorSystem};

  @override
  void update(World world) {
    Timeline.timeSync("ControlSystem: update", () {
      // 1. Process WantsControlIntent - grant control
      final wantsControlMap = world.get<WantsControlIntent>();
      for (final actorId in wantsControlMap.keys) {
        final intent = wantsControlMap[actorId]!;
        final actor = world.getEntity(actorId);
        final targetEntity = world.getEntity(intent.targetEntityId);

        if (targetEntity.has<EnablesControl>()) {
          final enablesControl = targetEntity.get<EnablesControl>()!;
          actor.upsert(Controlling(controlledEntityId: enablesControl.controlledEntityId));
          _logger.fine("actor granted control", {"actor": actor, "controlledEntityId": enablesControl.controlledEntityId});
        }
      }

      // 2. Process ReleasesControlIntent - release control
      final releasesControlMap = world.get<ReleasesControlIntent>();
      for (final controlledEntityId in releasesControlMap.keys) {
        // Find actor controlling this entity
        final controllingMap = world.get<Controlling>();

        for (final actorId in controllingMap.keys) {
          final controlling = controllingMap[actorId]!;
          if (controlling.controlledEntityId == controlledEntityId) {
            world.getEntity(actorId).remove<Controlling>();
            _logger.fine("actor released control", {"actorId": actorId, "controlledEntityId": controlledEntityId});
            break;
          }
        }
      }

      // 3. Process DockIntent - add Docked component
      final dockIntentMap = world.get<DockIntent>();
      for (final entityId in dockIntentMap.keys) {
        world.getEntity(entityId).upsert(Docked());
        _logger.fine("entity docked", {"entityId": entityId});
      }

      // 4. Process UndockIntent - remove Docked component
      final undockIntentMap = world.get<UndockIntent>();
      for (final entityId in undockIntentMap.keys) {
        world.getEntity(entityId).remove<Docked>();
        _logger.fine("entity undocked", {"entityId": entityId});
      }
    });
  }
}
