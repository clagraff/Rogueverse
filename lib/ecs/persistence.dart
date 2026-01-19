import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:json_patch/json_patch.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rogueverse/ecs/world.dart';

/// Handles world state persistence: saving, loading, and migration.
///
/// Uses a layered save system:
/// - `initial.json`: The authored world state (edited in editor mode)
/// - `*.patch.json`: RFC 6902 patches representing player progress
class Persistence {
  static final Logger _logger = Logger("Persistence");

  /// In-memory copy of the initial state Map, used for computing save diffs.
  /// Set during loadInitialState() or loadSaveWithPatch().
  static Map<String, dynamic>? _cachedInitialState;

  /// Simple lock to prevent concurrent write operations.
  static bool _writeLock = false;

  /// The path to the current save patch file for this game session.
  /// Set by loadSaveWithPatch() or setCurrentSavePath().
  /// Used by SaveSystem for periodic saves.
  static String? _currentSavePatchPath;

  /// Gets the current save patch path. Returns null if no save is loaded.
  static String? get currentSavePatchPath => _currentSavePatchPath;

  /// Sets the current save patch path for this game session.
  static void setCurrentSavePath(String? path) {
    _currentSavePatchPath = path;
    _logger.info("set current save path", {"path": path});
  }

  /// Returns a read-only reference to the cached initial state.
  /// Throws if no initial state is loaded.
  static Map<String, dynamic> get initialState {
    if (_cachedInitialState == null) {
      throw StateError(
          'No initial state loaded. Call loadInitialState() or loadSaveWithPatch() first.');
    }
    return _cachedInitialState!;
  }

  /// Migrates existing save files to new structure if needed.
  /// Call this once during app startup before loading.
  static Future<void> migrateIfNeeded() async {
    var supportDir = await getApplicationSupportDirectory();

    // Migration 1: save.json -> initial.json
    var oldSaveFile = File("${supportDir.path}/save.json");
    var newInitialFile = File("${supportDir.path}/initial.json");

    if (oldSaveFile.existsSync() && !newInitialFile.existsSync()) {
      _logger.info("migrating save.json to initial.json");
      await oldSaveFile.rename(newInitialFile.path);
    }

    // Migration 2: save.patch.json -> saves/default.patch.json
    var oldPatchFile = File("${supportDir.path}/save.patch.json");
    if (await oldPatchFile.exists()) {
      var savesDir = await getSavesDirectory();
      var newPatchFile = File("${savesDir.path}/default.patch.json");
      _logger.info("migrating save.patch.json to saves/default.patch.json");
      await oldPatchFile.rename(newPatchFile.path);
    }
  }

  /// Loads the initial state from initial.json.
  /// Caches the Map in memory for future diff computations.
  /// Returns null if initial.json doesn't exist.
  static Future<World?> loadInitialState() async {
    var task = TimelineTask(filterKey: "fileio");
    task.start("save: read initial");

    try {
      var supportDir = await getApplicationSupportDirectory();
      var initialFile = File("${supportDir.path}/initial.json");

      if (!initialFile.existsSync()) {
        _logger.info("no initial.json found");
        return null;
      }

      _logger.info(
          "loading initial state", {"path": "${supportDir.path}/initial.json"});
      var jsonContents = initialFile.readAsStringSync();

      // Cache the parsed Map for diffing later
      _cachedInitialState = jsonDecode(jsonContents) as Map<String, dynamic>;

      return WorldMapper.fromJson(jsonContents);
    } finally {
      task.finish();
    }
  }

