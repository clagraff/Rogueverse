import 'dart:convert';
import 'dart:io';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

part 'keybinding_service.mapper.dart';

/// Represents a key combination (one or more keys pressed together).
///
/// Stores keys as their keyId integers for serialization. Supports modifier keys
/// (Ctrl, Shift, Alt) combined with regular keys.
///
/// Example:
/// ```dart
/// // Ctrl+E
/// final combo = KeyCombo([LogicalKeyboardKey.control, LogicalKeyboardKey.keyE]);
///
/// // Just W
/// final move = KeyCombo([LogicalKeyboardKey.keyW]);
/// ```
@MappableClass()
class KeyCombo with KeyComboMappable {
  /// The key IDs that make up this combination.
  ///
  /// Stored as integers (LogicalKeyboardKey.keyId) for serialization.
  final List<int> keyIds;

  KeyCombo(this.keyIds);

  /// Creates a KeyCombo from LogicalKeyboardKey instances.
  factory KeyCombo.fromKeys(List<LogicalKeyboardKey> keys) {
    return KeyCombo(keys.map((k) => k.keyId).toList());
  }

  /// Converts back to LogicalKeyboardKey instances.
  Set<LogicalKeyboardKey> toKeys() {
    return keyIds
        .map((id) => LogicalKeyboardKey.findKeyByKeyId(id))
        .whereType<LogicalKeyboardKey>()
        .toSet();
  }

  /// Checks if this combo matches the currently pressed keys.
  ///
  /// Normalizes modifier keys so that e.g. controlLeft and controlRight
  /// both match the generic control key.
  ///
  /// TODO: Support non-normalized modifier matching for cases where leftCtrl+E
  /// and rightCtrl+E should trigger different actions. Could add a `exactMatch`
  /// flag to KeyCombo, or check if the combo uses a specific left/right variant
  /// and only normalize when using the generic modifier.
  bool matches(Set<LogicalKeyboardKey> keysPressed) {
    final comboKeys = toKeys();
    final normalizedCombo = comboKeys.map(_normalizeModifier).toSet();
    final normalizedPressed = keysPressed.map(_normalizeModifier).toSet();

    return normalizedCombo.length == normalizedPressed.length &&
        normalizedCombo.every((key) => normalizedPressed.contains(key));
  }

  /// Normalizes left/right modifier variants to their generic form.
  static LogicalKeyboardKey _normalizeModifier(LogicalKeyboardKey key) {
    // Control variants
    if (key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight) {
      return LogicalKeyboardKey.control;
    }
    // Shift variants
    if (key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight) {
      return LogicalKeyboardKey.shift;
    }
    // Alt variants
    if (key == LogicalKeyboardKey.altLeft ||
        key == LogicalKeyboardKey.altRight) {
      return LogicalKeyboardKey.alt;
    }
    // Meta variants (Windows/Command key)
    if (key == LogicalKeyboardKey.metaLeft ||
        key == LogicalKeyboardKey.metaRight) {
      return LogicalKeyboardKey.meta;
    }
    return key;
  }

  /// Returns a human-readable string representation of this combo.
  ///
  /// Example: "Ctrl+E", "W", "Ctrl+Shift+S"
  String toDisplayString() {
    final keys = toKeys().toList();
    final parts = <String>[];

    // Add modifiers first in a consistent order
    if (keys.any((k) =>
        k == LogicalKeyboardKey.controlLeft ||
        k == LogicalKeyboardKey.controlRight ||
        k == LogicalKeyboardKey.control)) {
      parts.add('Ctrl');
    }
    if (keys.any((k) =>
        k == LogicalKeyboardKey.shiftLeft ||
        k == LogicalKeyboardKey.shiftRight ||
        k == LogicalKeyboardKey.shift)) {
      parts.add('Shift');
    }
    if (keys.any((k) =>
        k == LogicalKeyboardKey.altLeft ||
        k == LogicalKeyboardKey.altRight ||
        k == LogicalKeyboardKey.alt)) {
      parts.add('Alt');
    }

    // Add non-modifier keys
    for (final key in keys) {
      if (!_isModifier(key)) {
        parts.add(_keyLabel(key));
      }
    }

    return parts.join('+');
  }

  bool _isModifier(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight ||
        key == LogicalKeyboardKey.control ||
        key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight ||
        key == LogicalKeyboardKey.shift ||
        key == LogicalKeyboardKey.altLeft ||
        key == LogicalKeyboardKey.altRight ||
        key == LogicalKeyboardKey.alt;
  }

