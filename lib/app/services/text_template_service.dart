import 'package:collection/collection.dart';
import 'package:rogueverse/app/services/template_namespace.dart';

export 'package:rogueverse/app/services/template_namespace.dart'
    show TemplateContext, TemplateVariableInfo;

/// Service for resolving text templates with placeholder substitution.
///
/// Supports placeholders in the format `{{namespace.key}}`:
/// - `{{keybind.movement.up}}` - resolves to the display string of a keybinding
/// - `{{player.name}}` - resolves to the player entity's Name component
/// - `{{npc.name}}` - resolves to the NPC entity's Name component
///
/// The service uses a namespace-based architecture for extensibility.
/// New namespaces can be registered via [registerNamespace].
///
/// Usage:
/// ```dart
/// // Simple keybinding resolution
/// final text = TextTemplateService.instance.resolve(
///   'Press {{keybind.movement.up}} to move up',
/// );
/// // → "Press W to move up"
///
/// // With entity context
/// final dialogText = TextTemplateService.instance.resolve(
///   'Hello, {{player.name}}!',
///   context: TemplateContext(player: playerEntity),
/// );
/// // → "Hello, Hero!"
/// ```
class TextTemplateService {
  static final TextTemplateService instance = TextTemplateService._internal();

  TextTemplateService._internal() {
    // Register default namespaces
    _namespaces.addAll([
      KeybindNamespace(),
      EntityNamespace('player', 'Player', (ctx) => ctx?.player),
      EntityNamespace('npc', 'NPC', (ctx) => ctx?.npc),
    ]);
  }

  /// Pattern matching `{{namespace.key}}` placeholders.
  ///
  /// Captures the full key path (e.g., "keybind.movement.up" or "player.name").
  static final RegExp _pattern = RegExp(r'\{\{(\w+(?:\.\w+)*)\}\}');

  /// Registered namespaces for variable resolution.
  final List<TemplateNamespace> _namespaces = [];

  /// Get all available template variables for help/documentation UI.
  ///
  /// Returns variables from all registered namespaces, useful for
  /// displaying a help screen showing available placeholders.
  List<TemplateVariableInfo> getAllVariables() {
    return _namespaces.expand((ns) => ns.getVariables()).toList();
  }

  /// Get all registered namespaces.
  ///
  /// Useful for grouping variables by namespace in the UI.
  List<TemplateNamespace> getNamespaces() => List.unmodifiable(_namespaces);

  /// Register a new namespace for template resolution.
  ///
  /// Namespaces are checked in order, so later registrations take precedence
  /// if there are duplicate namespace names.
  void registerNamespace(TemplateNamespace namespace) {
    _namespaces.add(namespace);
  }

  /// Resolves all placeholders in the given template string.
  ///
  /// If a placeholder cannot be resolved, it is left unchanged in the output.
  /// This allows for graceful degradation when context is missing.
  ///
  /// [template] The string containing `{{namespace.key}}` placeholders.
  /// [context] Optional context providing entity references for resolution.
  ///
  /// Returns the resolved string with placeholders substituted.
  String resolve(String template, {TemplateContext? context}) {
    return template.replaceAllMapped(_pattern, (match) {
      final key = match.group(1)!;
      return _resolveVariable(key, context) ?? match.group(0)!;
    });
  }

  /// Resolves a single variable key to its value.
  ///
  /// [fullKey] The full key path (e.g., "keybind.movement.up").
  /// [context] Optional template context for entity resolution.
  ///
  /// Returns the resolved value, or null if the variable cannot be resolved.
  String? _resolveVariable(String fullKey, TemplateContext? context) {
    final parts = fullKey.split('.');
    if (parts.isEmpty) return null;

    final namespaceName = parts[0];
    final key = parts.sublist(1).join('.');

    final namespace =
        _namespaces.firstWhereOrNull((ns) => ns.name == namespaceName);
    return namespace?.resolve(key, context);
  }
}
