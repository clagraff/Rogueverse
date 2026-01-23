import 'dart:developer';
import 'dart:math';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/systems/combat_system.dart';
import 'package:rogueverse/ecs/systems/system.dart';
import 'package:rogueverse/ecs/world.dart';

part 'death_system.mapper.dart';

/// System that processes dead entities and spawns their loot.
///
/// Runs after CombatSystem to handle entities that were killed this tick.
/// For each entity with the [Dead] component:
/// 1. If it has a [LootTable], selects items via weighted random
/// 2. Spawns item entities at the dead entity's position
/// 3. Removes the dead entity from the world
@MappableClass()
class DeathSystem extends System with DeathSystemMappable {
  @override
  Set<Type> get runAfter => {CombatSystem};

  static final _logger = Logger('DeathSystem');
  final Random _random = Random();

  @override
  void update(World world) {
    Timeline.timeSync("DeathSystem: update", () {
      final deadEntities = world.get<Dead>();

      // Process a copy of the map to avoid concurrent modification
      final deadEntityIds = deadEntities.keys.toList();

      for (final entityId in deadEntityIds) {
        final entity = world.getEntity(entityId);

        // Get position and parent for spawning loot
        final position = entity.get<LocalPosition>();
        final parent = entity.get<HasParent>();

        _logger.fine('processing dead entity', {
          'entityId': entityId,
          'hasPosition': position != null,
          'hasParent': parent != null,
        });

        // Check for loot table
        final lootTable = entity.get<LootTable>();
        if (lootTable != null && position != null) {
          _spawnLoot(world, lootTable, position, parent?.parentEntityId);
        }

        // Remove the dead entity from the world
        world.remove(entityId);
        _logger.fine('removed dead entity', {'entityId': entityId});
      }
    });
  }

  /// Spawns loot items based on the loot table's weighted random selection.
  void _spawnLoot(
    World world,
    LootTable lootTable,
    LocalPosition position,
    int? parentId,
  ) {
    if (lootTable.entries.isEmpty) return;

    // Calculate total weight
    final totalWeight = lootTable.entries.fold<int>(
      0,
      (sum, entry) => sum + entry.weight,
    );

    if (totalWeight <= 0) return;

    // Spawn dropCount items
    for (var i = 0; i < lootTable.dropCount; i++) {
      final selectedEntry = _selectWeightedRandom(lootTable.entries, totalWeight);
      if (selectedEntry != null) {
        _spawnItemFromTemplate(
          world,
          selectedEntry.templateId,
          position,
          parentId,
        );
      }
    }
  }

  /// Selects a random entry from the loot table based on weights.
  LootEntry? _selectWeightedRandom(List<LootEntry> entries, int totalWeight) {
    var roll = _random.nextInt(totalWeight);

    for (final entry in entries) {
      roll -= entry.weight;
      if (roll < 0) {
        return entry;
      }
    }

    // Fallback to last entry (shouldn't happen with valid weights)
    return entries.lastOrNull;
  }

  /// Spawns an item entity from a template at the given position.
  void _spawnItemFromTemplate(
    World world,
    int templateId,
    LocalPosition position,
    int? parentId,
  ) {
    // Verify the template exists
    try {
      final templateEntity = world.getEntity(templateId);
      if (!templateEntity.has<IsTemplate>()) {
        _logger.warning('loot template is not a template', {
          'templateId': templateId,
        });
        return;
      }

      // Create a new entity that inherits from the template
      final components = <Component>[
        FromTemplate(templateId),
        LocalPosition(x: position.x, y: position.y),
      ];

      if (parentId != null) {
        components.add(HasParent(parentId));
      }

      final itemEntity = world.add(components);

      final itemName = itemEntity.get<Name>()?.name ?? 'item';
      _logger.fine('spawned loot item', {
        'itemEntityId': itemEntity.id,
        'templateId': templateId,
        'itemName': itemName,
        'position': '(${position.x}, ${position.y})',
      });
    } catch (e) {
      _logger.warning('failed to spawn loot from template', {
        'templateId': templateId,
        'error': e.toString(),
      });
    }
  }
}
