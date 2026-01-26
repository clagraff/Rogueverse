import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rogueverse/app/services/keybinding_service.dart';
import 'package:rogueverse/app/ui_constants.dart';
import 'package:rogueverse/app/widgets/keyboard/auto_focus_keyboard_listener.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/world.dart';

/// A dialog for selecting a dialog node from the world.
///
/// Supports filtering by search text (matches entity ID or dialog text)
/// and scope toggle between "Current tree" and "All nodes".
class NodePickerDialog extends StatefulWidget {
  final World world;

  /// Nodes in the current NPC's dialog tree.
  final Set<int> currentTreeNodes;

  /// Node ID to exclude from selection (can't select self).
  final int? excludeNodeId;

  /// Currently selected target ID for pre-selection.
  final int? currentTargetId;

  const NodePickerDialog({
    super.key,
    required this.world,
    required this.currentTreeNodes,
    this.excludeNodeId,
    this.currentTargetId,
  });

  /// Shows the dialog and returns the selected node ID, or null if cancelled.
  static Future<int?> show({
    required BuildContext context,
    required World world,
    required Set<int> currentTreeNodes,
    int? excludeNodeId,
    int? currentTargetId,
  }) async {
    return showDialog<int?>(
      context: context,
      builder: (context) => NodePickerDialog(
        world: world,
        currentTreeNodes: currentTreeNodes,
        excludeNodeId: excludeNodeId,
        currentTargetId: currentTargetId,
      ),
    );
  }

  @override
  State<NodePickerDialog> createState() => _NodePickerDialogState();
}

enum _NodeScope { currentTree, allNodes }

