import 'dart:developer';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/systems/crafting_system.dart';
import 'package:rogueverse/ecs/systems/system.dart';
import 'package:rogueverse/ecs/world.dart';

part 'processing_system.mapper.dart';

/// Handles time-based crafting progression.
///
/// Each tick, decrements ticksRemaining on Processing components.
/// When complete, attempts to create outputs and add to inventory.
/// If inventory is full, sets awaitingSpace flag and retries each tick.
@MappableClass()
class ProcessingSystem extends System with ProcessingSystemMappable {
  @override
  Set<Type> get runAfter => {CraftingSystem};

  static final _logger = Logger('ProcessingSystem');

  @override
  void update(World world) {
    Timeline.timeSync("ProcessingSystem: update", () {
      final processing = Map.from(world.get<Processing>());

      for (final entry in processing.entries) {
        final entityId = entry.key;
        final proc = entry.value as Processing;
        final entity = world.getEntity(entityId);

        // Check presence requirement for stations
        final station = entity.get<CraftingStation>();
        if (station != null && station.requiresPresence) {
          // Only tick if initiator is adjacent
          final initiator = world.getEntity(proc.initiatorEntityId);
          if (!_isAdjacent(entity, initiator)) {
            _logger.finest('processing paused: initiator not adjacent', {
              'entity': entityId,
              'initiator': proc.initiatorEntityId,
            });
            continue; // Skip this tick
          }
        }

        if (proc.awaitingSpace) {
          // Try to complete again
          _tryComplete(world, entity, proc);
        } else if (proc.ticksRemaining <= 1) {
          // Ready to complete
          _tryComplete(world, entity, proc);
        } else {
          // Tick down
          entity.upsert(Processing(
            recipeTemplateId: proc.recipeTemplateId,
            ticksRemaining: proc.ticksRemaining - 1,
            initiatorEntityId: proc.initiatorEntityId,
          ));
          _logger.finest('processing tick', {
            'entity': entityId,
            'remaining': proc.ticksRemaining - 1,
          });
        }
      }
    });
  }

  bool _isAdjacent(Entity a, Entity b) {
    final posA = a.get<LocalPosition>();
    final posB = b.get<LocalPosition>();
    if (posA == null || posB == null) return false;

    final dx = (posA.x - posB.x).abs();
    final dy = (posA.y - posB.y).abs();
    return dx <= 1 && dy <= 1;
  }

  void _tryComplete(World world, Entity entity, Processing proc) {
    final recipeTemplate = world.getEntity(proc.recipeTemplateId);
    final recipe = recipeTemplate.get<Recipe>();
    if (recipe == null) {
      _logger.warning('processing complete but recipe not found', {
        'entity': entity.id,
        'recipeId': proc.recipeTemplateId,
      });
      entity.remove<Processing>();
      entity.remove<Busy>();
      return;
    }

    // Check if outputs will fit
    final inventory = entity.get<Inventory>() ?? Inventory([]);
    final maxCount = entity.get<InventoryMaxCount>();
    final totalOutputs = recipe.outputs.fold<int>(0, (sum, o) => sum + o.quantity);

    if (maxCount != null &&
        inventory.items.length + totalOutputs > maxCount.maxAmount) {
      // Can't fit - stall
      entity.upsert(Processing(
        recipeTemplateId: proc.recipeTemplateId,
        ticksRemaining: 0,
        initiatorEntityId: proc.initiatorEntityId,
        awaitingSpace: true,
      ));
      _logger.fine('processing stalled: awaiting space', {
        'entity': entity.id,
        'recipeId': proc.recipeTemplateId,
      });
      return;
    }

    // Create outputs
    final produced = <int>[];
    for (final output in recipe.outputs) {
      for (var i = 0; i < output.quantity; i++) {
        final item = world.add([FromTemplate(output.templateId)]);
        produced.add(item.id);
      }
    }

    entity.upsert(Inventory([...inventory.items, ...produced]));
    entity.remove<Processing>();
    entity.remove<Busy>(); // In case of inventory crafting

    // Notify completion on the entity
    entity.upsert(DidCompleteCrafting(
      recipeTemplateId: proc.recipeTemplateId,
      producedEntityIds: produced,
    ));

    // Also notify initiator if different
    if (proc.initiatorEntityId != entity.id) {
      final initiator = world.getEntity(proc.initiatorEntityId);
      initiator.upsert(DidCompleteCrafting(
        recipeTemplateId: proc.recipeTemplateId,
        producedEntityIds: produced,
      ));
    }

    _logger.fine('processing completed', {
      'entity': entity.id,
      'recipe': proc.recipeTemplateId,
      'produced': produced,
    });
  }
}
