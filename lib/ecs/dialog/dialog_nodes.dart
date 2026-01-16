import 'package:dart_mappable/dart_mappable.dart';
import 'package:rogueverse/ecs/entity.dart';

part 'dialog_nodes.mapper.dart';

/// Result of advancing through a dialog node.
///
/// Unlike behavior trees which run automatically, dialog trees are player-driven
/// and wait for input at choice points.
@MappableClass()
sealed class DialogResult with DialogResultMappable {
  const DialogResult();
}

/// Dialog has reached a point that requires player input (choices).
@MappableClass()
class DialogAwaitingChoice extends DialogResult with DialogAwaitingChoiceMappable {
  final String speakerName;
  final String text;
  final List<DialogChoice> choices;

  const DialogAwaitingChoice({
    required this.speakerName,
    required this.text,
    required this.choices,
  });
}

/// Dialog has ended (reached an EndNode or final text with no continuation).
@MappableClass()
class DialogEnded extends DialogResult with DialogEndedMappable {
  const DialogEnded();
}

/// A choice available to the player.
@MappableClass()
class DialogChoice with DialogChoiceMappable {
  /// Display text for this choice.
  final String text;

  /// If unavailable, shows why (e.g., "[Speech 5]").
  final String? conditionLabel;

  /// Whether this choice can currently be selected.
  final bool isAvailable;

  /// Index into the parent ChoiceNode's children for navigation.
  final int choiceIndex;

  const DialogChoice({
    required this.text,
    this.conditionLabel,
    required this.isAvailable,
    required this.choiceIndex,
  });
}

/// Base class for all dialog tree nodes.
///
/// Dialog trees are similar to behavior trees but are player-driven rather
/// than AI-driven. They pause at ChoiceNodes waiting for player selection.
@MappableClass()
abstract class DialogNode with DialogNodeMappable {
  const DialogNode();

  /// Advances the dialog from this node.
  ///
  /// Returns a [DialogResult] indicating what happened:
  /// - [DialogAwaitingChoice]: Reached a choice point, waiting for player input
  /// - [DialogEnded]: Dialog has concluded
  ///
  /// The [player] and [npc] entities are provided for condition/effect evaluation.
  DialogResult advance(Entity player, Entity npc);

  /// Selects a choice at a choice point and returns the next node to process.
  ///
  /// Only meaningful for nodes that can present choices.
  /// Returns null if selection is invalid or node doesn't support selection.
  DialogNode? selectChoice(int choiceIndex) => null;

  /// Resets this node and all children to initial state.
  void reset();
}
