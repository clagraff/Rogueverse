import 'package:flutter/material.dart' hide Dialog;
import 'package:flutter/services.dart';

import 'package:rogueverse/ecs/components.dart' show Dialog, Name;
import 'package:rogueverse/ecs/dialog/dialog.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/app/screens/game/template_variables_screen.dart';
import 'package:rogueverse/app/widgets/overlays/dialog_editor/dialog_tree_view.dart';
import 'package:rogueverse/app/widgets/overlays/dialog_editor/dialog_node_editor.dart';

/// Full-screen editor for dialog trees attached to NPC entities.
///
/// Uses a tree + side panel layout:
/// - Left panel: Tree view showing dialog structure
/// - Right panel: Properties editor for selected node
class DialogEditorScreen extends StatefulWidget {
  final Entity entity;

  const DialogEditorScreen({
    super.key,
    required this.entity,
  });

  @override
  State<DialogEditorScreen> createState() => _DialogEditorScreenState();
}

class _DialogEditorScreenState extends State<DialogEditorScreen> {
  /// Working copy of the dialog tree (edited, not yet saved).
  DialogNode? _rootNode;

  /// Path to the currently selected node in the tree.
  /// Each int represents an index into children at that level.
  List<int> _selectedPath = [];

  /// Whether changes have been made since opening.
  bool _hasChanges = false;

  /// Node ID registry for validation and lookups.
  NodeIdRegistry _nodeRegistry = {};

  @override
  void initState() {
    super.initState();
    // Clone the dialog tree for editing
    final dialog = widget.entity.get<Dialog>();
    _rootNode = dialog?.root;
    _rebuildRegistry();
  }

  /// Rebuilds the node ID registry from the current root node.
  void _rebuildRegistry() {
    _nodeRegistry = {};
    if (_rootNode != null) {
      _collectNodeIds(_rootNode!, _nodeRegistry);
    }
  }

  /// Recursively collects all node IDs into the registry.
  void _collectNodeIds(DialogNode node, NodeIdRegistry registry) {
    registry[node.id] = node;

    if (node is SpeakNode) {
      for (final choice in node.choices) {
        _collectNodeIds(choice.child, registry);
      }
    } else if (node is TextNode) {
      if (node.next != null) {
        _collectNodeIds(node.next!, registry);
      }
    } else if (node is EffectNode) {
      _collectNodeIds(node.next, registry);
    } else if (node is ConditionalNode) {
      _collectNodeIds(node.onPass, registry);
      _collectNodeIds(node.onFail, registry);
    }
    // GotoNode and EndNode have no children
  }

  /// Gets the node at the current selection path.
  DialogNode? get _selectedNode {
    if (_rootNode == null) return null;
    if (_selectedPath.isEmpty) return _rootNode;

    DialogNode? current = _rootNode;
    for (final index in _selectedPath) {
      current = _getChildAt(current, index);
      if (current == null) return null;
    }
    return current;
  }

  /// Gets a child node at the given index.
  DialogNode? _getChildAt(DialogNode? node, int index) {
    if (node == null) return null;

    if (node is SpeakNode) {
      if (index < node.choices.length) {
        return node.choices[index].child;
      }
    } else if (node is TextNode) {
      if (index == 0) return node.next;
    } else if (node is EffectNode) {
      if (index == 0) return node.next;
    } else if (node is ConditionalNode) {
      if (index == 0) return node.onPass;
      if (index == 1) return node.onFail;
    }
    return null;
  }