  String _keyLabel(LogicalKeyboardKey key) {
    // Handle special keys
    if (key == LogicalKeyboardKey.space) return 'Space';
    if (key == LogicalKeyboardKey.escape) return 'Esc';
    if (key == LogicalKeyboardKey.tab) return 'Tab';
    if (key == LogicalKeyboardKey.enter) return 'Enter';
    if (key == LogicalKeyboardKey.backquote) return '`';
    if (key == LogicalKeyboardKey.arrowUp) return 'Up';
    if (key == LogicalKeyboardKey.arrowDown) return 'Down';
    if (key == LogicalKeyboardKey.arrowLeft) return 'Left';
    if (key == LogicalKeyboardKey.arrowRight) return 'Right';

    // For letter keys, extract just the letter
    final label = key.keyLabel;
    if (label.length == 1) return label.toUpperCase();
    return label;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! KeyCombo) return false;
    final otherKeys = other.keyIds.toSet();
    final thisKeys = keyIds.toSet();
    return thisKeys.length == otherKeys.length &&
        thisKeys.every((k) => otherKeys.contains(k));
  }

  @override
  int get hashCode => Object.hashAll(keyIds.toList()..sort());
}

/// A single keybinding mapping an action name to a key combination.
@MappableClass()
class KeyBinding with KeyBindingMappable {
  /// The action identifier (e.g., "movement.up", "overlay.editor").
  final String action;

  /// The key combination that triggers this action.
  final KeyCombo combo;

  KeyBinding({required this.action, required this.combo});

  /// Creates a KeyBinding from LogicalKeyboardKey instances.
  factory KeyBinding.fromKeys(String action, List<LogicalKeyboardKey> keys) {
    return KeyBinding(action: action, combo: KeyCombo.fromKeys(keys));
  }
}

/// Central service for managing keybindings.
///
/// Provides CRUD operations, persistence, and resolution of keybindings.
/// Bindings are stored both in memory and persisted to JSON in the app support directory.
///
/// Actions are identified by string names using a hierarchical format:
/// - `movement.up`, `movement.down`, `movement.left`, `movement.right`
/// - `entity.interact`
/// - `inventory.toggle`
/// - `game.advanceTick`, `game.deselect`
/// - `overlay.editor`, `overlay.templates`
///
/// Usage:
/// ```dart
/// // Initialize and load persisted keybindings
/// await KeyBindingService.instance.load();
///
/// // Check if an action matches current keys
/// if (KeyBindingService.instance.matches('overlay.editor', keysPressed)) {
///   // Toggle editor
/// }
///
/// // Rebind an action
/// await KeyBindingService.instance.rebind(
///   'overlay.editor',
///   KeyCombo.fromKeys([LogicalKeyboardKey.control, LogicalKeyboardKey.backquote]),
/// );
/// ```
class KeyBindingService {
  static final KeyBindingService _instance = KeyBindingService._internal();
  static KeyBindingService get instance => _instance;

  KeyBindingService._internal();

  final _logger = Logger('KeyBindingService');

  /// In-memory storage of keybindings, keyed by action name.
  final Map<String, KeyBinding> _bindings = {};

  /// Notifier that emits changes when keybindings are modified.
  final ValueNotifier<int> changeNotifier = ValueNotifier(0);

  /// Gets all keybindings as a list.
  List<KeyBinding> getAll() => _bindings.values.toList();

  /// Gets the keybinding for a specific action.
  KeyBinding? getBinding(String action) => _bindings[action];

  /// Gets the key combo for a specific action.
  KeyCombo? getCombo(String action) => _bindings[action]?.combo;

  /// Checks if the given keys match the binding for an action.
  bool matches(String action, Set<LogicalKeyboardKey> keysPressed) {
    final binding = _bindings[action];
    if (binding == null) return false;
    return binding.combo.matches(keysPressed);
  }

  /// Resolves which action (if any) matches the currently pressed keys.
  ///
  /// Optionally filter by action prefix (e.g., "movement." to only check movement actions).
  String? resolve(Set<LogicalKeyboardKey> keysPressed, {String? prefix}) {
    for (final entry in _bindings.entries) {
      if (prefix != null && !entry.key.startsWith(prefix)) continue;
      if (entry.value.combo.matches(keysPressed)) {
        return entry.key;
      }
    }
    return null;
  }

