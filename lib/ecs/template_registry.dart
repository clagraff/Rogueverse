import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rogueverse/ecs/entity_template.dart';

/// Central registry for managing entity templates.
///
/// Provides CRUD operations, persistence, and search functionality for templates.
/// Templates are stored both in memory and persisted to JSON in the app support directory.
///
/// Usage:
/// ```dart
/// // Initialize and load persisted templates
/// await TemplateRegistry.instance.load();
///
/// // Create a new template
/// final template = EntityTemplate(...);
/// TemplateRegistry.instance.save(template);
///
/// // Search templates
/// final walls = TemplateRegistry.instance.search('wall');
/// ```
class TemplateRegistry {
  static final TemplateRegistry _instance = TemplateRegistry._internal();
  static TemplateRegistry get instance => _instance;

  TemplateRegistry._internal();

  final _logger = Logger('TemplateRegistry');

  /// In-memory storage of templates, keyed by template ID.
  final Map<int, EntityTemplate> _templates = {};

  /// The next ID to assign to a new template.
  int _nextId = 1;

  /// Notifier that emits changes when templates are added, updated, or removed.
  ///
  /// UI components can listen to this to reactively update when the template
  /// list changes.
  final ValueNotifier<int> changeNotifier = ValueNotifier(0);

  /// Gets all templates as a list.
  List<EntityTemplate> getAll() => _templates.values.toList();

  /// Gets a template by its ID.
  ///
  /// Returns null if no template with that ID exists.
  EntityTemplate? getById(int id) => _templates[id];

  /// Searches templates by display name (case-insensitive substring match).
  ///
  /// Returns all templates whose displayName contains the query string.
  /// If query is empty, returns all templates.
  List<EntityTemplate> search(String query) {
    if (query.isEmpty) return getAll();

    final lowerQuery = query.toLowerCase();
    return _templates.values
        .where((template) => template.displayName.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Saves or updates a template in the registry.
  ///
  /// If a template with the same ID exists, it will be replaced.
  /// Automatically persists to disk and notifies listeners.
  Future<void> save(EntityTemplate template) async {
    _templates[template.id] = template;
    _notifyChange();
    await _persist();
    _logger.info('Saved template: ${template.displayName} (${template.id})');
  }

  /// Deletes a template by its ID.
  ///
  /// Returns true if the template was found and deleted, false otherwise.
  /// Automatically persists to disk and notifies listeners.
  Future<bool> delete(int id) async {
    final removed = _templates.remove(id);
    if (removed != null) {
      _notifyChange();
      await _persist();
      _logger.info('Deleted template: ${removed.displayName} ($id)');
      return true;
    }
    return false;
  }

  /// Generates a new unique ID for a template.
  ///
  /// IDs are assigned sequentially starting from 1.
  int generateId() => _nextId++;

  /// Loads templates from persisted JSON file.
  ///
  /// Should be called once during app initialization. If no save file exists,
  /// the registry starts empty.
  Future<void> load() async {
    try {
      final file = await _getTemplateFile();
      if (!file.existsSync()) {
        _logger.info('No template file found, starting with empty registry');
        return;
      }

      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      _templates.clear();
      int maxId = 0;

      for (final entry in jsonData.entries) {
        final template = EntityTemplateMapper.fromMap(entry.value as Map<String, dynamic>);
        final id = int.parse(entry.key);
        _templates[id] = template;
        if (id > maxId) maxId = id;
      }

      // Set next ID to be one more than the highest existing ID
      _nextId = maxId + 1;

      _notifyChange();
      _logger.info('Loaded ${_templates.length} templates from disk');
    } catch (e, stackTrace) {
      _logger.severe('Failed to load templates', e, stackTrace);
    }
  }

  /// Persists all templates to JSON file.
  ///
  /// Called automatically after save/delete operations.
  Future<void> _persist() async {
    try {
      final file = await _getTemplateFile();

      // Convert templates to JSON (int keys become strings for JSON)
      final jsonData = <String, dynamic>{};
      for (final entry in _templates.entries) {
        jsonData[entry.key.toString()] = entry.value.toMap();
      }

      final jsonString = const JsonEncoder.withIndent('\t').convert(jsonData);
      await file.writeAsString(jsonString);

      _logger.info('Persisted ${_templates.length} templates to disk');
    } catch (e, stackTrace) {
      _logger.severe('Failed to persist templates', e, stackTrace);
    }
  }

  /// Gets the file handle for the templates JSON file.
  Future<File> _getTemplateFile() async {
    final supportDir = await getApplicationSupportDirectory();
    return File('${supportDir.path}/templates.json');
  }

  /// Notifies listeners that the template registry has changed.
  void _notifyChange() {
    changeNotifier.value++;
  }

  /// Clears all templates from memory.
  ///
  /// Primarily for testing. Does not delete the persisted file.
  void clear() {
    _templates.clear();
    _notifyChange();
  }
}
