import 'dart:developer';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/systems/behavior_system.dart';
import 'package:rogueverse/ecs/systems/system.dart';
import 'package:rogueverse/ecs/world.dart';

part 'crafting_system.mapper.dart';

/// Processes crafting intents (CraftIntent and StationCraftIntent).
///
/// For instant crafts (craftingTicks <= 1), immediately consumes ingredients
/// and creates outputs. For time-based crafts, adds Processing component
/// (and Busy for inventory crafts) to track progress.
@MappableClass()
class CraftingSystem extends System with CraftingSystemMappable {
  @override
  Set<Type> get runAfter => {BehaviorSystem};

  static final _logger = Logger('CraftingSystem');

  @override
  void update(World world) {
    Timeline.timeSync("CraftingSystem: update", () {
      _processDirectCraftIntents(world);
      _processStationCraftIntents(world);
    });
  }

  void _processDirectCraftIntents(World world) {
    final intents = Map.from(world.get<CraftIntent>());

    for (final entry in intents.entries) {
      final crafterId = entry.key;
      final intent = entry.value as CraftIntent;
      final crafter = world.getEntity(crafterId);

      crafter.remove<CraftIntent>();

      // Validate recipe
      final recipeTemplate = world.getEntity(intent.recipeTemplateId);
      final recipe = recipeTemplate.get<Recipe>();
      if (recipe == null) {
        crafter.upsert(CraftingFailed(
          recipeTemplateId: intent.recipeTemplateId,
          reason: CraftingFailureReason.recipeNotFound,
        ));
        _logger.fine('craft failed: recipe not found', {
          'crafter': crafterId,
          'recipeId': intent.recipeTemplateId,
        });
        continue;
      }

      // Must be inventory-craftable (empty capabilities)
      if (recipe.requiredCapabilities.isNotEmpty) {
        crafter.upsert(CraftingFailed(
          recipeTemplateId: intent.recipeTemplateId,
          reason: CraftingFailureReason.stationRequired,
        ));
        _logger.fine('craft failed: station required', {
          'crafter': crafterId,
          'recipeId': intent.recipeTemplateId,
        });
        continue;
      }

      // Check and consume ingredients
      final inventory = crafter.get<Inventory>();
      if (inventory == null) {
        crafter.upsert(CraftingFailed(
          recipeTemplateId: intent.recipeTemplateId,
          reason: CraftingFailureReason.missingIngredients,
        ));
        continue;
      }

      final consumed = _tryConsumeIngredients(world, crafter, recipe.inputs);
      if (consumed == null) {
        crafter.upsert(CraftingFailed(
          recipeTemplateId: intent.recipeTemplateId,
          reason: CraftingFailureReason.missingIngredients,
        ));
        _logger.fine('craft failed: missing ingredients', {
          'crafter': crafterId,
          'recipeId': intent.recipeTemplateId,
        });
        continue;
      }

      if (recipe.craftingTicks <= 1) {
        // Instant craft
        final produced = _createOutputs(world, crafter, recipe);
        crafter.upsert(DidStartCrafting(
          recipeTemplateId: intent.recipeTemplateId,
          isInstant: true,
        ));
        crafter.upsert(DidCompleteCrafting(
          recipeTemplateId: intent.recipeTemplateId,
          producedEntityIds: produced,
        ));
        _logger.fine('instant craft completed', {
          'crafter': crafterId,
          'recipeId': intent.recipeTemplateId,
          'produced': produced,
        });
      } else {
        // Time-based: add Processing and Busy
        crafter.upsert(Processing(
          recipeTemplateId: intent.recipeTemplateId,
          ticksRemaining: recipe.craftingTicks,
          initiatorEntityId: crafterId,
        ));
        crafter.upsert(Busy(activity: 'crafting'));
        crafter.upsert(DidStartCrafting(
          recipeTemplateId: intent.recipeTemplateId,
          isInstant: false,
        ));
        _logger.fine('time-based craft started', {
          'crafter': crafterId,
          'recipeId': intent.recipeTemplateId,
          'ticks': recipe.craftingTicks,
        });
      }
    }
  }

