import 'dart:developer';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/systems/behavior_system.dart';
import 'package:rogueverse/ecs/systems/system.dart';
import 'package:rogueverse/ecs/world.dart';

part 'dialog_system.mapper.dart';

/// System that processes dialog intents.
///
/// Handles:
/// - TalkIntent: Starts a dialog with an NPC (creates ActiveDialog)
/// - DialogAdvanceIntent: Advances dialog by selecting a choice
/// - DialogExitIntent: Exits dialog early
///
/// Dialog state is stored on the player entity as an ActiveDialog component.
/// Dialog nodes are independent entities with DialogNode components.
@MappableClass()
class DialogSystem extends System with DialogSystemMappable {
  static final _logger = Logger('DialogSystem');

  @override
  Set<Type> get runAfter => {BehaviorSystem};

  @override
  void update(World world) {
    Timeline.timeSync("DialogSystem: update", () {
      _processTalkIntents(world);
      _processAdvanceIntents(world);
      _processExitIntents(world);
    });
  }

  /// Process TalkIntent - start dialog with an NPC.
  void _processTalkIntents(World world) {
    final intents = Map.from(world.get<TalkIntent>());
    for (final entry in intents.entries) {
      final playerId = entry.key;
      final intent = entry.value as TalkIntent;
      final player = world.getEntity(playerId);

      player.remove<TalkIntent>();

      final npc = world.getEntity(intent.targetEntityId);
      final dialogRef = npc.get<DialogRef>();
      if (dialogRef == null) {
        _logger.warning("NPC has no DialogRef", {"npcId": intent.targetEntityId});
        continue;
      }

      // Verify the root node exists and has DialogNode
      final rootNode = world.getEntity(dialogRef.rootNodeId);
      final dialogNode = rootNode.get<DialogNode>();
      if (dialogNode == null) {
        _logger.warning("dialog root node missing DialogNode component", {
          "npcId": intent.targetEntityId,
          "rootNodeId": dialogRef.rootNodeId,
        });
        continue;
      }

      // Set active dialog on player
      player.upsert(ActiveDialog(
        npcEntityId: intent.targetEntityId,
        currentNodeId: dialogRef.rootNodeId,
      ));

      _logger.fine("started dialog", {
        "playerId": playerId,
        "npcId": intent.targetEntityId,
        "nodeId": dialogRef.rootNodeId,
      });
    }
  }

  /// Process DialogAdvanceIntent - advance dialog by selecting a choice.
  void _processAdvanceIntents(World world) {
    final intents = Map.from(world.get<DialogAdvanceIntent>());
    for (final entry in intents.entries) {
      final playerId = entry.key;
      final intent = entry.value as DialogAdvanceIntent;
      final player = world.getEntity(playerId);

      player.remove<DialogAdvanceIntent>();

      final active = player.get<ActiveDialog>();
      if (active == null) {
        _logger.finest("no active dialog", {"playerId": playerId});
        continue;
      }

      final currentNodeEntity = world.getEntity(active.currentNodeId);
      final dialogNode = currentNodeEntity.get<DialogNode>();
      if (dialogNode == null) {
        _logger.warning("current dialog node missing DialogNode", {
          "nodeId": active.currentNodeId,
        });
        player.remove<ActiveDialog>();
        continue;
      }

      // Validate choice index
      if (intent.choiceIndex < 0 || intent.choiceIndex >= dialogNode.choices.length) {
        _logger.warning("invalid choice index", {
          "choiceIndex": intent.choiceIndex,
          "choicesCount": dialogNode.choices.length,
        });
        continue;
      }

      final choice = dialogNode.choices[intent.choiceIndex];

      // null targetNodeId = end dialog
      if (choice.targetNodeId == null) {
        player.remove<ActiveDialog>();
        _logger.fine("dialog ended by choice", {"playerId": playerId});
        continue;
      }

      // Verify target node exists
      final nextNode = world.getEntity(choice.targetNodeId!);
      final nextDialogNode = nextNode.get<DialogNode>();
      if (nextDialogNode == null) {
        _logger.warning("target node missing DialogNode", {
          "targetNodeId": choice.targetNodeId,
        });
        player.remove<ActiveDialog>();
        continue;
      }

      // Update to next node (keep same NPC)
      player.upsert(ActiveDialog(
        npcEntityId: active.npcEntityId,
        currentNodeId: choice.targetNodeId!,
      ));

      _logger.fine("advanced dialog", {
        "playerId": playerId,
        "fromNodeId": active.currentNodeId,
        "toNodeId": choice.targetNodeId,
        "choice": choice.text,
      });
    }
  }

  /// Process DialogExitIntent - exit dialog early.
  void _processExitIntents(World world) {
    final intents = Map.from(world.get<DialogExitIntent>());
    for (final entry in intents.entries) {
      final playerId = entry.key;
      final player = world.getEntity(playerId);

      player.remove<DialogExitIntent>();
      player.remove<ActiveDialog>();

      _logger.fine("dialog exited early", {"playerId": playerId});
    }
  }
}