  /// Rebinds an action to a new key combination.
  ///
  /// Automatically persists to disk and notifies listeners.
  Future<void> rebind(String action, KeyCombo combo) async {
    _bindings[action] = KeyBinding(action: action, combo: combo);
    _notifyChange();
    await _persist();
    _logger.fine('rebound action', {'action': action, 'combo': combo.toDisplayString()});
  }

  /// Resets a single action to its default binding.
  Future<void> resetToDefault(String action) async {
    final defaultCombo = _defaultBindings[action];
    if (defaultCombo != null) {
      await rebind(action, defaultCombo);
    }
  }

  /// Resets all keybindings to defaults.
  Future<void> resetAllToDefaults() async {
    _bindings.clear();
    _applyDefaults();
    _notifyChange();
    await _persist();
    _logger.info('reset all keybindings to defaults');
  }

  /// Loads keybindings from persisted JSON file.
  ///
  /// Should be called once during app initialization. If no save file exists,
  /// default keybindings are used.
  Future<void> load() async {
    // Always start with defaults
    _applyDefaults();

    try {
      final file = await _getKeybindingFile();
      if (!file.existsSync()) {
        _logger.fine('no keybinding file found, using defaults');
        await _persist(); // Save defaults
        return;
      }

      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Override defaults with saved bindings
      for (final entry in jsonData.entries) {
        final binding = KeyBindingMapper.fromMap(entry.value as Map<String, dynamic>);
        _bindings[entry.key] = binding;
      }

      _notifyChange();
      _logger.fine('loaded keybindings from disk', {'bindingCount': _bindings.length});
    } catch (e, stackTrace) {
      _logger.severe('failed to load keybindings', e, stackTrace);
    }
  }

  /// Persists all keybindings to JSON file.
  Future<void> _persist() async {
    try {
      final file = await _getKeybindingFile();

      final jsonData = <String, dynamic>{};
      for (final entry in _bindings.entries) {
        jsonData[entry.key] = entry.value.toMap();
      }

      final jsonString = const JsonEncoder.withIndent('\t').convert(jsonData);
      await file.writeAsString(jsonString);

      _logger.info('persisted ${_bindings.length} keybindings to disk');
    } catch (e, stackTrace) {
      _logger.severe('failed to persist keybindings', e, stackTrace);
    }
  }

  /// Gets the file handle for the keybindings JSON file.
  Future<File> _getKeybindingFile() async {
    final supportDir = await getApplicationSupportDirectory();
    return File('${supportDir.path}/keybindings.json');
  }

  /// Notifies listeners that keybindings have changed.
  void _notifyChange() {
    changeNotifier.value++;
  }

  /// Applies default keybindings.
  void _applyDefaults() {
    for (final entry in _defaultBindings.entries) {
      _bindings[entry.key] = KeyBinding(action: entry.key, combo: entry.value);
    }
  }

  /// Default keybindings.
  static final Map<String, KeyCombo> _defaultBindings = {
    // Movement
    'movement.up': KeyCombo.fromKeys([LogicalKeyboardKey.keyW]),
    'movement.down': KeyCombo.fromKeys([LogicalKeyboardKey.keyS]),
    'movement.left': KeyCombo.fromKeys([LogicalKeyboardKey.keyA]),
    'movement.right': KeyCombo.fromKeys([LogicalKeyboardKey.keyD]),

    // Entity actions
    'entity.interact': KeyCombo.fromKeys([LogicalKeyboardKey.keyE]),

    // Inventory
    'inventory.toggle': KeyCombo.fromKeys([LogicalKeyboardKey.tab]),

    // Game controls
    'game.advanceTick': KeyCombo.fromKeys([LogicalKeyboardKey.space]),
    'game.deselect': KeyCombo.fromKeys([LogicalKeyboardKey.escape]),
    'game.toggleMode': KeyCombo.fromKeys([LogicalKeyboardKey.control, LogicalKeyboardKey.backquote]),

    // Overlay toggles
    'overlay.editor': KeyCombo.fromKeys([LogicalKeyboardKey.control, LogicalKeyboardKey.keyE]),
    'overlay.templates': KeyCombo.fromKeys([LogicalKeyboardKey.control, LogicalKeyboardKey.keyT]),
  };

  /// Clears all keybindings from memory.
  ///
  /// Primarily for testing. Does not delete the persisted file.
  void clear() {
    _bindings.clear();
    _notifyChange();
  }
}
