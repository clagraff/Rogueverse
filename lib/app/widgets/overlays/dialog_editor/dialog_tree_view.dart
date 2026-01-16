import 'package:flutter/material.dart';

import 'package:rogueverse/ecs/dialog/dialog.dart';

/// Tree view showing the structure of a dialog tree.
///
/// Each node displays its type and key information. Nodes can be
/// expanded to show children. Clicking a node selects it for editing.
class DialogTreeView extends StatelessWidget {
  final DialogNode? root;
  final List<int> selectedPath;
  final void Function(List<int> path) onSelect;
  final void Function(List<int> path, DialogNode? newNode) onUpdate;
  final VoidCallback onAddRootNode;

  const DialogTreeView({
    super.key,
    required this.root,
    required this.selectedPath,
    required this.onSelect,
    required this.onUpdate,
    required this.onAddRootNode,
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
          child: Text(
            'Dialog Tree',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Tree content
        Expanded(
          child: root == null
              ? _buildEmptyState(context)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: _DialogNodeItem(
                    node: root!,
                    path: const [],
                    selectedPath: selectedPath,
                    onSelect: onSelect,
                    onUpdate: onUpdate,
                    depth: 0,
                  ),
                ),
        ),

        // Add root node button (only when empty)
        if (root == null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton.icon(
              onPressed: onAddRootNode,
              icon: const Icon(Icons.add),
              label: const Text('Add Root Node'),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_tree_outlined,
            size: 48,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 8),
          Text(
            'No dialog tree',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single node item in the tree view.
class _DialogNodeItem extends StatefulWidget {
  final DialogNode node;
  final List<int> path;
  final List<int> selectedPath;
  final void Function(List<int> path) onSelect;
  final void Function(List<int> path, DialogNode? newNode) onUpdate;
  final int depth;

  const _DialogNodeItem({
    required this.node,
    required this.path,
    required this.selectedPath,
    required this.onSelect,
    required this.onUpdate,
    required this.depth,
  });

  @override
  State<_DialogNodeItem> createState() => _DialogNodeItemState();
}

class _DialogNodeItemState extends State<_DialogNodeItem> {
  bool _expanded = true;

  bool get _isSelected => _pathsEqual(widget.path, widget.selectedPath);

  bool _pathsEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  List<_ChildInfo> _getChildren() {
    final children = <_ChildInfo>[];
    final node = widget.node;

    if (node is SpeakNode) {
      for (int i = 0; i < node.choices.length; i++) {
        children.add(_ChildInfo(
          index: i,
          label: 'Choice: "${_truncate(node.choices[i].text, 20)}"',
          child: node.choices[i].child,
        ));
      }
    } else if (node is TextNode && node.next != null) {
      children.add(_ChildInfo(
        index: 0,
        label: 'Next',
        child: node.next!,
      ));
    } else if (node is EffectNode) {
      children.add(_ChildInfo(
        index: 0,
        label: 'Next',
        child: node.next,
      ));
    } else if (node is ConditionalNode) {
      children.add(_ChildInfo(
        index: 0,
        label: 'Pass',
        child: node.onPass,
      ));
      children.add(_ChildInfo(
        index: 1,
        label: 'Fail',
        child: node.onFail,
      ));
    }

    return children;
  }

  String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  String _getNodeLabel() {
    final node = widget.node;

    if (node is SpeakNode) {
      return 'SpeakNode: "${_truncate(node.speakerName, 15)}"';
    } else if (node is TextNode) {
      return 'TextNode: "${_truncate(node.speakerName, 15)}"';
    } else if (node is EndNode) {
      return 'EndNode';
    } else if (node is EffectNode) {
      return 'EffectNode (${node.effects.length} effects)';
    } else if (node is ConditionalNode) {
      return 'ConditionalNode';
    }

    return node.runtimeType.toString();
  }

  IconData _getNodeIcon() {
    final node = widget.node;

    if (node is SpeakNode) return Icons.chat_bubble;
    if (node is TextNode) return Icons.text_fields;
    if (node is EndNode) return Icons.stop_circle;
    if (node is EffectNode) return Icons.flash_on;
    if (node is ConditionalNode) return Icons.call_split;

    return Icons.circle;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final children = _getChildren();
    final hasChildren = children.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Node header
        InkWell(
          onTap: () => widget.onSelect(widget.path),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: _isSelected ? colorScheme.primaryContainer : null,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Expand/collapse toggle
                if (hasChildren)
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Icon(
                      _expanded ? Icons.expand_more : Icons.chevron_right,
                      size: 20,
                      color: _isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                    ),
                  )
                else
                  const SizedBox(width: 20),

                const SizedBox(width: 4),

                // Node icon
                Icon(
                  _getNodeIcon(),
                  size: 16,
                  color: _isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.primary,
                ),

                const SizedBox(width: 8),

                // Node label
                Text(
                  _getNodeLabel(),
                  style: TextStyle(
                    color: _isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface,
                    fontWeight: _isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Children
        if (_expanded && hasChildren)
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children.map((childInfo) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Child label
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 4),
                      child: Text(
                        childInfo.label,
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                      ),
                    ),

                    // Child node
                    _DialogNodeItem(
                      node: childInfo.child,
                      path: [...widget.path, childInfo.index],
                      selectedPath: widget.selectedPath,
                      onSelect: widget.onSelect,
                      onUpdate: widget.onUpdate,
                      depth: widget.depth + 1,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

/// Information about a child node in the tree.
class _ChildInfo {
  final int index;
  final String label;
  final DialogNode child;

  const _ChildInfo({
    required this.index,
    required this.label,
    required this.child,
  });
}
