import 'package:rogueverse/app/services/keybinding_service.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';

/// Context for template resolution, providing entity references.
///
/// Used to resolve entity-specific placeholders like `{{player.name}}` or
/// `{{npc.name}}` in dialog text.
class TemplateContext {
  /// The player entity for resolving `{{player.*}}` placeholders.
  final Entity? player;

  /// The NPC entity for resolving `{{npc.*}}` placeholders.
  final Entity? npc;

  const TemplateContext({this.player, this.npc});
}

/// Metadata about a template variable for documentation/help UI.
class TemplateVariableInfo {
  /// Full key path, e.g., "keybind.movement.up".
  final String key;

  /// Human-readable description, e.g., "Move up".
  final String description;

  /// Current resolved value, e.g., "W". Null if requires context.
  final String? currentValue;

  /// True if this variable requires runtime context (e.g., player.name).
  final bool requiresContext;

  const TemplateVariableInfo({
    required this.key,
    required this.description,
    this.currentValue,
    this.requiresContext = false,
  });
}

/// A namespace that can resolve and document its variables.
///
/// Namespaces provide a hierarchical organization for template variables.
/// Each namespace handles a prefix (e.g., "keybind", "player") and can
/// resolve keys within that prefix.
abstract class TemplateNamespace {
  /// The namespace name (e.g., "keybind", "player").
  String get name;

  /// Human-readable display name for the UI (e.g., "Keybindings", "Player").
  String get displayName;

  /// Get all variables in this namespace for documentation/help UI.
  List<TemplateVariableInfo> getVariables();

  /// Resolve a key within this namespace.
  ///
  /// [key] is the portion after the namespace prefix.
  /// For example, if the full key is "keybind.movement.up", key is "movement.up".
  ///
  /// Returns the resolved value, or null if the key cannot be resolved.
  String? resolve(String key, TemplateContext? context);
}

/// Namespace for keybinding template variables.
///
/// Resolves `{{keybind.*}}` placeholders to their display strings.
class KeybindNamespace extends TemplateNamespace {
  @override
  String get name => 'keybind';

  @override
  String get displayName => 'Keybindings';

  /// Maps action names to human-readable descriptions.
  static const _descriptions = {
    // Movement
    'movement.up': 'Move up',
    'movement.down': 'Move down',
    'movement.left': 'Move left',
    'movement.right': 'Move right',

    // Direction (face without moving)
    'direction.up': 'Face up (no movement)',
    'direction.down': 'Face down (no movement)',
    'direction.left': 'Face left (no movement)',
    'direction.right': 'Face right (no movement)',

    // Strafe (move without changing direction)
    'strafe.up': 'Strafe up',
    'strafe.down': 'Strafe down',
    'strafe.left': 'Strafe left',
    'strafe.right': 'Strafe right',

    // Entity actions
    'entity.interact': 'Interact with entity',

    // Inventory
    'inventory.toggle': 'Open/close inventory',

    // Game controls
    'game.advanceTick': 'Wait one turn',
    'game.deselect': 'Deselect / Open menu',
    'game.toggleMode': 'Toggle edit/gameplay mode',

    // Camera controls
    'camera.toggleFollow': 'Toggle camera follow',

    // Overlay toggles
    'overlay.editor': 'Open editor panel',
    'overlay.templates': 'Open templates panel',
  };

  @override
  List<TemplateVariableInfo> getVariables() {
    return KeyBindingService.instance.getAll().map((binding) {
      return TemplateVariableInfo(
        key: 'keybind.${binding.action}',
        description: _descriptions[binding.action] ?? binding.action,
        currentValue: binding.combo.toDisplayString(),
        requiresContext: false,
      );
    }).toList();
  }

  @override
  String? resolve(String key, TemplateContext? context) {
    return KeyBindingService.instance.getCombo(key)?.toDisplayString();
  }
}

/// Namespace for entity template variables.
///
/// Used for both player and NPC entities. Resolves properties like name
/// from the provided entity in the template context.
class EntityNamespace extends TemplateNamespace {
  @override
  final String name;

  @override
  final String displayName;

  /// Function to get the entity from the template context.
  final Entity? Function(TemplateContext?) entityGetter;

  EntityNamespace(this.name, this.displayName, this.entityGetter);

  @override
  List<TemplateVariableInfo> getVariables() {
    return [
      TemplateVariableInfo(
        key: '$name.name',
        description: "The $name's name",
        requiresContext: true,
      ),
    ];
  }

  @override
  String? resolve(String key, TemplateContext? context) {
    final entity = entityGetter(context);
    if (entity == null) return null;

    return switch (key) {
      'name' => entity.get<Name>()?.name,
      _ => null,
    };
  }
}