  void _processStationCraftIntents(World world) {
    final intents = Map.from(world.get<StationCraftIntent>());

    for (final entry in intents.entries) {
      final initiatorId = entry.key;
      final intent = entry.value as StationCraftIntent;
      final initiator = world.getEntity(initiatorId);
      final station = world.getEntity(intent.stationEntityId);

      initiator.remove<StationCraftIntent>();

      // Validate station
      final craftingStation = station.get<CraftingStation>();
      if (craftingStation == null) {
        initiator.upsert(CraftingFailed(
          recipeTemplateId: intent.recipeTemplateId,
          reason: CraftingFailureReason.wrongStationType,
        ));
        _logger.fine('station craft failed: not a station', {
          'initiator': initiatorId,
          'stationId': intent.stationEntityId,
        });
        continue;
      }

      // Check station not busy
      if (station.has<Processing>()) {
        initiator.upsert(CraftingFailed(
          recipeTemplateId: intent.recipeTemplateId,
          reason: CraftingFailureReason.stationBusy,
        ));
        _logger.fine('station craft failed: station busy', {
          'initiator': initiatorId,
          'stationId': intent.stationEntityId,
        });
        continue;
      }

      // Validate recipe
      final recipeTemplate = world.getEntity(intent.recipeTemplateId);
      final recipe = recipeTemplate.get<Recipe>();
      if (recipe == null) {
        initiator.upsert(CraftingFailed(
          recipeTemplateId: intent.recipeTemplateId,
          reason: CraftingFailureReason.recipeNotFound,
        ));
        continue;
      }

      // Check capabilities
      if (!craftingStation.capabilities.containsAll(recipe.requiredCapabilities)) {
        initiator.upsert(CraftingFailed(
          recipeTemplateId: intent.recipeTemplateId,
          reason: CraftingFailureReason.wrongStationType,
        ));
        _logger.fine('station craft failed: wrong capabilities', {
          'initiator': initiatorId,
          'stationId': intent.stationEntityId,
          'required': recipe.requiredCapabilities,
          'available': craftingStation.capabilities,
        });
        continue;
      }

      // Check and consume ingredients
      // When initiator differs from station (player-initiated), draw from
      // player first, then station. When same (autonomous), station only.
      final List<int>? consumed;
      if (initiatorId != intent.stationEntityId) {
        consumed = _tryConsumeFromSources(
            world, [initiator, station], recipe.inputs);
      } else {
        consumed = _tryConsumeIngredients(world, station, recipe.inputs);
      }
      if (consumed == null) {
        initiator.upsert(CraftingFailed(
          recipeTemplateId: intent.recipeTemplateId,
          reason: CraftingFailureReason.missingIngredients,
        ));
        _logger.fine('station craft failed: missing ingredients', {
          'initiator': initiatorId,
          'stationId': intent.stationEntityId,
        });
        continue;
      }

      if (recipe.craftingTicks <= 1) {
        // Instant craft
        final produced = _createOutputs(world, station, recipe);
        initiator.upsert(DidStartCrafting(
          recipeTemplateId: intent.recipeTemplateId,
          isInstant: true,
        ));
        initiator.upsert(DidCompleteCrafting(
          recipeTemplateId: intent.recipeTemplateId,
          producedEntityIds: produced,
        ));
        _logger.fine('instant station craft completed', {
          'initiator': initiatorId,
          'stationId': intent.stationEntityId,
          'produced': produced,
        });
      } else {
        // Time-based: add Processing to station
        station.upsert(Processing(
          recipeTemplateId: intent.recipeTemplateId,
          ticksRemaining: recipe.craftingTicks,
          initiatorEntityId: initiatorId,
        ));
        initiator.upsert(DidStartCrafting(
          recipeTemplateId: intent.recipeTemplateId,
          isInstant: false,
        ));
        _logger.fine('time-based station craft started', {
          'initiator': initiatorId,
          'stationId': intent.stationEntityId,
          'ticks': recipe.craftingTicks,
        });
      }
    }
  }

