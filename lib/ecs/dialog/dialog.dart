/// Dialog tree system for NPC conversations.
///
/// This library provides a tree-based dialog system similar to classic RPGs
/// like Fallout. Dialog trees support:
/// - Branching conversations with player choices
/// - Condition checks (skills, items, quests, etc.)
/// - Effects that modify game state (give/take items, heal, damage, etc.)
/// - Explicit tick control (game doesn't auto-tick during dialog)
library;

export 'dialog_nodes.dart';
export 'dialog_content_nodes.dart';
export 'dialog_conditions.dart';
export 'dialog_effects.dart' hide IgnoreHook;
