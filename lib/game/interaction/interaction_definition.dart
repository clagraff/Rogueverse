import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';

/// Defines a type of interaction that can be performed on entities.
///
/// Each interaction maps from ECS components to user-facing actions.
/// The [range] determines how far away the player can be to perform the action.
///
/// For self-actions (like Wait), set [isSelfAction] to true. These don't
/// target another entity and are always available.
class InteractionDefinition {
  /// Display name for the action (e.g., "Open", "Pick up", "Mine").
  final String actionName;

  /// Present participle form for feedback (e.g., "Opening", "Picking up").
  final String actionVerb;

  /// Fallback label when entity has no Name component (e.g., "Door", "Item").
  /// For self-actions, this is not used.
  final String genericLabel;

  /// Maximum distance (Manhattan) from player to target.
  /// - 0 = must be on same tile
  /// - 1 = adjacent tiles (cardinal directions)
  /// - N = up to N tiles away
  /// Ignored for self-actions.
  final int range;

  /// Whether this is a self-action (targets the player, not another entity).
  /// Self-actions like "Wait" don't require a target entity.
  final bool isSelfAction;

  /// Sort order for menu display. Higher values appear later.
  /// Default is 0. Use high values (e.g., 1000) for "always last" items.
  final int sortOrder;

  /// Returns true if this interaction is currently available for the entity.
  /// For self-actions, this is called with the player entity.
  /// For target actions, this is called with the target entity.
  final bool Function(Entity entity) isAvailable;

  /// Creates the intent component to execute this interaction.
  /// For self-actions, the target parameter is the player entity itself.
  final IntentComponent Function(Entity target) createIntent;

  const InteractionDefinition({
    required this.actionName,
    required this.actionVerb,
    this.genericLabel = '',
    this.range = 1,
    this.isSelfAction = false,
    this.sortOrder = 0,
    required this.isAvailable,
    required this.createIntent,
  });
}
