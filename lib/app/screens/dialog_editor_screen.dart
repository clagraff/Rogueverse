import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rogueverse/app/screens/game/template_variables_screen.dart';
import 'package:rogueverse/app/ui_constants.dart';
import 'package:rogueverse/app/widgets/dialogs/node_picker_dialog.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/world.dart';

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

  /// Stack of previously visited node IDs for back navigation.
  final List<int> _navigationHistory = [];

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

  /// Returns a label for a node, preferring truncated dialog text.
  String _getNodeLabel(Entity nodeEntity, DialogNode dialogNode) {
    if (dialogNode.text.isNotEmpty) {
      final text = dialogNode.text;
      return text.length > 30 ? '${text.substring(0, 30)}...' : text;
    }
    return 'Node #${nodeEntity.id}';
  }

  void _handleClose() {
    Navigator.of(context).pop();
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
        actions: const [
          SizedBox(width: 16),
        ],
      ),
      body: Shortcuts(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
        },
        child: Actions(
          actions: {
            DismissIntent: CallbackAction<DismissIntent>(
              onInvoke: (_) {
                _handleClose();
                return null;
              },
            ),
          },
          child: Focus(
            autofocus: true,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(kSpacingM),
      child: _buildTreeNode(
        colorScheme: colorScheme,
        nodeId: rootNodeId,
        rootNodeId: rootNodeId,
        visitedNodes: {},
        depth: 0,
      ),
    );
  }

  /// Builds a tree node and its children recursively.
  Widget _buildTreeNode({
    required ColorScheme colorScheme,
    required int nodeId,
    required int rootNodeId,
    required Set<int> visitedNodes,
    required int depth,
  }) {
    final nodeEntity = _world.getEntity(nodeId);
    final dialogNode = nodeEntity.get<DialogNode>();
    final isRoot = nodeId == rootNodeId;
    final isSelected = nodeId == _selectedNodeId;

    if (dialogNode == null) {
      return const SizedBox.shrink();
    }

    // Mark this node as visited to detect loops
    final newVisited = {...visitedNodes, nodeId};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Node header
        InkWell(
          onTap: () => setState(() {
            _navigationHistory.clear();
            _selectedNodeId = nodeId;
          }),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: kSpacingS,
              vertical: kSpacingXS,
            ),
            decoration: BoxDecoration(
              color: isSelected ? colorScheme.primaryContainer : null,
              borderRadius: BorderRadius.circular(4),
              border: isSelected
                  ? Border.all(color: colorScheme.primary, width: 2)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isRoot ? Icons.star : Icons.chat_bubble_outline,
                  size: 14,
                  color: isRoot ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: kSpacingXS),
                Flexible(
                  child: Text(
                    _getNodeLabel(nodeEntity, dialogNode),
                    style: TextStyle(
                      fontWeight: isRoot ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Choices as children
        Padding(
          padding: const EdgeInsets.only(left: kSpacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: dialogNode.choices.asMap().entries.map((entry) {
              final choice = entry.value;
              final targetId = choice.targetNodeId;
              final choiceText = choice.text.length > 25
                  ? '${choice.text.substring(0, 25)}...'
                  : choice.text;

              if (targetId == null) {
                // End dialog choice
                return _buildChoiceRow(
                  colorScheme: colorScheme,
                  icon: Icons.stop_circle_outlined,
                  iconColor: colorScheme.error.withValues(alpha: 0.7),
                  text: '"$choiceText" (end)',
                  onTap: null,
                );
              }

              // Check if this is a loop reference
              if (visitedNodes.contains(targetId)) {
                final targetEntity = _world.getEntity(targetId);
                final targetNode = targetEntity.get<DialogNode>();
                final targetLabel = targetNode != null
                    ? _getNodeLabel(targetEntity, targetNode)
                    : 'Node #$targetId';
                return _buildChoiceRow(
                  colorScheme: colorScheme,
                  icon: Icons.redo,
                  iconColor: colorScheme.tertiary,
                  text: '"$choiceText" \u21a9 $targetLabel',
                  onTap: () => setState(() {
                    _navigationHistory.clear();
                    _selectedNodeId = targetId;
                  }),
                );
              }

              // Regular child node - recurse
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChoiceRow(
                    colorScheme: colorScheme,
                    icon: Icons.subdirectory_arrow_right,
                    iconColor: colorScheme.onSurface.withValues(alpha: 0.5),
                    text: '"$choiceText"',
                    onTap: () => setState(() {
                      _navigationHistory.clear();
                      _selectedNodeId = targetId;
                    }),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: kSpacingM),
                    child: _buildTreeNode(
                      colorScheme: colorScheme,
                      nodeId: targetId,
                      rootNodeId: rootNodeId,
                      visitedNodes: newVisited,
                      depth: depth + 1,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Builds a single choice row in the tree.
  Widget _buildChoiceRow({
    required ColorScheme colorScheme,
    required IconData icon,
    required Color iconColor,
    required String text,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: kSpacingXS,
          vertical: 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: iconColor),
            const SizedBox(width: kSpacingXS),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
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

          // Dialog text field
          TextFormField(
            key: ValueKey('text_$nodeId'),
            initialValue: dialogNode.text,
            decoration: InputDecoration(
              labelText: 'Dialog Text',
              border: const OutlineInputBorder(),
              hintText: 'What the NPC says...',
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.data_object,
                  size: 20,
                  color: colorScheme.primary,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TemplateVariablesScreen(),
                    ),
                  );
                },
                tooltip: 'Template Variables',
              ),
            ),
            maxLines: 4,
            onChanged: (value) {
              nodeEntity.upsert(DialogNode(
                text: value,
                choices: dialogNode.choices,
              ));
              setState(() {}); // Refresh tree labels
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

  /// Creates a new dialog node and links it to the given choice.
  void _createLinkedNode(Entity nodeEntity, DialogNode dialogNode, int choiceIndex) {
    // Create a new dialog node entity
    final newEntity = _world.add([
      DialogNode(
        text: 'New dialog text',
        choices: [DialogChoice(text: 'Continue')],
      ),
      Name(name: 'Dialog Node'),
    ]);

    // Update the choice to point to the new node
    final newChoices = [...dialogNode.choices];
    newChoices[choiceIndex] = DialogChoice(
      text: newChoices[choiceIndex].text,
      targetNodeId: newEntity.id,
    );
    nodeEntity.upsert(DialogNode(
      text: dialogNode.text,
      choices: newChoices,
    ));

    setState(() {
      _discoveredNodes.add(newEntity.id);
      if (_selectedNodeId != null) {
        _navigationHistory.add(_selectedNodeId!);
      }
      _selectedNodeId = newEntity.id;
    });
  }

  /// Updates the target node ID for a choice.
  void _updateChoiceTarget(
    Entity nodeEntity,
    DialogNode dialogNode,
    int choiceIndex,
    int? newTargetId,
  ) {
    final newChoices = [...dialogNode.choices];
    newChoices[choiceIndex] = DialogChoice(
      text: newChoices[choiceIndex].text,
      targetNodeId: newTargetId,
    );
    nodeEntity.upsert(DialogNode(
      text: dialogNode.text,
      choices: newChoices,
    ));
    setState(() {
      _discoverGraph();
    });
  }

  /// Builds a read-only display for the current target.
  Widget _buildTargetDisplay(DialogChoice choice, ColorScheme colorScheme) {
    final targetId = choice.targetNodeId;
    String label;
    IconData icon;
    Color iconColor;

    if (targetId == null) {
      label = '(End dialog)';
      icon = Icons.stop_circle_outlined;
      iconColor = colorScheme.error.withValues(alpha: 0.7);
    } else {
      final targetEntity = _world.getEntity(targetId);
      final targetNode = targetEntity.get<DialogNode>();
      if (targetNode != null) {
        label = _getNodeLabel(targetEntity, targetNode);
      } else {
        label = 'Node #$targetId';
      }
      icon = Icons.arrow_forward;
      iconColor = colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kSpacingM,
        vertical: kSpacingS,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(kRadiusS),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: kSpacingS),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontStyle: targetId == null ? FontStyle.italic : FontStyle.normal,
                color: targetId == null
                    ? colorScheme.onSurface.withValues(alpha: 0.6)
                    : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds action buttons for the target selector.
  List<Widget> _buildTargetActions(
    Entity nodeEntity,
    DialogNode dialogNode,
    int index,
    DialogChoice choice,
    ColorScheme colorScheme,
  ) {
    return [
      // Link existing node (opens modal)
      IconButton(
        icon: const Icon(Icons.link, size: 18),
        onPressed: () async {
          final selectedId = await NodePickerDialog.show(
            context: context,
            world: _world,
            currentTreeNodes: _discoveredNodes,
            excludeNodeId: nodeEntity.id,
            currentTargetId: choice.targetNodeId,
          );
          if (selectedId != null) {
            _updateChoiceTarget(nodeEntity, dialogNode, index, selectedId);
          }
        },
        tooltip: 'Link to existing node',
        visualDensity: VisualDensity.compact,
      ),
      // Create new linked node
      IconButton(
        icon: Icon(Icons.add_circle_outline, size: 18, color: colorScheme.primary),
        onPressed: () => _createLinkedNode(nodeEntity, dialogNode, index),
        tooltip: 'Create new linked node',
        visualDensity: VisualDensity.compact,
      ),
      // End dialog (clear target)
      if (choice.targetNodeId != null)
        IconButton(
          icon: Icon(Icons.stop_circle_outlined, size: 18, color: colorScheme.error.withValues(alpha: 0.7)),
          onPressed: () => _updateChoiceTarget(nodeEntity, dialogNode, index, null),
          tooltip: 'End dialog (clear target)',
          visualDensity: VisualDensity.compact,
        ),
      // Navigate to target node
      if (choice.targetNodeId != null)
        IconButton(
          icon: const Icon(Icons.open_in_new, size: 18),
          onPressed: () {
            setState(() {
              if (_selectedNodeId != null) {
                _navigationHistory.add(_selectedNodeId!);
              }
              _selectedNodeId = choice.targetNodeId;
            });
          },
          tooltip: 'Go to target node',
          visualDensity: VisualDensity.compact,
        ),
    ];
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
            // Header with title and delete button
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

            // Horizontal row with Choice Text and Target Node
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Choice text (flex: 2)
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    key: ValueKey('choice_${nodeEntity.id}_$index'),
                    initialValue: choice.text,
                    decoration: const InputDecoration(
                      labelText: 'Choice Text',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) {
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
                ),
                const SizedBox(width: kSpacingM),

                // Target node (flex: 1) with display + action buttons
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      // Target display chip
                      Expanded(
                        child: _buildTargetDisplay(choice, colorScheme),
                      ),
                      // Action buttons
                      ..._buildTargetActions(
                        nodeEntity,
                        dialogNode,
                        index,
                        choice,
                        colorScheme,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
