import 'dart:math';

import 'package:flutter/material.dart';

import 'package:rogueverse/ecs/dialog/dialog.dart';
import 'package:rogueverse/app/screens/text_editor_screen.dart';
import 'package:rogueverse/app/widgets/overlays/dialog_editor/condition_editor.dart';
import 'package:rogueverse/app/widgets/overlays/dialog_editor/effect_editor.dart';

/// Generates a short random ID for dialog nodes (8 hex characters).
String generateNodeId() {
  final random = Random();
  return List.generate(8, (_) => random.nextInt(16).toRadixString(16)).join();
}

/// Provides access to the dialog tree context (node ID registry) from anywhere
/// in the editor widget tree.
class DialogTreeContext extends InheritedWidget {
  /// Map of node IDs to nodes in the current dialog tree.
  final NodeIdRegistry registry;

  const DialogTreeContext({
    super.key,
    required this.registry,
    required super.child,
  });

  static DialogTreeContext? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DialogTreeContext>();
  }

  @override
  bool updateShouldNotify(DialogTreeContext oldWidget) {
    return registry != oldWidget.registry;
  }
}

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
    } else if (n is GotoNode) {
      return _GotoNodeEditor(
        node: n,
        onUpdate: onUpdate,
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

        // Node ID field
        _NodeIdField(
          nodeId: node.id,
          onUpdate: (id) {
            onUpdate(SpeakNode(
              id: id,
              speakerName: node.speakerName,
              text: node.text,
              choices: node.choices,
              effects: node.effects,
            ));
          },
        ),
        const SizedBox(height: 16),

        // Text (speaker name will use NPC's Name component automatically)
        _TextField(
          label: 'Dialog Text',
          value: node.text,
          multiline: true,
          onChanged: (value) {
            onUpdate(SpeakNode(
              id: node.id,
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
              id: node.id,
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
      Choice(
        text: 'New choice',
        child: EndNode(id: generateNodeId()),
      ),
    ];
    onUpdate(SpeakNode(
      id: node.id,
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
      id: node.id,
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
      id: node.id,
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

        // Node ID field
        _NodeIdField(
          nodeId: node.id,
          onUpdate: (id) {
            onUpdate(TextNode(
              id: id,
              speakerName: node.speakerName,
              text: node.text,
              next: node.next,
              effects: node.effects,
              continueText: node.continueText,
            ));
          },
        ),
        const SizedBox(height: 16),

        // Text (speaker name will use NPC's Name component automatically)
        _TextField(
          label: 'Dialog Text',
          value: node.text,
          multiline: true,
          onChanged: (value) {
            onUpdate(TextNode(
              id: node.id,
              speakerName: node.speakerName,
              text: value,
              next: node.next,
              effects: node.effects,
              continueText: node.continueText,
            ));
          },
        ),
        const SizedBox(height: 16),

        // Continue text
        _TextField(
          label: 'Continue Button Text',
          value: node.continueText,
          onChanged: (value) {
            onUpdate(TextNode(
              id: node.id,
              speakerName: node.speakerName,
              text: node.text,
              next: node.next,
              effects: node.effects,
              continueText: value.isEmpty ? '(continue)' : value,
            ));
          },
        ),
        const SizedBox(height: 16),

        // Effects
        EffectsListEditor(
          effects: node.effects,
          onUpdate: (effects) {
            onUpdate(TextNode(
              id: node.id,
              speakerName: node.speakerName,
              text: node.text,
              next: node.next,
              effects: effects,
              continueText: node.continueText,
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
              id: node.id,
              speakerName: node.speakerName,
              text: node.text,
              next: hasNext ? EndNode(id: generateNodeId()) : null,
              effects: node.effects,
              continueText: node.continueText,
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

        // Node ID field
        _NodeIdField(
          nodeId: node.id,
          onUpdate: (id) {
            onUpdate(EndNode(id: id, effects: node.effects));
          },
        ),
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
            onUpdate(EndNode(id: node.id, effects: effects));
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

        // Node ID field
        _NodeIdField(
          nodeId: node.id,
          onUpdate: (id) {
            onUpdate(EffectNode(
              id: id,
              effects: node.effects,
              next: node.next,
            ));
          },
        ),
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
              id: node.id,
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

        // Node ID field
        _NodeIdField(
          nodeId: node.id,
          onUpdate: (id) {
            onUpdate(ConditionalNode(
              id: id,
              condition: node.condition,
              onPass: node.onPass,
              onFail: node.onFail,
            ));
          },
        ),
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
              id: node.id,
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

/// Editor for GotoNode.
class _GotoNodeEditor extends StatelessWidget {
  final GotoNode node;
  final void Function(DialogNode?) onUpdate;

  const _GotoNodeEditor({
    required this.node,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Check if target ID is valid
    final treeContext = DialogTreeContext.of(context);
    final targetExists = node.targetId.isEmpty ||
        (treeContext?.registry.containsKey(node.targetId) ?? true);
    final isSelfReference = node.targetId == node.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Node type selector
        _NodeTypeSelector(node: node, onUpdate: onUpdate),
        const SizedBox(height: 16),

        // Node ID field
        _NodeIdField(
          nodeId: node.id,
          onUpdate: (id) {
            onUpdate(GotoNode(
              id: id,
              targetId: node.targetId,
            ));
          },
        ),
        const SizedBox(height: 16),

        Text(
          'Jumps to a labeled node elsewhere in the dialog tree.',
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),

        // Target ID field with validation
        _GotoTargetField(
          targetId: node.targetId,
          hasError: !targetExists || isSelfReference,
          onChanged: (value) {
            onUpdate(GotoNode(
              id: node.id,
              targetId: value,
            ));
          },
        ),
        const SizedBox(height: 8),

        // Validation message
        if (isSelfReference)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.error, size: 16, color: colorScheme.error),
                const SizedBox(width: 4),
                Text(
                  'Cannot reference itself',
                  style: TextStyle(color: colorScheme.error, fontSize: 12),
                ),
              ],
            ),
          )
        else if (!targetExists && node.targetId.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.warning, size: 16, color: colorScheme.error),
                const SizedBox(width: 4),
                Text(
                  'Target node ID not found',
                  style: TextStyle(color: colorScheme.error, fontSize: 12),
                ),
              ],
            ),
          ),

        Text(
          'Enter the ID of the node to jump to. If the ID is not found, the dialog will end.',
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: 12,
          ),
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
            _TextField(
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
            _TextField(
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
  _NodeType('goto', 'GotoNode', Icons.shortcut),
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
    if (node is GotoNode) return 'goto';
    return 'end';
  }

  void _onTypeChanged(String? typeId) {
    if (typeId == null) return;

    // Try to preserve data when changing types
    final currentText = _extractText();
    final currentEffects = _extractEffects();
    final currentId = node.id; // Preserve the existing ID

    DialogNode newNode;
    switch (typeId) {
      case 'speak':
        newNode = SpeakNode(
          id: currentId,
          speakerName: '', // Will use NPC name
          text: currentText,
          choices: [Choice(text: 'Continue', child: EndNode(id: generateNodeId()))],
          effects: currentEffects,
        );
        break;
      case 'text':
        newNode = TextNode(
          id: currentId,
          speakerName: '', // Will use NPC name
          text: currentText,
          next: EndNode(id: generateNodeId()),
          effects: currentEffects,
        );
        break;
      case 'end':
        newNode = EndNode(id: currentId, effects: currentEffects);
        break;
      case 'effect':
        newNode = EffectNode(
          id: currentId,
          effects: currentEffects,
          next: EndNode(id: generateNodeId()),
        );
        break;
      case 'conditional':
        newNode = ConditionalNode(
          id: currentId,
          condition: const AlwaysCondition(),
          onPass: EndNode(id: generateNodeId()),
          onFail: EndNode(id: generateNodeId()),
        );
        break;
      case 'goto':
        newNode = GotoNode(
          id: currentId,
          targetId: '',
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

/// Widget for editing text fields that properly handles external value changes.
///
/// Uses a StatefulWidget with TextEditingController to properly handle
/// external value changes (e.g., when navigating between nodes).
class _TextField extends StatefulWidget {
  final String label;
  final String value;
  final void Function(String) onChanged;
  final bool multiline;

  const _TextField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.multiline = false,
  });

  @override
  State<_TextField> createState() => _TextFieldState();
}

class _TextFieldState extends State<_TextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_TextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller when the value changes externally (e.g., navigating to different node)
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            if (widget.multiline) ...[
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
                    title: widget.label,
                    initialValue: widget.value,
                  );
                  if (result != null) {
                    widget.onChanged(result);
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
          controller: _controller,
          maxLines: widget.multiline ? 3 : 1,
          onChanged: widget.onChanged,
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }
}

/// Widget for editing a node's ID.
///
/// Uses a StatefulWidget with TextEditingController to properly handle
/// external value changes (e.g., when navigating between nodes).
class _NodeIdField extends StatefulWidget {
  final String nodeId;
  final void Function(String) onUpdate;

  const _NodeIdField({
    required this.nodeId,
    required this.onUpdate,
  });

  @override
  State<_NodeIdField> createState() => _NodeIdFieldState();
}

class _NodeIdFieldState extends State<_NodeIdField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.nodeId);
  }

  @override
  void didUpdateWidget(_NodeIdField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller when the ID changes externally (e.g., navigating to different node)
    // Must also check _controller.text to avoid resetting during typing (like _TextField)
    if (widget.nodeId != oldWidget.nodeId && widget.nodeId != _controller.text) {
      _controller.text = widget.nodeId;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Node ID',
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _controller,
          onChanged: (value) {
            if (value.isNotEmpty) {
              widget.onUpdate(value);
            }
          },
          decoration: InputDecoration(
            isDense: true,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            hintText: 'e.g., main_menu',
            hintStyle: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            prefixIcon: Icon(Icons.tag, size: 18, color: colorScheme.primary),
          ),
        ),
      ],
    );
  }
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

/// Widget for editing a GotoNode's target ID with validation styling.
class _GotoTargetField extends StatefulWidget {
  final String targetId;
  final bool hasError;
  final void Function(String) onChanged;

  const _GotoTargetField({
    required this.targetId,
    required this.hasError,
    required this.onChanged,
  });

  @override
  State<_GotoTargetField> createState() => _GotoTargetFieldState();
}

class _GotoTargetFieldState extends State<_GotoTargetField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.targetId);
  }

  @override
  void didUpdateWidget(_GotoTargetField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.targetId != oldWidget.targetId && widget.targetId != _controller.text) {
      _controller.text = widget.targetId;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Node ID',
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _controller,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            isDense: true,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            hintText: 'e.g., main_menu',
            hintStyle: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            prefixIcon: Icon(
              Icons.shortcut,
              size: 18,
              color: widget.hasError ? colorScheme.error : colorScheme.primary,
            ),
            enabledBorder: widget.hasError
                ? OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.error),
                  )
                : null,
            focusedBorder: widget.hasError
                ? OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.error, width: 2),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
