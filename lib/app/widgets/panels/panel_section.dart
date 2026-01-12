import 'package:flutter/material.dart';

/// A collapsible section within a dock panel with a consistent header and content area.
///
/// Provides a titled container for panel content with optional action buttons
/// in the header. Can be collapsed to save space.
class PanelSection extends StatefulWidget {
  /// The title displayed in the section header.
  final String title;

  /// The main content of the section.
  final Widget child;

  /// Optional action buttons displayed in the header row.
  final List<Widget>? actions;

  /// Whether this section can be collapsed. Defaults to true.
  final bool isCollapsible;

  /// Whether the section starts expanded. Defaults to true.
  final bool initiallyExpanded;

  const PanelSection({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.isCollapsible = true,
    this.initiallyExpanded = true,
  });

  @override
  State<PanelSection> createState() => _PanelSectionState();
}

class _PanelSectionState extends State<PanelSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _toggleExpanded() {
    if (widget.isCollapsible) {
      setState(() {
        _isExpanded = !_isExpanded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: _isExpanded ? MainAxisSize.max : MainAxisSize.min,
      children: [
        // Header (clickable to toggle)
        GestureDetector(
          onTap: widget.isCollapsible ? _toggleExpanded : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Collapse/expand indicator
                if (widget.isCollapsible) ...[
                  Icon(
                    _isExpanded ? Icons.expand_more : Icons.chevron_right,
                    size: 16,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  widget.title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (widget.actions != null) ...widget.actions!,
              ],
            ),
          ),
        ),
        // Content (only when expanded)
        if (_isExpanded) Expanded(child: widget.child),
      ],
    );
  }
}
