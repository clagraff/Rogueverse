import 'package:flutter/material.dart';

import 'package:rogueverse/ecs/dialog/dialog.dart';
import 'package:rogueverse/app/screens/text_editor_screen.dart';
import 'package:rogueverse/app/widgets/overlays/dialog_editor/condition_editor.dart';
import 'package:rogueverse/app/widgets/overlays/dialog_editor/effect_editor.dart';

/// Right panel for editing the properties of a selected dialog node.
class DialogNodeEditor extends StatelessWidget {
  final DialogNode? node;
  final List<int> path;
  final void Function(DialogNode? newNode) onUpdate;
  final void Function(int childIndex) onNavigateToChild;
  final VoidCallback onNavigateUp;

  const DialogNodeEditor({
    super.key,
    required this.node,
    required this.path,
    required this.onUpdate,
    required this.onNavigateToChild,
    required this.onNavigateUp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
          ),
          child: Row(
            children: [
              if (path.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 20),
                  onPressed: onNavigateUp,
                  tooltip: 'Go to parent',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (path.isNotEmpty) const SizedBox(width: 8),
              Text(
                'Node Properties',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: node == null
              ? _buildEmptyState(context)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: _buildNodeEditor(context),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Text(
        'Select a node to edit',
        style: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildNodeEditor(BuildContext context) {
    final n = node!;

    if (n is SpeakNode) {
      return _SpeakNodeEditor(
        node: n,
        onUpdate: onUpdate,
        onNavigateToChild: onNavigateToChild,
      );
    } else if (n is TextNode) {
      return _TextNodeEditor(
        node: n,
        onUpdate: onUpdate,
        onNavigateToChild: onNavigateToChild,
      );
    } else if (n is EndNode) {
      return _EndNodeEditor(
        node: n,
        onUpdate: onUpdate,
      );
    } else if (n is EffectNode) {
      return _EffectNodeEditor(
        node: n,
        onUpdate: onUpdate,
        onNavigateToChild: onNavigateToChild,
      );
    } else if (n is ConditionalNode) {
      return _ConditionalNodeEditor(
        node: n,
        onUpdate: onUpdate,
        onNavigateToChild: onNavigateToChild,
      );
    }

    return Text('Unknown node type: ${n.runtimeType}');
  }
}

/// Editor for SpeakNode.
class _SpeakNodeEditor extends StatelessWidget {
  final SpeakNode node;
  final void Function(DialogNode?) onUpdate;
  final void Function(int childIndex) onNavigateToChild;

  const _SpeakNodeEditor({
    required this.node,
    required this.onUpdate,
    required this.onNavigateToChild,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Node type selector
        _NodeTypeSelector(node: node, onUpdate: onUpdate),
        const SizedBox(height: 16),

        // Text (speaker name will use NPC's Name component automatically)
        _buildTextField(
          context: context,
          label: 'Dialog Text',
          value: node.text,
          multiline: true,
          onChanged: (value) {
            onUpdate(SpeakNode(
              speakerName: node.speakerName,
              text: value,
              choices: node.choices,
              effects: node.effects,
            ));
          },
        ),
        const SizedBox(height: 16),

        // Effects
        EffectsListEditor(
          effects: node.effects,
          onUpdate: (effects) {
            onUpdate(SpeakNode(
              speakerName: node.speakerName,
              text: node.text,
              choices: node.choices,
              effects: effects,
            ));
          },
        ),
        const SizedBox(height: 16),

        // Choices
        Divider(color: colorScheme.outlineVariant),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Choices',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _addChoice(),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Choice'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        ...node.choices.asMap().entries.map((entry) {
          return _ChoiceEditor(
            index: entry.key,
            choice: entry.value,
            onUpdate: (newChoice) => _updateChoice(entry.key, newChoice),
            onDelete: () => _deleteChoice(entry.key),
            onNavigateToChild: () => onNavigateToChild(entry.key),
          );
        }),
      ],
    );
  }

  void _addChoice() {
    final newChoices = [
      ...node.choices,
      const Choice(
        text: 'New choice',
        child: EndNode(),
      ),
    ];
    onUpdate(SpeakNode(
      speakerName: node.speakerName,
      text: node.text,
      choices: newChoices,
      effects: node.effects,
    ));
  }

  void _updateChoice(int index, Choice newChoice) {
    final newChoices = List<Choice>.from(node.choices);
    newChoices[index] = newChoice;
    onUpdate(SpeakNode(
      speakerName: node.speakerName,
      text: node.text,
      choices: newChoices,
      effects: node.effects,
    ));
  }

  void _deleteChoice(int index) {
    if (node.choices.length <= 1) return; // Keep at least one choice
    final newChoices = List<Choice>.from(node.choices);
    newChoices.removeAt(index);
    onUpdate(SpeakNode(
      speakerName: node.speakerName,
      text: node.text,
      choices: newChoices,
      effects: node.effects,
    ));
  }
}

/// Editor for TextNode.
class _TextNodeEditor extends StatelessWidget {
  final TextNode node;
  final void Function(DialogNode?) onUpdate;
  final void Function(int childIndex) onNavigateToChild;

  const _TextNodeEditor({
    required this.node,
    required this.onUpdate,
    required this.onNavigateToChild,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Node type selector
        _NodeTypeSelector(node: node, onUpdate: onUpdate),
        const SizedBox(height: 16),

        // Text (speaker name will use NPC's Name component automatically)
        _buildTextField(
          context: context,
          label: 'Dialog Text',
          value: node.text,
          multiline: true,
          onChanged: (value) {
            onUpdate(TextNode(
              speakerName: node.speakerName,
              text: value,
              next: node.next,
              effects: node.effects,
            ));
          },
        ),
        const SizedBox(height: 16),

        // Effects
        EffectsListEditor(
          effects: node.effects,
          onUpdate: (effects) {
            onUpdate(TextNode(
              speakerName: node.speakerName,
              text: node.text,
              next: node.next,
              effects: effects,
            ));
          },
        ),
        const SizedBox(height: 16),

        // Next node
        _buildNextNodeSelector(
          context: context,
          hasNext: node.next != null,
          onNavigate: () => onNavigateToChild(0),
          onSetNext: (hasNext) {
            onUpdate(TextNode(
              speakerName: node.speakerName,
              text: node.text,
              next: hasNext ? const EndNode() : null,
              effects: node.effects,
            ));
          },
        ),
      ],
    );
  }
}

/// Editor for EndNode.
class _EndNodeEditor extends StatelessWidget {
  final EndNode node;
  final void Function(DialogNode?) onUpdate;

  const _EndNodeEditor({
    required this.node,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Node type selector
        _NodeTypeSelector(node: node, onUpdate: onUpdate),
        const SizedBox(height: 16),

        Text(
          'This node ends the dialog. Change the type above to continue the conversation.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),

        // Effects (executed when dialog ends)
        EffectsListEditor(
          effects: node.effects,
          onUpdate: (effects) {
            onUpdate(EndNode(effects: effects));
          },
        ),
      ],
    );
  }
}

/// Editor for EffectNode.
class _EffectNodeEditor extends StatelessWidget {
  final EffectNode node;
  final void Function(DialogNode?) onUpdate;
  final void Function(int childIndex) onNavigateToChild;

  const _EffectNodeEditor({
    required this.node,
    required this.onUpdate,
    required this.onNavigateToChild,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Node type selector
        _NodeTypeSelector(node: node, onUpdate: onUpdate),
        const SizedBox(height: 16),

        Text(
          'Executes effects then continues to next node.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),

        // Effects
        EffectsListEditor(
          effects: node.effects,
          onUpdate: (effects) {
            onUpdate(EffectNode(
              effects: effects,
              next: node.next,
            ));
          },
        ),
        const SizedBox(height: 16),

        // Next node button
        OutlinedButton.icon(
          onPressed: () => onNavigateToChild(0),
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Edit Next Node'),
        ),
      ],
    );
  }
}

/// Editor for ConditionalNode.
class _ConditionalNodeEditor extends StatelessWidget {
  final ConditionalNode node;
  final void Function(DialogNode?) onUpdate;
  final void Function(int childIndex) onNavigateToChild;

  const _ConditionalNodeEditor({
    required this.node,
    required this.onUpdate,
    required this.onNavigateToChild,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Node type selector
        _NodeTypeSelector(node: node, onUpdate: onUpdate),
        const SizedBox(height: 16),

        Text(
          'Branches based on a condition.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),

        // Condition editor
        ConditionEditor(
          condition: node.condition,
          onUpdate: (condition) {
            // ConditionalNode requires a non-null condition; default to AlwaysCondition
            onUpdate(ConditionalNode(
              condition: condition ?? const AlwaysCondition(),
              onPass: node.onPass,
              onFail: node.onFail,
            ));
          },
        ),
        const SizedBox(height: 16),

        // Branch buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onNavigateToChild(0),
                icon: const Icon(Icons.check, color: Colors.green),
                label: const Text('Edit Pass Branch'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onNavigateToChild(1),
                icon: const Icon(Icons.close, color: Colors.red),
                label: const Text('Edit Fail Branch'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Editor for a single choice in a SpeakNode.
class _ChoiceEditor extends StatelessWidget {
  final int index;
  final Choice choice;
  final void Function(Choice) onUpdate;
  final VoidCallback onDelete;
  final VoidCallback onNavigateToChild;

  const _ChoiceEditor({
    required this.index,
    required this.choice,
    required this.onUpdate,
    required this.onDelete,
    required this.onNavigateToChild,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Choice ${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18),
                  onPressed: onDelete,
                  tooltip: 'Delete choice',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Text
            _buildTextField(
              context: context,
              label: 'Choice Text',
              value: choice.text,
              onChanged: (value) {
                onUpdate(Choice(
                  text: value,
                  condition: choice.condition,
                  conditionLabel: choice.conditionLabel,
                  showWhenUnavailable: choice.showWhenUnavailable,
                  child: choice.child,
                ));
              },
            ),
            const SizedBox(height: 8),

            // Condition
            ConditionEditor(
              condition: choice.condition,
              onUpdate: (condition) {
                onUpdate(Choice(
                  text: choice.text,
                  condition: condition,
                  conditionLabel: choice.conditionLabel,
                  showWhenUnavailable: choice.showWhenUnavailable,
                  child: choice.child,
                ));
              },
            ),
            const SizedBox(height: 8),

            // Condition label
            _buildTextField(
              context: context,
              label: 'Condition Label (e.g., "[Speech 5]")',
              value: choice.conditionLabel ?? '',
              onChanged: (value) {
                onUpdate(Choice(
                  text: choice.text,
                  condition: choice.condition,
                  conditionLabel: value.isEmpty ? null : value,
                  showWhenUnavailable: choice.showWhenUnavailable,
                  child: choice.child,
                ));
              },
            ),
            const SizedBox(height: 8),

            // Show when unavailable
            Row(
              children: [
                Checkbox(
                  value: choice.showWhenUnavailable,
                  onChanged: (value) {
                    onUpdate(Choice(
                      text: choice.text,
                      condition: choice.condition,
                      conditionLabel: choice.conditionLabel,
                      showWhenUnavailable: value ?? true,
                      child: choice.child,
                    ));
                  },
                ),
                const SizedBox(width: 4),
                Text(
                  'Show when unavailable (grayed)',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Navigate to child
            OutlinedButton.icon(
              onPressed: onNavigateToChild,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Edit Child Node'),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widgets

/// Node type information for the dropdown.
class _NodeType {
  final String id;
  final String name;
  final IconData icon;

  const _NodeType(this.id, this.name, this.icon);
}

const _nodeTypes = [
  _NodeType('speak', 'SpeakNode', Icons.chat_bubble),
  _NodeType('text', 'TextNode', Icons.text_fields),
  _NodeType('end', 'EndNode', Icons.stop_circle),
  _NodeType('effect', 'EffectNode', Icons.flash_on),
  _NodeType('conditional', 'ConditionalNode', Icons.call_split),
];

/// Widget to select and change node type.
class _NodeTypeSelector extends StatelessWidget {
  final DialogNode node;
  final void Function(DialogNode?) onUpdate;

  const _NodeTypeSelector({
    required this.node,
    required this.onUpdate,
  });

  String _getNodeTypeId() {
    if (node is SpeakNode) return 'speak';
    if (node is TextNode) return 'text';
    if (node is EndNode) return 'end';
    if (node is EffectNode) return 'effect';
    if (node is ConditionalNode) return 'conditional';
    return 'end';
  }

  void _onTypeChanged(String? typeId) {
    if (typeId == null) return;

    // Try to preserve data when changing types
    final currentText = _extractText();
    final currentEffects = _extractEffects();

    DialogNode newNode;
    switch (typeId) {
      case 'speak':
        newNode = SpeakNode(
          speakerName: '', // Will use NPC name
          text: currentText,
          choices: const [Choice(text: 'Continue', child: EndNode())],
          effects: currentEffects,
        );
        break;
      case 'text':
        newNode = TextNode(
          speakerName: '', // Will use NPC name
          text: currentText,
          next: const EndNode(),
          effects: currentEffects,
        );
        break;
      case 'end':
        newNode = EndNode(effects: currentEffects);
        break;
      case 'effect':
        newNode = EffectNode(
          effects: currentEffects,
          next: const EndNode(),
        );
        break;
      case 'conditional':
        newNode = const ConditionalNode(
          condition: AlwaysCondition(),
          onPass: EndNode(),
          onFail: EndNode(),
        );
        break;
      default:
        return;
    }

    onUpdate(newNode);
  }

  String _extractText() {
    if (node is SpeakNode) return (node as SpeakNode).text;
    if (node is TextNode) return (node as TextNode).text;
    return 'Hello!';
  }

  List<DialogEffect> _extractEffects() {
    if (node is SpeakNode) return (node as SpeakNode).effects;
    if (node is TextNode) return (node as TextNode).effects;
    if (node is EndNode) return (node as EndNode).effects;
    if (node is EffectNode) return (node as EffectNode).effects;
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentTypeId = _getNodeTypeId();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Node Type',
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: currentTypeId,
          isExpanded: true,
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: _nodeTypes.map((type) {
            return DropdownMenuItem(
              value: type.id,
              child: Row(
                children: [
                  Icon(type.icon, size: 18, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(type.name),
                ],
              ),
            );
          }).toList(),
          onChanged: _onTypeChanged,
        ),
      ],
    );
  }
}

Widget _buildTextField({
  required BuildContext context,
  required String label,
  required String value,
  required void Function(String) onChanged,
  bool multiline = false,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          if (multiline) ...[
            const Spacer(),
            IconButton(
              icon: Icon(
                Icons.open_in_full,
                size: 16,
                color: colorScheme.primary,
              ),
              onPressed: () async {
                final result = await TextEditorScreen.show(
                  context,
                  title: label,
                  initialValue: value,
                );
                if (result != null) {
                  onChanged(result);
                }
              },
              tooltip: 'Edit in expanded view',
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ],
        ],
      ),
      const SizedBox(height: 4),
      TextFormField(
        initialValue: value,
        maxLines: multiline ? 3 : 1,
        onChanged: onChanged,
        decoration: const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    ],
  );
}

Widget _buildNextNodeSelector({
  required BuildContext context,
  required bool hasNext,
  required VoidCallback onNavigate,
  required void Function(bool) onSetNext,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Next Node',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Checkbox(
            value: hasNext,
            onChanged: (value) => onSetNext(value ?? false),
          ),
          const SizedBox(width: 4),
          Text(
            'Has continuation',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          if (hasNext) ...[
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: onNavigate,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Edit Next'),
            ),
          ],
        ],
      ),
    ],
  );
}