  void _handleClose() {
    if (_hasChanges) {
      _showDiscardConfirmation();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _showDiscardConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes. Discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _saveAndClose() {
    if (_rootNode != null) {
      widget.entity.upsert(Dialog(_rootNode!));
    } else {
      widget.entity.remove<Dialog>();
    }
    Navigator.of(context).pop();
  }

  void _onSelectNode(List<int> path) {
    setState(() {
      _selectedPath = path;
    });
  }

  void _onUpdateNode(List<int> path, DialogNode? newNode) {
    setState(() {
      _hasChanges = true;

      // Get the old node's ID for detecting ID changes
      final oldNode = path.isEmpty ? _rootNode : _selectedNode;
      final oldId = oldNode?.id;
      final newId = newNode?.id;

      // Update the node in the tree
      if (path.isEmpty) {
        _rootNode = newNode;
      } else {
        _rootNode = _updateNodeAtPath(_rootNode, path, newNode);
      }

      // If the node ID changed, update all GotoNode references
      if (oldId != null && newId != null && oldId != newId && _rootNode != null) {
        _rootNode = _updateGotoTargets(_rootNode!, oldId, newId);
      }

      // Rebuild registry after any tree modification
      _rebuildRegistry();
    });
  }

  /// Recursively updates a node at the given path.
  DialogNode? _updateNodeAtPath(
    DialogNode? current,
    List<int> path,
    DialogNode? newNode,
  ) {
    if (current == null) return null;
    if (path.isEmpty) return newNode;

    final index = path.first;
    final remainingPath = path.sublist(1);

    if (current is SpeakNode) {
      final newChoices = List<Choice>.from(current.choices);
      if (index < newChoices.length) {
        final choice = newChoices[index];
        final updatedChild = remainingPath.isEmpty
            ? newNode
            : _updateNodeAtPath(choice.child, remainingPath, newNode);
        newChoices[index] = Choice(
          text: choice.text,
          condition: choice.condition,
          conditionLabel: choice.conditionLabel,
          showWhenUnavailable: choice.showWhenUnavailable,
          child: updatedChild ?? EndNode(id: generateNodeId()),
        );
      }
      return SpeakNode(
        id: current.id,
        speakerName: current.speakerName,
        text: current.text,
        choices: newChoices,
        effects: current.effects,
      );
    } else if (current is TextNode) {
      if (index == 0) {
        final updatedNext = remainingPath.isEmpty
            ? newNode
            : _updateNodeAtPath(current.next, remainingPath, newNode);
        return TextNode(
          id: current.id,
          speakerName: current.speakerName,
          text: current.text,
          next: updatedNext,
          effects: current.effects,
        );
      }
    } else if (current is EffectNode) {
      if (index == 0) {
        final updatedNext = remainingPath.isEmpty
            ? newNode
            : _updateNodeAtPath(current.next, remainingPath, newNode);
        return EffectNode(
          id: current.id,
          effects: current.effects,
          next: updatedNext ?? EndNode(id: generateNodeId()),
        );
      }
    } else if (current is ConditionalNode) {
      if (index == 0) {
        final updatedPass = remainingPath.isEmpty
            ? newNode
            : _updateNodeAtPath(current.onPass, remainingPath, newNode);
        return ConditionalNode(
          id: current.id,
          condition: current.condition,
          onPass: updatedPass ?? EndNode(id: generateNodeId()),
          onFail: current.onFail,
        );
      } else if (index == 1) {
        final updatedFail = remainingPath.isEmpty
            ? newNode
            : _updateNodeAtPath(current.onFail, remainingPath, newNode);
        return ConditionalNode(
          id: current.id,
          condition: current.condition,
          onPass: current.onPass,
          onFail: updatedFail ?? EndNode(id: generateNodeId()),
        );
      }
    }

    return current;
  }

  /// Recursively updates all GotoNode targetIds from oldId to newId.
  DialogNode _updateGotoTargets(DialogNode node, String oldId, String newId) {
    if (node is GotoNode) {
      if (node.targetId == oldId) {
        return GotoNode(id: node.id, targetId: newId);
      }
      return node;
    } else if (node is SpeakNode) {
      final newChoices = node.choices.map((choice) {
        return Choice(
          text: choice.text,
          condition: choice.condition,
          conditionLabel: choice.conditionLabel,
          showWhenUnavailable: choice.showWhenUnavailable,
          child: _updateGotoTargets(choice.child, oldId, newId),
        );
      }).toList();
      return SpeakNode(
        id: node.id,
        speakerName: node.speakerName,
        text: node.text,
        choices: newChoices,
        effects: node.effects,
      );
    } else if (node is TextNode) {
      return TextNode(
        id: node.id,
        speakerName: node.speakerName,
        text: node.text,
        next: node.next != null ? _updateGotoTargets(node.next!, oldId, newId) : null,
        effects: node.effects,
      );
    } else if (node is EffectNode) {
      return EffectNode(
        id: node.id,
        effects: node.effects,
        next: _updateGotoTargets(node.next, oldId, newId),
      );
    } else if (node is ConditionalNode) {
      return ConditionalNode(
        id: node.id,
        condition: node.condition,
        onPass: _updateGotoTargets(node.onPass, oldId, newId),
        onFail: _updateGotoTargets(node.onFail, oldId, newId),
      );
    }
    // EndNode has no children
    return node;
  }

  void _onAddRootNode() {
    setState(() {
      _hasChanges = true;
      _rootNode = SpeakNode(
        id: generateNodeId(),
        speakerName: 'Speaker',
        text: 'Hello!',
        choices: [
          Choice(
            text: 'Goodbye',
            child: EndNode(id: generateNodeId()),
          ),
        ],
      );
      _selectedPath = [];
      _rebuildRegistry();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final npcName = widget.entity.get<Name>()?.name ?? 'Unknown';

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
            if (_hasChanges) ...[
              const SizedBox(width: 8),
              Text(
                '(unsaved)',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: _handleClose,
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: _saveAndClose,
            child: const Text('Save & Close'),
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
            if (event.logicalKey == LogicalKeyboardKey.keyS &&
                HardwareKeyboard.instance.isControlPressed) {
              _saveAndClose();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: DialogTreeContext(
          registry: _nodeRegistry,
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left panel - Tree view
                SizedBox(
                  width: 350,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: colorScheme.outlineVariant),
                      ),
                    ),
                    child: DialogTreeView(
                      root: _rootNode,
                      selectedPath: _selectedPath,
                      onSelect: _onSelectNode,
                      onUpdate: _onUpdateNode,
                      onAddRootNode: _onAddRootNode,
                    ),
                  ),
                ),

                // Right panel - Node editor
                Expanded(
                  child: DialogNodeEditor(
                    node: _selectedNode,
                    path: _selectedPath,
                    onUpdate: (newNode) => _onUpdateNode(_selectedPath, newNode),
                    onNavigateToChild: (childIndex) {
                      setState(() {
                        _selectedPath = [..._selectedPath, childIndex];
                      });
                    },
                    onNavigateUp: () {
                      if (_selectedPath.isNotEmpty) {
                        setState(() {
                          _selectedPath = _selectedPath.sublist(
                              0, _selectedPath.length - 1);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const TemplateVariablesScreen(),
            ),
          );
        },
        tooltip: 'Template Variables',
        child: const Icon(Icons.data_object),
      ),
    );
  }
}