class _NodePickerDialogState extends State<NodePickerDialog> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  _NodeScope _scope = _NodeScope.currentTree;
  int _selectedIndex = 0;
  List<Entity> _filteredNodes = [];

  @override
  void initState() {
    super.initState();
    _updateFilteredNodes();
    // Pre-select current target if available
    if (widget.currentTargetId != null) {
      final index = _filteredNodes.indexWhere((e) => e.id == widget.currentTargetId);
      if (index >= 0) {
        _selectedIndex = index;
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<Entity> _getAllDialogNodes() {
    return widget.world.entities()
        .where((e) => e.has<DialogNode>())
        .toList();
  }

  void _updateFilteredNodes() {
    final searchText = _searchController.text.toLowerCase();
    var nodes = _getAllDialogNodes();

    // Filter by scope
    if (_scope == _NodeScope.currentTree) {
      nodes = nodes.where((e) => widget.currentTreeNodes.contains(e.id)).toList();
    }

    // Exclude self
    if (widget.excludeNodeId != null) {
      nodes = nodes.where((e) => e.id != widget.excludeNodeId).toList();
    }

    // Filter by search text (matches ID or dialog text)
    if (searchText.isNotEmpty) {
      nodes = nodes.where((e) {
        final idMatch = e.id.toString().contains(searchText);
        final dialogNode = e.get<DialogNode>();
        final textMatch = dialogNode?.text.toLowerCase().contains(searchText) ?? false;
        return idMatch || textMatch;
      }).toList();
    }

    // Sort by ID for consistency
    nodes.sort((a, b) => a.id.compareTo(b.id));

    _filteredNodes = nodes;

    // Clamp selected index
    if (_selectedIndex >= _filteredNodes.length) {
      _selectedIndex = _filteredNodes.isEmpty ? 0 : _filteredNodes.length - 1;
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;
    final keybindings = KeyBindingService.instance;

    // Navigate list
    if (key == LogicalKeyboardKey.arrowUp ||
        keybindings.matches('menu.up', {key})) {
      setState(() {
        _selectedIndex = (_selectedIndex - 1).clamp(0, _filteredNodes.length - 1);
      });
    } else if (key == LogicalKeyboardKey.arrowDown ||
        keybindings.matches('menu.down', {key})) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1).clamp(0, _filteredNodes.length - 1);
      });
    }
    // Select item
    else if (key == LogicalKeyboardKey.enter ||
        keybindings.matches('menu.select', {key})) {
      if (_filteredNodes.isNotEmpty) {
        Navigator.of(context).pop(_filteredNodes[_selectedIndex].id);
      }
    }
    // Cancel
    else if (key == LogicalKeyboardKey.escape ||
        keybindings.matches('menu.back', {key})) {
      Navigator.of(context).pop(null);
    }
    // Toggle scope with Tab
    else if (key == LogicalKeyboardKey.tab) {
      setState(() {
        _scope = _scope == _NodeScope.currentTree
            ? _NodeScope.allNodes
            : _NodeScope.currentTree;
        _updateFilteredNodes();
      });
    }
  }

  String _getNodeLabel(Entity entity, DialogNode dialogNode) {
    if (dialogNode.text.isNotEmpty) {
      final text = dialogNode.text;
      return text.length > 40 ? '${text.substring(0, 40)}...' : text;
    }
    return 'Node #${entity.id}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AutoFocusKeyboardListener(
      onKeyEvent: _handleKeyEvent,
      child: Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 500,
            maxHeight: 500,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(kSpacingL),
                child: Row(
                  children: [
                    Icon(Icons.link, color: colorScheme.primary),
                    const SizedBox(width: kSpacingM),
                    Text(
                      'Select Target Node',
                      style: textTheme.titleLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(null),
                      tooltip: 'Cancel (Esc)',
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Search field
              Padding(
                padding: const EdgeInsets.all(kSpacingM),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search by ID or text...',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    isDense: true,
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _updateFilteredNodes();
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _updateFilteredNodes();
                    });
                  },
                ),
              ),

              // Scope toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: kSpacingM),
                child: SegmentedButton<_NodeScope>(
                  segments: [
                    ButtonSegment(
                      value: _NodeScope.currentTree,
                      label: Text('Current tree (${widget.currentTreeNodes.length - 1})'),
                      icon: const Icon(Icons.account_tree, size: 18),
                    ),
                    ButtonSegment(
                      value: _NodeScope.allNodes,
                      label: Text('All nodes (${_getAllDialogNodes().length - 1})'),
                      icon: const Icon(Icons.apps, size: 18),
                    ),
                  ],
                  selected: {_scope},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _scope = selection.first;
                      _updateFilteredNodes();
                    });
                  },
                ),
              ),
              const SizedBox(height: kSpacingM),

              // Results list
              Expanded(
                child: _filteredNodes.isEmpty
                    ? Center(
                        child: Text(
                          'No matching nodes',
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: kSpacingM),
                        itemCount: _filteredNodes.length,
                        itemBuilder: (context, index) {
                          final entity = _filteredNodes[index];
                          final dialogNode = entity.get<DialogNode>()!;
                          final isSelected = index == _selectedIndex;
                          final isInCurrentTree = widget.currentTreeNodes.contains(entity.id);

                          return InkWell(
                            onTap: () => Navigator.of(context).pop(entity.id),
                            borderRadius: BorderRadius.circular(kRadiusS),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: kSpacingM,
                                vertical: kSpacingS,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.primaryContainer
                                    : null,
                                borderRadius: BorderRadius.circular(kRadiusS),
                                border: isSelected
                                    ? Border.all(color: colorScheme.primary, width: 2)
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  // Entity ID badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: kSpacingS,
                                      vertical: kSpacingXS,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(kRadiusS),
                                    ),
                                    child: Text(
                                      '#${entity.id}',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                                        fontFeatures: const [FontFeature.tabularFigures()],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: kSpacingM),
                                  // Dialog text
                                  Expanded(
                                    child: Text(
                                      _getNodeLabel(entity, dialogNode),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // External indicator
                                  if (!isInCurrentTree) ...[
                                    const SizedBox(width: kSpacingS),
                                    Icon(
                                      Icons.open_in_new,
                                      size: 14,
                                      color: colorScheme.tertiary,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: kSpacingM),

              // Footer hint
              Padding(
                padding: const EdgeInsets.all(kSpacingM),
                child: Text(
                  '↑↓ Navigate • Enter to select • Tab to toggle scope • Esc to cancel',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