  /// Loads the game by reading initial.json and applying a save patch.
  ///
  /// [savePatchPath] - Optional path to the save patch file. If null, loads
  /// initial state only (no patch applied).
  ///
  /// Flow:
  /// 1. Load initial.json (caches in memory)
  /// 2. If savePatchPath provided and exists, apply it to get current state
  /// 3. Return the resulting World
  ///
  /// Throws if patch application fails.
  static Future<World?> loadSaveWithPatch([String? savePatchPath]) async {
    var task = TimelineTask(filterKey: "fileio");
    task.start("save: load with patch");

    try {
      var supportDir = await getApplicationSupportDirectory();
      var initialFile = File("${supportDir.path}/initial.json");

      // Step 1: Load initial state
      if (!initialFile.existsSync()) {
        _logger.info("no initial.json found");
        return null;
      }

      _logger.info("loading initial state", {"path": initialFile.path});
      var initialJson =
          jsonDecode(initialFile.readAsStringSync()) as Map<String, dynamic>;

      // Cache initial state for future diff operations (deep copy)
      _cachedInitialState =
          jsonDecode(jsonEncode(initialJson)) as Map<String, dynamic>;

      // Store the current save path for this session
      _currentSavePatchPath = savePatchPath;

      // Step 2: Apply patch if exists
      Map<String, dynamic> finalState;
      if (savePatchPath != null) {
        var patchFile = File(savePatchPath);
        if (patchFile.existsSync()) {
          _logger.info("applying save patch", {"path": patchFile.path});
          var patchJson =
              jsonDecode(patchFile.readAsStringSync()) as List<dynamic>;
          var patchOps = patchJson.cast<Map<String, dynamic>>();

          // Apply RFC 6902 patch
          try {
            finalState = JsonPatch.apply(initialJson, patchOps, strict: false)
                as Map<String, dynamic>;
          } catch (e) {
            _logger.warning(
                "Failed to apply save patch - initial state may have changed. "
                "Discarding patch and using initial state only.",
                {"error": e.toString(), "patchPath": patchFile.path});
            // Fall back to initial state without patch
            finalState = initialJson;
          }
        } else {
          _logger.info("save patch file not found, using initial state",
              {"path": savePatchPath});
          finalState = initialJson;
        }
      } else {
        _logger.info("no save patch path provided, using initial state");
        finalState = initialJson;
      }

      // Step 3: Deserialize to World
      return WorldMapper.fromMap(finalState);
    } finally {
      task.finish();
    }
  }

  /// Computes the diff between initial state and current world,
  /// then writes the patch to the specified save file.
  ///
  /// [savePatchPath] - Optional path to write the save patch. If null, uses
  /// the current save path set by loadSaveWithPatch() or setCurrentSavePath().
  ///
  /// Uses the cached initial state from loadInitialState/loadSaveWithPatch.
  /// Throws StateError if no initial state is cached or no save path is set.
  static Future<void> writeSavePatch(World world, [String? savePatchPath]) async {
    var effectivePath = savePatchPath ?? _currentSavePatchPath;
    if (effectivePath == null) {
      _logger.warning("no save path specified and no current save path set, skipping");
      return;
    }

    if (_writeLock) {
      _logger.warning("write operation already in progress, skipping");
      return;
    }
    _writeLock = true;

    var task = TimelineTask(filterKey: "fileio");
    task.start("save: write patch");

    try {
      if (_cachedInitialState == null) {
        throw StateError('Cannot write save patch: no initial state loaded.');
      }

      var patchFile = File(effectivePath);

      // Get current state as Map
      var currentState = world.toMap();

      // Compute RFC 6902 patch
      var patchOps = JsonPatch.diff(_cachedInitialState!, currentState);

      // Write patch to file
      _logger.info("writing save patch",
          {"path": patchFile.path, "opCount": patchOps.length});

      var patchJson = JsonEncoder.withIndent("\t").convert(patchOps);
      var writer = patchFile.openWrite();
      writer.write(patchJson);
      await writer.flush();
      await writer.close();
    } finally {
      _writeLock = false;
      task.finish();
    }
  }

