import 'package:dart_mappable/dart_mappable.dart';
import 'package:rogueverse/ecs/dialog/dialog_nodes.dart';
import 'package:rogueverse/ecs/dialog/dialog_conditions.dart';
import 'package:rogueverse/ecs/dialog/dialog_effects.dart';
import 'package:rogueverse/ecs/entity.dart';

part 'dialog_content_nodes.mapper.dart';

/// A single choice in a ChoiceNode.
@MappableClass()
class Choice with ChoiceMappable {
  /// Display text for this choice.
  final String text;

  /// Condition that must be met for this choice to be available.
  /// If null, the choice is always available.
  final DialogCondition? condition;

  /// Label shown when condition fails (e.g., "[Speech 5]").
  final String? conditionLabel;

  /// Whether to show this choice when unavailable (grayed out).
  /// If false, the choice is hidden entirely when unavailable.
  final bool showWhenUnavailable;

  /// The node to advance to when this choice is selected.
  final DialogNode child;

  const Choice({
    required this.text,
    this.condition,
    this.conditionLabel,
    this.showWhenUnavailable = true,
    required this.child,
  });

  /// Checks if this choice is available for the given entities.
  bool isAvailable(Entity player, Entity npc) {
    if (condition == null) return true;
    return condition!.evaluate(player, npc);
  }
}

/// Node that displays NPC text and presents player choices.
///
/// This is the most common node type - the NPC says something and the
/// player picks a response. Combines text display with choice selection.
@MappableClass()
class SpeakNode extends DialogNode with SpeakNodeMappable {
  /// Name of the speaker (typically NPC name).
  final String speakerName;

  /// The text the speaker says.
  final String text;

  /// Available player responses.
  final List<Choice> choices;

  /// Effects to execute when this node is reached (before choices shown).
  final List<DialogEffect> effects;

  const SpeakNode({
    required this.speakerName,
    required this.text,
    required this.choices,
    this.effects = const [],
  });

  @override
  DialogResult advance(Entity player, Entity npc) {
    // Execute any effects first
    for (final effect in effects) {
      effect.execute(player, npc);
    }

    // Build available choices
    final dialogChoices = <DialogChoice>[];
    for (int i = 0; i < choices.length; i++) {
      final choice = choices[i];
      final available = choice.isAvailable(player, npc);

      if (available || choice.showWhenUnavailable) {
        dialogChoices.add(DialogChoice(
          text: choice.text,
          conditionLabel: choice.conditionLabel,
          isAvailable: available,
          choiceIndex: i,
        ));
      }
    }

    // Always add "(done)" option
    dialogChoices.add(DialogChoice(
      text: "(done)",
      conditionLabel: null,
      isAvailable: true,
      choiceIndex: -1, // Special index for exit
    ));

    return DialogAwaitingChoice(
      speakerName: speakerName,
      text: text,
      choices: dialogChoices,
    );
  }

  @override
  DialogNode? selectChoice(int choiceIndex) {
    if (choiceIndex == -1) return null; // "(done)" selected
    if (choiceIndex < 0 || choiceIndex >= choices.length) return null;
    return choices[choiceIndex].child;
  }

  @override
  void reset() {
    for (final choice in choices) {
      choice.child.reset();
    }
  }
}

/// Node that displays text then automatically continues to the next node.
///
/// Use for NPC monologue sections where no player choice is needed,
/// or for transition text between choice points.
@MappableClass()
class TextNode extends DialogNode with TextNodeMappable {
  /// Name of the speaker.
  final String speakerName;

  /// The text to display.
  final String text;

  /// The next node to advance to.
  final DialogNode? next;

  /// Effects to execute when this node is reached.
  final List<DialogEffect> effects;

  const TextNode({
    required this.speakerName,
    required this.text,
    this.next,
    this.effects = const [],
  });

  @override
  DialogResult advance(Entity player, Entity npc) {
    // Execute effects
    for (final effect in effects) {
      effect.execute(player, npc);
    }

    // Show text with appropriate continuation option
    // Use "(done)" if no next node or next is EndNode
    final choiceText = (next == null || next is EndNode) ? "(done)" : "(continue)";
    return DialogAwaitingChoice(
      speakerName: speakerName,
      text: text,
      choices: [
        DialogChoice(
          text: choiceText,
          conditionLabel: null,
          isAvailable: true,
          choiceIndex: 0, // Use 0 to indicate "continue to next"
        ),
      ],
    );
  }

  @override
  DialogNode? selectChoice(int choiceIndex) {
    // Return next node if it exists, otherwise null ends dialog
    return next;
  }

  @override
  void reset() {
    next?.reset();
  }
}

/// Node that ends the dialog.
///
/// When reached, the dialog closes immediately without showing text.
@MappableClass()
class EndNode extends DialogNode with EndNodeMappable {
  /// Effects to execute when dialog ends.
  final List<DialogEffect> effects;

  const EndNode({this.effects = const []});

  @override
  DialogResult advance(Entity player, Entity npc) {
    // Execute any final effects
    for (final effect in effects) {
      effect.execute(player, npc);
    }
    return const DialogEnded();
  }

  @override
  void reset() {}
}

/// Node that executes effects then continues to the next node.
///
/// Useful for triggering game changes mid-conversation without
/// showing any text (e.g., giving an item, advancing quest state).
@MappableClass()
class EffectNode extends DialogNode with EffectNodeMappable {
  /// Effects to execute.
  final List<DialogEffect> effects;

  /// The next node to continue to.
  final DialogNode next;

  const EffectNode({
    required this.effects,
    required this.next,
  });

  @override
  DialogResult advance(Entity player, Entity npc) {
    for (final effect in effects) {
      effect.execute(player, npc);
    }
    return next.advance(player, npc);
  }

  @override
  DialogNode? selectChoice(int choiceIndex) {
    return next.selectChoice(choiceIndex);
  }

  @override
  void reset() {
    next.reset();
  }
}

/// Node that branches based on a condition.
///
/// Evaluates the condition and continues to either the pass or fail branch.
/// Useful for automatic branching based on game state (skills, quests, etc.).
@MappableClass()
class ConditionalNode extends DialogNode with ConditionalNodeMappable {
  /// The condition to evaluate.
  final DialogCondition condition;

  /// Node to advance to if condition passes.
  final DialogNode onPass;

  /// Node to advance to if condition fails.
  final DialogNode onFail;

  const ConditionalNode({
    required this.condition,
    required this.onPass,
    required this.onFail,
  });

  @override
  DialogResult advance(Entity player, Entity npc) {
    if (condition.evaluate(player, npc)) {
      return onPass.advance(player, npc);
    } else {
      return onFail.advance(player, npc);
    }
  }

  @override
  DialogNode? selectChoice(int choiceIndex) {
    // Conditional nodes don't present choices directly
    return null;
  }

  @override
  void reset() {
    onPass.reset();
    onFail.reset();
  }
}
