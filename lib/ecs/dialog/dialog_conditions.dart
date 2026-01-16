import 'package:dart_mappable/dart_mappable.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/dialog/dialog_effects.dart' show IgnoreHook;
import 'package:rogueverse/ecs/entity.dart';

part 'dialog_conditions.mapper.dart';

/// Base class for dialog conditions.
///
/// Conditions determine whether a choice is available or which branch
/// to take in a conditional node.
@MappableClass()
abstract class DialogCondition with DialogConditionMappable {
  const DialogCondition();

  /// Evaluates the condition.
  ///
  /// Returns true if the condition passes.
  bool evaluate(Entity player, Entity npc);
}

/// Always passes - useful for unconditional choices.
@MappableClass()
class AlwaysCondition extends DialogCondition with AlwaysConditionMappable {
  const AlwaysCondition();

  @override
  bool evaluate(Entity player, Entity npc) => true;
}

/// Never passes - useful for disabled choices.
@MappableClass()
class NeverCondition extends DialogCondition with NeverConditionMappable {
  const NeverCondition();

  @override
  bool evaluate(Entity player, Entity npc) => false;
}

/// Inverts another condition.
@MappableClass()
class NotCondition extends DialogCondition with NotConditionMappable {
  final DialogCondition condition;

  const NotCondition(this.condition);

  @override
  bool evaluate(Entity player, Entity npc) {
    return !condition.evaluate(player, npc);
  }
}

/// All conditions must pass (AND logic).
@MappableClass()
class AllCondition extends DialogCondition with AllConditionMappable {
  final List<DialogCondition> conditions;

  const AllCondition(this.conditions);

  @override
  bool evaluate(Entity player, Entity npc) {
    return conditions.every((c) => c.evaluate(player, npc));
  }
}

/// Any condition must pass (OR logic).
@MappableClass()
class AnyCondition extends DialogCondition with AnyConditionMappable {
  final List<DialogCondition> conditions;

  const AnyCondition(this.conditions);

  @override
  bool evaluate(Entity player, Entity npc) {
    return conditions.any((c) => c.evaluate(player, npc));
  }
}

/// Checks if player has a specific item in inventory.
@MappableClass()
class HasItemCondition extends DialogCondition with HasItemConditionMappable {
  /// Template ID or name pattern to match.
  final String itemIdentifier;

  /// Minimum count required (default 1).
  final int minCount;

  const HasItemCondition({
    required this.itemIdentifier,
    this.minCount = 1,
  });

  @override
  bool evaluate(Entity player, Entity npc) {
    final inventory = player.get<Inventory>();
    if (inventory == null) return false;

    // Count items matching the identifier
    int count = 0;
    for (final itemId in inventory.items) {
      final item = player.parentCell.getEntity(itemId);
      final name = item.get<Name>();
      if (name?.name == itemIdentifier) {
        count++;
      }
    }
    return count >= minCount;
  }
}

/// Checks player health.
@MappableClass()
class HealthCondition extends DialogCondition with HealthConditionMappable {
  /// Minimum health required (absolute value).
  final int? minHealth;

  /// Maximum health required (absolute value).
  final int? maxHealth;

  /// Minimum health percentage (0.0 to 1.0).
  final double? minPercentage;

  /// Maximum health percentage (0.0 to 1.0).
  final double? maxPercentage;

  const HealthCondition({
    this.minHealth,
    this.maxHealth,
    this.minPercentage,
    this.maxPercentage,
  });

  @override
  bool evaluate(Entity player, Entity npc) {
    final health = player.get<Health>();
    if (health == null) return false;

    if (minHealth != null && health.current < minHealth!) return false;
    if (maxHealth != null && health.current > maxHealth!) return false;

    if (health.max > 0) {
      final percentage = health.current / health.max;
      if (minPercentage != null && percentage < minPercentage!) return false;
      if (maxPercentage != null && percentage > maxPercentage!) return false;
    }

    return true;
  }
}

/// Checks if player has a specific component.
@MappableClass()
class HasComponentCondition extends DialogCondition
    with HasComponentConditionMappable {
  /// The component type name to check for.
  final String componentType;

  /// Whether to check player (true) or NPC (false).
  final bool checkPlayer;

  const HasComponentCondition({
    required this.componentType,
    this.checkPlayer = true,
  });

  @override
  bool evaluate(Entity player, Entity npc) {
    final target = checkPlayer ? player : npc;
    return target.getByName(componentType) != null;
  }
}

/// Custom condition using a function.
///
/// Note: Custom functions cannot be serialized, so this is for runtime use only.
/// For persistent dialogs, use the built-in condition types.
@MappableClass()
class CustomCondition extends DialogCondition with CustomConditionMappable {
  @MappableField(hook: IgnoreHook())
  final bool Function(Entity player, Entity npc)? evaluator;

  /// Fallback value when evaluator is null (e.g., after deserialization).
  final bool fallbackValue;

  const CustomCondition({
    this.evaluator,
    this.fallbackValue = false,
  });

  @override
  bool evaluate(Entity player, Entity npc) {
    if (evaluator == null) return fallbackValue;
    return evaluator!(player, npc);
  }
}
