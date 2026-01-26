import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/app/ui_constants.dart';

/// Full-screen editor for dialog graphs attached to NPC entities.
///
/// Dialog nodes are now independent entities with DialogNode components.
/// This editor shows the graph starting from an NPC's DialogRef and allows
/// creating/editing dialog node entities.
class DialogEditorScreen extends StatefulWidget {
  /// The NPC entity with a DialogRef component.
  final Entity entity;

  const DialogEditorScreen({
    super.key,
    required this.entity,
  });

  @override
  State<DialogEditorScreen> createState() => _DialogEditorScreenState();
}

class _DialogEditorScreenState extends State<DialogEditorScreen> {
  /// Currently selected dialog node entity ID.
  int? _selectedNodeId;

  /// Set of node IDs discovered in the graph.
  Set<int> _discoveredNodes = {};

  World get _world => widget.entity.parentCell;

  @override
  void initState() {
    super.initState();
    _discoverGraph();
  }

  /// Discovers all nodes reachable from the NPC's DialogRef.
  void _discoverGraph() {
    _discoveredNodes = {};

    final dialogRef = widget.entity.get<DialogRef>();
    if (dialogRef == null) return;

    _discoverFromNode(dialogRef.rootNodeId);
    _selectedNodeId ??= dialogRef.rootNodeId;
  }

  void _discoverFromNode(int nodeId) {
    if (_discoveredNodes.contains(nodeId)) return;

    final nodeEntity = _world.getEntity(nodeId);
    final dialogNode = nodeEntity.get<DialogNode>();
    if (dialogNode == null) return;

    _discoveredNodes.add(nodeId);

    // Follow choice targets
    for (final choice in dialogNode.choices) {
      if (choice.targetNodeId != null) {
        _discoverFromNode(choice.targetNodeId!);
      }
    }
  }

  void _handleClose() {
    Navigator.of(context).pop();
  }

  void _createNewNode() async {
    // Create a new dialog node entity
    final newEntity = _world.add([
      DialogNode(
        text: 'New dialog text',
        choices: [DialogChoice(text: 'Continue')],
      ),
      Name(name: 'Dialog Node'),
    ]);

    setState(() {
      _discoveredNodes.add(newEntity.id);
      _selectedNodeId = newEntity.id;
    });
  }

  void _setAsRootNode(int nodeId) {
    widget.entity.upsert(DialogRef(rootNodeId: nodeId));
    setState(() {
      _discoverGraph();
    });
  }

  void _deleteNode(int nodeId) {
    // Don't delete if it's the root node
    final dialogRef = widget.entity.get<DialogRef>();
    if (dialogRef?.rootNodeId == nodeId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete root node')),
      );
      return;
    }

