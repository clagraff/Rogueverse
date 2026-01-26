import 'dart:convert';
import 'dart:io';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

part 'game_settings_service.mapper.dart';

/// How to handle interactions with entities remembered from vision memory.
@MappableEnum()
enum InteractionMacroMode {
  /// No macro - only visible entities can be interacted with.
  disabled,

  /// Turn → interact → turn back to original direction.
  lookBack,

  /// Turn → interact (don't turn back).
  remainFacing,
}

/// Where to display the dialog overlay on screen.
@MappableEnum()
enum DialogPosition {
  /// Dialog anchored near bottom of screen (default).
  bottom,

  /// Dialog centered vertically on screen.
  center,

  /// Dialog anchored near top of screen.
  top,
}

/// General game settings that can be persisted.
@MappableClass()
class GameSettings with GameSettingsMappable {
  /// Whether to show health bars for all entities, even at full health.
  final bool alwaysShowHealthBars;

  /// How to handle interactions with entities remembered from vision memory.
  final InteractionMacroMode interactionMacroMode;

  /// Where to display the dialog overlay on screen.
  final DialogPosition dialogPosition;

  GameSettings({
    this.alwaysShowHealthBars = false,
    this.interactionMacroMode = InteractionMacroMode.lookBack,
    this.dialogPosition = DialogPosition.bottom,
  });
}

/// Central service for managing general game settings.
///
/// Provides persistence and access to game-wide settings like display options.
/// Settings are stored both in memory and persisted to JSON in the app support directory.
///
/// Usage:
/// ```dart
/// // Initialize and load persisted settings
/// await GameSettingsService.instance.load();
///
/// // Check a setting
/// if (GameSettingsService.instance.alwaysShowHealthBars) {
///   // Show health bar
/// }
///
/// // Change a setting
/// await GameSettingsService.instance.setAlwaysShowHealthBars(true);
/// ```
class GameSettingsService {
  static final GameSettingsService _instance = GameSettingsService._internal();
  static GameSettingsService get instance => _instance;

  GameSettingsService._internal();

  final _logger = Logger('GameSettingsService');

  /// In-memory storage of settings.
  GameSettings _settings = GameSettings();

  /// Notifier that emits changes when settings are modified.
  final ValueNotifier<int> changeNotifier = ValueNotifier(0);

  /// Whether to show health bars for all entities, even at full health.
  bool get alwaysShowHealthBars => _settings.alwaysShowHealthBars;

  /// How to handle interactions with entities remembered from vision memory.
  InteractionMacroMode get interactionMacroMode => _settings.interactionMacroMode;

  /// Where to display the dialog overlay on screen.
  DialogPosition get dialogPosition => _settings.dialogPosition;

  /// Sets whether to always show health bars.
  Future<void> setAlwaysShowHealthBars(bool value) async {
    _settings = GameSettings(
      alwaysShowHealthBars: value,
      interactionMacroMode: _settings.interactionMacroMode,
      dialogPosition: _settings.dialogPosition,
    );
    _notifyChange();
    await _persist();
  }

  /// Sets how to handle interactions with memory entities.
  Future<void> setInteractionMacroMode(InteractionMacroMode value) async {
    _settings = GameSettings(
      alwaysShowHealthBars: _settings.alwaysShowHealthBars,
      interactionMacroMode: value,
      dialogPosition: _settings.dialogPosition,
    );
    _notifyChange();
    await _persist();
  }

  /// Sets where to display the dialog overlay on screen.
  Future<void> setDialogPosition(DialogPosition value) async {
    _settings = GameSettings(
      alwaysShowHealthBars: _settings.alwaysShowHealthBars,
      interactionMacroMode: _settings.interactionMacroMode,
      dialogPosition: value,
    );
    _notifyChange();
    await _persist();
  }

  /// Loads settings from persisted JSON file.
  ///
  /// Should be called once during app initialization. If no save file exists,
  /// default settings are used.
  Future<void> load() async {
    try {
      final file = await _getSettingsFile();
      if (!file.existsSync()) {
        _logger.fine('no settings file found, using defaults');
        return;
      }

      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      _settings = GameSettingsMapper.fromMap(jsonData);

      _notifyChange();
      _logger.fine('loaded game settings from disk');
    } catch (e, stackTrace) {
      _logger.severe('failed to load game settings', e, stackTrace);
    }
  }

  /// Persists settings to JSON file.
  Future<void> _persist() async {
    try {
      final file = await _getSettingsFile();
      final jsonString = const JsonEncoder.withIndent('\t').convert(_settings.toMap());
      await file.writeAsString(jsonString);

      _logger.info('persisted game settings to disk');
    } catch (e, stackTrace) {
      _logger.severe('failed to persist game settings', e, stackTrace);
    }
  }

  /// Gets the file handle for the settings JSON file.
  Future<File> _getSettingsFile() async {
    final supportDir = await getApplicationSupportDirectory();
    return File('${supportDir.path}/game_settings.json');
  }

  /// Notifies listeners that settings have changed.
  void _notifyChange() {
    changeNotifier.value++;
  }

  /// Resets all settings to defaults.
  Future<void> resetToDefaults() async {
    _settings = GameSettings();
    _notifyChange();
    await _persist();
    _logger.info('reset all settings to defaults');
  }
}