  /// Writes the complete world state to initial.json.
  /// Used by the editor to save authored content.
  /// Also updates the cached initial state.
  static Future<void> writeInitialState(World world,
      [bool indent = true]) async {
    if (_writeLock) {
      _logger.warning("write operation already in progress, skipping");
      return;
    }
    _writeLock = true;

    var task = TimelineTask(filterKey: "fileio");
    task.start("save: write initial");

    try {
      var indentChar = indent ? "\t" : "";
      var worldMap = world.toMap();
      var saveState = JsonEncoder.withIndent(indentChar).convert(worldMap);
      var supportDir = await getApplicationSupportDirectory();
      var initialFile = File("${supportDir.path}/initial.json");

      _logger.info("writing initial state", {"path": initialFile.path});

      var writer = initialFile.openWrite();
      writer.write(saveState);
      await writer.flush();
      await writer.close();

      // Update cached initial state (deep copy)
      _cachedInitialState =
          jsonDecode(jsonEncode(worldMap)) as Map<String, dynamic>;
    } finally {
      _writeLock = false;
      task.finish();
    }
  }

  /// Clears the save patch file (used when editor changes make patch invalid).
  static Future<void> clearSavePatch() async {
    var supportDir = await getApplicationSupportDirectory();
    var patchFile = File("${supportDir.path}/save.patch.json");

    if (patchFile.existsSync()) {
      _logger.info("clearing save patch", {"path": patchFile.path});
      await patchFile.delete();
    }
  }

  /// Legacy method - kept for backward compatibility during transition.
  /// Prefer writeInitialState() for editor saves and writeSavePatch() for gameplay saves.
  @Deprecated('Use writeInitialState() or writeSavePatch() instead')
  static Future<void> writeSave(World world, [bool indent = true]) async {
    await writeInitialState(world, indent);
  }

  /// Gets (and creates if needed) the saves directory.
  static Future<Directory> getSavesDirectory() async {
    var supportDir = await getApplicationSupportDirectory();
    var savesDir = Directory("${supportDir.path}/saves");
    if (!await savesDir.exists()) {
      await savesDir.create(recursive: true);
    }
    return savesDir;
  }

  /// Lists all save files in the saves directory.
  /// Returns saves sorted by last modified date (newest first).
  static Future<List<SaveFileInfo>> listSaves() async {
    var savesDir = await getSavesDirectory();
    var saves = <SaveFileInfo>[];

    await for (var entity in savesDir.list()) {
      if (entity is File && entity.path.endsWith('.patch.json')) {
        var stat = await entity.stat();
        var fileName = entity.uri.pathSegments.last;
        var name = fileName.replaceAll('.patch.json', '');
        saves.add(SaveFileInfo(
          name: name,
          path: entity.path,
          lastModified: stat.modified,
        ));
      }
    }

    // Sort by last modified, newest first
    saves.sort((a, b) => b.lastModified.compareTo(a.lastModified));
    return saves;
  }

  /// Creates a new save file with the given name.
  /// Returns the path to the new save file.
  /// Throws if a save with this name already exists.
  static Future<String> createNewSave(String name) async {
    var savesDir = await getSavesDirectory();
    var savePath = "${savesDir.path}/$name.patch.json";
    var saveFile = File(savePath);

    if (await saveFile.exists()) {
      throw StateError('Save file "$name" already exists.');
    }

    // Write empty patch array
    await saveFile.writeAsString('[]');
    _logger.info("created new save", {"path": savePath});
    return savePath;
  }

  /// Deletes a save file.
  static Future<void> deleteSave(String savePath) async {
    var file = File(savePath);
    if (await file.exists()) {
      await file.delete();
      _logger.info("deleted save", {"path": savePath});
    }
  }
}

/// Information about a save file.
class SaveFileInfo {
  final String name;
  final String path;
  final DateTime lastModified;

  SaveFileInfo({
    required this.name,
    required this.path,
    required this.lastModified,
  });
}

/// Backward compatibility alias - use [Persistence] instead.
@Deprecated('Use Persistence instead')
typedef WorldSaves = Persistence;
