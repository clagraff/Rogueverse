import 'package:flutter/material.dart';

/// A reusable layout widget that provides optional left, right, and bottom panels
/// around a center content area.
///
/// Used for both editing mode (with entity/template/properties panels) and
/// potentially gameplay mode (with stats/inventory panels).
class PanelLayout extends StatelessWidget {
  /// The main center content (typically the game widget).
  final Widget child;

  /// Optional left panel content. If null, no left panel is shown.
  final Widget? leftPanel;

  /// Optional right panel content. If null, no right panel is shown.
  final Widget? rightPanel;

  /// Optional bottom bar content. If null, no bottom bar is shown.
  final Widget? bottomBar;

  /// Width for side panels. Defaults to 280.
  final double panelWidth;

  /// Height for bottom bar. Defaults to 40.
  final double bottomBarHeight;

  /// Minimum width required for the center content area.
  static const double _minCenterWidth = 200.0;

  const PanelLayout({
    super.key,
    required this.child,
    this.leftPanel,
    this.rightPanel,
    this.bottomBar,
    this.panelWidth = 280,
    this.bottomBarHeight = 40,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final requiredWidth = _minCenterWidth +
            (leftPanel != null ? panelWidth : 0) +
            (rightPanel != null ? panelWidth : 0);

        if (constraints.maxWidth < requiredWidth) {
          return _buildMinSizeWarning(context, requiredWidth);
        }

        return _buildLayout(context);
      },
    );
  }

  Widget _buildMinSizeWarning(BuildContext context, double requiredWidth) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 48,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Window too small',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Minimum width: ${requiredWidth.toInt()}px',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayout(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left panel
        if (leftPanel != null)
          SizedBox(
            width: panelWidth,
            child: Material(
              elevation: 4,
              color: colorScheme.surface,
              child: leftPanel,
            ),
          ),

        // Center content area (clipped to prevent game rendering over panels)
        Expanded(
          child: Column(
            children: [
              // Main content (clipped to bounds)
              Expanded(
                child: ClipRect(child: child),
              ),

              // Bottom bar
              if (bottomBar != null)
                SizedBox(
                  height: bottomBarHeight,
                  child: bottomBar,
                ),
            ],
          ),
        ),

        // Right panel
        if (rightPanel != null)
          SizedBox(
            width: panelWidth,
            child: Material(
              elevation: 4,
              color: colorScheme.surface,
              child: rightPanel,
            ),
          ),
      ],
    );
  }
}