  /// Check if item matches required template (traverses FromTemplate chain).
  bool _matchesTemplate(World world, Entity item, int requiredTemplateId) {
    var fromTemplate = item.get<FromTemplate>();
    while (fromTemplate != null) {
      if (fromTemplate.templateEntityId == requiredTemplateId) return true;
      final parent = world.getEntity(fromTemplate.templateEntityId);
      fromTemplate = parent.get<FromTemplate>();
    }
    return false;
  }

  /// Try to consume ingredients. Returns consumed item IDs or null if insufficient.
  List<int>? _tryConsumeIngredients(
    World world,
    Entity source,
    List<RecipeIngredient> required,
  ) {
    final inventory = source.get<Inventory>();
    if (inventory == null) return null;

    final toConsume = <int>[];
    final available = List<int>.from(inventory.items);

    for (final ingredient in required) {
      var needed = ingredient.quantity;

      for (var i = available.length - 1; i >= 0 && needed > 0; i--) {
        final itemId = available[i];
        final item = world.getEntity(itemId);

        if (_matchesTemplate(world, item, ingredient.templateId)) {
          toConsume.add(itemId);
          available.removeAt(i);
          needed--;
        }
      }

      if (needed > 0) return null; // Not enough
    }

    // Actually remove consumed items (destroy them)
    source.upsert(Inventory(available));
    for (final itemId in toConsume) {
      world.remove(itemId);
    }
    return toConsume;
  }

  /// Try to consume ingredients across multiple sources in order.
  ///
  /// For each ingredient, exhausts the first source before moving to the next.
  /// Returns consumed item IDs or null if total across all sources is insufficient.
  List<int>? _tryConsumeFromSources(
    World world,
    List<Entity> sources,
    List<RecipeIngredient> required,
  ) {
    // Build per-source available lists
    final availableBySrc = <Entity, List<int>>{};
    for (final src in sources) {
      final inv = src.get<Inventory>();
      if (inv != null) {
        availableBySrc[src] = List<int>.from(inv.items);
      }
    }

    // Track which items to consume from each source
    final consumedBySrc = <Entity, List<int>>{};

    for (final ingredient in required) {
      var needed = ingredient.quantity;

      for (final src in sources) {
        final available = availableBySrc[src];
        if (available == null || needed <= 0) continue;

        for (var i = available.length - 1; i >= 0 && needed > 0; i--) {
          final itemId = available[i];
          final item = world.getEntity(itemId);

          if (_matchesTemplate(world, item, ingredient.templateId)) {
            consumedBySrc.putIfAbsent(src, () => []).add(itemId);
            available.removeAt(i);
            needed--;
          }
        }
      }

      if (needed > 0) return null;
    }

    // Commit: update each source's inventory and destroy consumed items
    final allConsumed = <int>[];
    for (final entry in consumedBySrc.entries) {
      final src = entry.key;
      final consumed = entry.value;
      allConsumed.addAll(consumed);

      final remaining = availableBySrc[src]!;
      src.upsert(Inventory(remaining));

      for (final itemId in consumed) {
        world.remove(itemId);
      }
    }

    return allConsumed;
  }

  /// Create output items and add to destination inventory.
  List<int> _createOutputs(World world, Entity destination, Recipe recipe) {
    final produced = <int>[];

    for (final output in recipe.outputs) {
      for (var i = 0; i < output.quantity; i++) {
        final item = world.add([FromTemplate(output.templateId)]);
        produced.add(item.id);
      }
    }

    final inventory = destination.get<Inventory>() ?? Inventory([]);
    destination.upsert(Inventory([...inventory.items, ...produced]));

    return produced;
  }
}
