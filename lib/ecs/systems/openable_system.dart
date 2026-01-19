import 'dart:developer';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/systems/behavior_system.dart';
import 'package:rogueverse/ecs/systems/system.dart';
import 'package:rogueverse/ecs/world.dart';

part 'openable_system.mapper.dart';

/// System that processes open/close intents for Openable entities.
///
/// Handles:
/// - OpenIntent: Opens the target entity (swaps Renderable, removes blockers)
/// - CloseIntent: Closes the target entity (swaps Renderable, adds blockers)
///
/// The system synchronizes BlocksMovement and BlocksSight components based on
/// the Openable configuration and current state.
@MappableClass()
class OpenableSystem extends System with OpenableSystemMappable {
  static final _logger = Logger('OpenableSystem');

  @override
  Set<Type> get runAfter => {BehaviorSystem};

  @override
  void update(World world) {
    Timeline.timeSync("OpenableSystem: update", () {
      // Process OpenIntent
      final openIntents = Map.from(world.get<OpenIntent>());
      for (final entry in openIntents.entries) {
        final actorId = entry.key;
        final intent = entry.value as OpenIntent;
        final actor = world.getEntity(actorId);
        final target = world.getEntity(intent.targetEntityId);

        actor.remove<OpenIntent>();

        final openable = target.get<Openable>();
        if (openable == null) {
          _logger.warning("open target missing Openable component", {
            "actor": actor,
            "target": target,
          });
          continue;
        }

        if (openable.isOpen) {
          _logger.finest("target already open", {"target": target});
          continue;
        }

        // Open the entity - create new Openable with updated state (don't mutate template)
        target.upsert(Openable(
          isOpen: true,
          openRenderablePath: openable.openRenderablePath,
          closedRenderablePath: openable.closedRenderablePath,
          blocksMovementWhenClosed: openable.blocksMovementWhenClosed,
          blocksVisionWhenClosed: openable.blocksVisionWhenClosed,
        ));
        target.upsert(Renderable(ImageAsset(openable.openRenderablePath)));

        // Remove blocking components
        if (openable.blocksMovementWhenClosed) {
          target.remove<BlocksMovement>();
        }
        if (openable.blocksVisionWhenClosed) {
          target.remove<BlocksSight>();
        }

        actor.upsert(DidOpen(targetEntityId: target.id));
        _logger.fine("opened entity", {"actor": actor, "target": target});
      }

      // Process CloseIntent
      final closeIntents = Map.from(world.get<CloseIntent>());
      for (final entry in closeIntents.entries) {
        final actorId = entry.key;
        final intent = entry.value as CloseIntent;
        final actor = world.getEntity(actorId);
        final target = world.getEntity(intent.targetEntityId);

        actor.remove<CloseIntent>();

        final openable = target.get<Openable>();
        if (openable == null) {
          _logger.warning("close target missing Openable component", {
            "actor": actor,
            "target": target,
          });
          continue;
        }

        if (!openable.isOpen) {
          _logger.finest("target already closed", {"target": target});
          continue;
        }

        // Close the entity - create new Openable with updated state (don't mutate template)
        target.upsert(Openable(
          isOpen: false,
          openRenderablePath: openable.openRenderablePath,
          closedRenderablePath: openable.closedRenderablePath,
          blocksMovementWhenClosed: openable.blocksMovementWhenClosed,
          blocksVisionWhenClosed: openable.blocksVisionWhenClosed,
        ));
        target.upsert(Renderable(ImageAsset(openable.closedRenderablePath)));

        // Add blocking components based on configuration
        if (openable.blocksMovementWhenClosed) {
          target.upsert(BlocksMovement());
        }
        if (openable.blocksVisionWhenClosed) {
          target.upsert(BlocksSight());
        }

        actor.upsert(DidClose(targetEntityId: target.id));
        _logger.fine("closed entity", {"actor": actor, "target": target});
      }
    });
  }
}