    _world.remove(nodeId);
    setState(() {
      _discoveredNodes.remove(nodeId);
      if (_selectedNodeId == nodeId) {
        _selectedNodeId = _discoveredNodes.firstOrNull;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final npcName = widget.entity.get<Name>()?.name ?? 'Unknown';
    final dialogRef = widget.entity.get<DialogRef>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleClose,
          tooltip: 'Back (Esc)',
        ),
        title: Row(
          children: [
            const Icon(Icons.chat),
            const SizedBox(width: 8),
            Text('Dialog Editor - $npcName'),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _createNewNode,
            icon: const Icon(Icons.add),
            label: const Text('New Node'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              _handleClose();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: dialogRef == null
            ? _buildNoDialogRef(colorScheme)
            : Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left panel - Node list
                  SizedBox(
                    width: 300,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: colorScheme.outlineVariant),
                        ),
                      ),
                      child: _buildNodeList(colorScheme, dialogRef.rootNodeId),
                    ),
                  ),

                  // Right panel - Node editor
                  Expanded(
                    child: _selectedNodeId != null
                        ? _buildNodeEditor(colorScheme, _selectedNodeId!)
                        : _buildNoSelection(colorScheme),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildNoDialogRef(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: kSpacingL),
          Text(
            'No DialogRef on this entity',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: kSpacingL),
          FilledButton.icon(
            onPressed: () {
              // Create a root dialog node and set the DialogRef
              final rootNode = _world.add([
                DialogNode(
                  text: 'Hello!',
                  choices: [DialogChoice(text: 'Goodbye')],
                ),
                Name(name: 'Root Dialog'),
              ]);
              widget.entity.upsert(DialogRef(rootNodeId: rootNode.id));
              setState(() {
                _discoverGraph();
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Dialog'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSelection(ColorScheme colorScheme) {
    return Center(
      child: Text(
        'Select a node to edit',
        style: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildNodeList(ColorScheme colorScheme, int rootNodeId) {
    final sortedNodes = _discoveredNodes.toList()
      ..sort((a, b) => a == rootNodeId ? -1 : (b == rootNodeId ? 1 : a.compareTo(b)));

    return ListView.builder(
      padding: const EdgeInsets.all(kSpacingM),
      itemCount: sortedNodes.length,
      itemBuilder: (context, index) {
        final nodeId = sortedNodes[index];
        final nodeEntity = _world.getEntity(nodeId);
        final dialogNode = nodeEntity.get<DialogNode>();
        final nodeName = nodeEntity.get<Name>()?.name ?? 'Node #$nodeId';
        final isRoot = nodeId == rootNodeId;
        final isSelected = nodeId == _selectedNodeId;

        return Card(
          color: isSelected ? colorScheme.primaryContainer : null,
          child: InkWell(
            onTap: () => setState(() => _selectedNodeId = nodeId),
            child: Padding(
              padding: const EdgeInsets.all(kSpacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isRoot) ...[
                        Icon(
                          Icons.star,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: kSpacingXS),
                      ],
                      Expanded(
                        child: Text(
                          nodeName,
                          style: TextStyle(
                            fontWeight: isRoot ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      Text(
                        '#$nodeId',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  if (dialogNode != null) ...[
                    const SizedBox(height: kSpacingXS),
                    Text(
                      dialogNode.text.length > 50
                          ? '${dialogNode.text.substring(0, 50)}...'
                          : dialogNode.text,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: kSpacingXS),
                    Text(
                      '${dialogNode.choices.length} choice(s)',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNodeEditor(ColorScheme colorScheme, int nodeId) {
    final nodeEntity = _world.getEntity(nodeId);
    final dialogNode = nodeEntity.get<DialogNode>();
    final dialogRef = widget.entity.get<DialogRef>();
    final isRoot = dialogRef?.rootNodeId == nodeId;

    if (dialogNode == null) {
      return Center(
        child: Text(
          'Node #$nodeId has no DialogNode component',
          style: TextStyle(color: colorScheme.error),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(kSpacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Node #$nodeId',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (isRoot) ...[
                const SizedBox(width: kSpacingM),
                Chip(
                  label: const Text('Root'),
                  backgroundColor: colorScheme.primaryContainer,
                ),
              ],
              const Spacer(),
              if (!isRoot)
                TextButton.icon(
                  onPressed: () => _setAsRootNode(nodeId),
                  icon: const Icon(Icons.star_outline),
                  label: const Text('Set as Root'),
                ),
              if (!isRoot)
                TextButton.icon(
                  onPressed: () => _deleteNode(nodeId),
                  icon: Icon(Icons.delete, color: colorScheme.error),
                  label: Text('Delete', style: TextStyle(color: colorScheme.error)),
                ),
            ],
          ),
          const SizedBox(height: kSpacingL),

          // Name field
          TextFormField(
            key: ValueKey('name_$nodeId'),
            initialValue: nodeEntity.get<Name>()?.name ?? '',
            decoration: const InputDecoration(
              labelText: 'Node Name (for editor)',
              border: OutlineInputBorder(),
            ),
            onFieldSubmitted: (value) {
              if (value.isNotEmpty) {
                nodeEntity.upsert(Name(name: value));
              } else {
                nodeEntity.remove<Name>();
              }
            },
          ),
          const SizedBox(height: kSpacingL),

          // Dialog text field
          TextFormField(
            key: ValueKey('text_$nodeId'),
            initialValue: dialogNode.text,
            decoration: const InputDecoration(
              labelText: 'Dialog Text',
              border: OutlineInputBorder(),
              hintText: 'What the NPC says...',
            ),
            maxLines: 4,
            onFieldSubmitted: (value) {
              nodeEntity.upsert(DialogNode(
                text: value,
                choices: dialogNode.choices,
              ));
            },
          ),
          const SizedBox(height: kSpacingL),

          // Choices section
          Text(
            'Choices',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: kSpacingM),

          ...dialogNode.choices.asMap().entries.map((entry) {
            final index = entry.key;
            final choice = entry.value;
            return _buildChoiceEditor(nodeEntity, dialogNode, index, choice, colorScheme);
          }),

          // Add choice button
          TextButton.icon(
            onPressed: () {
              final newChoices = [...dialogNode.choices, DialogChoice(text: 'New choice')];
              nodeEntity.upsert(DialogNode(
                text: dialogNode.text,
                choices: newChoices,
              ));
              setState(() {});
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Choice'),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceEditor(
    Entity nodeEntity,
    DialogNode dialogNode,
    int index,
    DialogChoice choice,
    ColorScheme colorScheme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: kSpacingM),
      child: Padding(
        padding: const EdgeInsets.all(kSpacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Choice ${index + 1}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18),
                  onPressed: dialogNode.choices.length > 1
                      ? () {
                          final newChoices = [...dialogNode.choices]..removeAt(index);
                          nodeEntity.upsert(DialogNode(
                            text: dialogNode.text,
                            choices: newChoices,
                          ));
                          setState(() {});
                        }
                      : null,
                  tooltip: 'Delete choice',
                ),
              ],
            ),
            const SizedBox(height: kSpacingS),

            // Choice text
            TextFormField(
              key: ValueKey('choice_${nodeEntity.id}_$index'),
              initialValue: choice.text,
              decoration: const InputDecoration(
                labelText: 'Choice Text',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onFieldSubmitted: (value) {
                final newChoices = [...dialogNode.choices];
                newChoices[index] = DialogChoice(
                  text: value,
                  targetNodeId: choice.targetNodeId,
                );
                nodeEntity.upsert(DialogNode(
                  text: dialogNode.text,
                  choices: newChoices,
                ));
              },
            ),
            const SizedBox(height: kSpacingS),

            // Target node
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey('target_${nodeEntity.id}_$index'),
                    initialValue: choice.targetNodeId?.toString() ?? '',
                    decoration: InputDecoration(
                      labelText: 'Target Node ID',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      helperText: choice.targetNodeId == null ? 'Empty = end dialog' : null,
                    ),
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (value) {
                      final newChoices = [...dialogNode.choices];
                      newChoices[index] = DialogChoice(
                        text: choice.text,
                        targetNodeId: value.isEmpty ? null : int.tryParse(value),
                      );
                      nodeEntity.upsert(DialogNode(
                        text: dialogNode.text,
                        choices: newChoices,
                      ));
                      setState(() {
                        _discoverGraph();
                      });
                    },
                  ),
                ),
                const SizedBox(width: kSpacingS),
                if (choice.targetNodeId != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedNodeId = choice.targetNodeId;
                      });
                    },
                    child: const Text('Go to'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
