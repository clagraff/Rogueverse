import 'package:flutter/material.dart';

/// Which side of the screen the dock panel is anchored to.
enum DockSide { left, right }

/// How child widgets are arranged within the dock panel.
enum DockLayout {
  /// Children stacked vertically with dividers between them.
  verticalSplit,
  // Future: tabs, stacked, etc.
}

/// A dockable panel that anchors to the left or right side of the screen.
///
/// Contains one or more child widgets arranged according to [layout].
/// Each child should be a [PanelSection] for consistent styling.
class DockPanel extends StatelessWidget {
  /// Which side to dock to.
  final DockSide side;

  /// How to arrange children.
  final DockLayout layout;

  /// The panel widgets to display.
  final List<Widget> children;

  /// Width of the dock panel.
  final double width;

  const DockPanel({
    super.key,
    required this.side,
    this.layout = DockLayout.verticalSplit,
    required this.children,
    this.width = 280,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: side == DockSide.left
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: SizedBox(
        width: width,
        child: Material(
          elevation: 4,
          color: colorScheme.surface,
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (layout) {
      case DockLayout.verticalSplit:
        return _buildVerticalSplit(context);
    }
  }

  Widget _buildVerticalSplit(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final List<Widget> columnChildren = [];

    for (var i = 0; i < children.length; i++) {
      // Use Flexible so collapsed panels can shrink to their minimum size
      columnChildren.add(Flexible(child: children[i]));

      // Add divider between children (not after last)
      if (i < children.length - 1) {
        columnChildren.add(Divider(
          height: 1,
          thickness: 1,
          color: colorScheme.outlineVariant,
        ));
      }
    }

    return Column(children: columnChildren);
  }
}
