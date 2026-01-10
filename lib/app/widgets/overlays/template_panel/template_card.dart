import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rogueverse/ecs/entity_template.dart';

/// A card displaying a single entity template in the grid.
///
/// Shows the template's Renderable asset as an icon and its display name below.
/// Highlights when selected and provides a delete button on hover.
class TemplateCard extends StatefulWidget {
  /// The template to display.
  final EntityTemplate template;

  /// Whether this template is currently selected for placement.
  final bool isSelected;

  /// Callback when the card is tapped.
  final VoidCallback onTap;

  /// Callback when the delete button is pressed.
  final VoidCallback onDelete;

  /// Callback when the edit button is pressed.
  final VoidCallback onEdit;

  /// Callback when the duplicate button is pressed.
  final VoidCallback onDuplicate;

  const TemplateCard({
    super.key,
    required this.template,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
    required this.onDuplicate,
  });

  @override
  State<TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<TemplateCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: widget.isSelected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.2),
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              // Main content: icon and name
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon area
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: _buildIcon(context),
                    ),
                  ),
                  // Name label
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? colorScheme.primary.withValues(alpha: 0.1)
                          : colorScheme.surfaceContainerHigh,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(7),
                        bottomRight: Radius.circular(7),
                      ),
                    ),
                    child: Text(
                      widget.template.displayName,
                      style: const TextStyle(
                        fontSize: 10,
                      ).copyWith(
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: widget.isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              // Action buttons (show on hover)
              if (_isHovering)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Duplicate button
                      _ActionButton(
                        icon: Icons.copy_outlined,
                        color: colorScheme.secondary,
                        onTap: widget.onDuplicate,
                      ),
                      const SizedBox(width: 2),
                      // Edit button
                      _ActionButton(
                        icon: Icons.edit_outlined,
                        color: colorScheme.primary,
                        onTap: widget.onEdit,
                      ),
                      const SizedBox(width: 2),
                      // Delete button
                      _ActionButton(
                        icon: Icons.delete_outline,
                        color: colorScheme.error,
                        onTap: widget.onDelete,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the icon for the template.
  ///
  /// If the template has a Renderable component, displays that asset.
  /// Otherwise, shows a fallback icon. If the asset fails to load, falls back
  /// to a default asset or placeholder icon.
  Widget _buildIcon(BuildContext context) {
    final renderable = widget.template.renderable;

    if (renderable == null) {
      return Icon(
        Icons.help_outline,
        size: 24,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
      );
    }

    // Use Flutter SVG to display the asset with error handling
    return _SafeSvgPicture(
      assetPath: renderable.svgAssetPath,
      fallbackIcon: Icons.image_not_supported,
    );
  }
}

/// A small circular action button for template card actions.
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 11,
            color: color,
          ),
        ),
      ),
    );
  }
}

/// A widget that safely loads SVG assets with fallback handling.
///
/// If the primary asset fails to load, attempts to load a default.svg.
/// If that also fails, displays a fallback icon.
class _SafeSvgPicture extends StatelessWidget {
  final String assetPath;
  final IconData fallbackIcon;

  const _SafeSvgPicture({
    required this.assetPath,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _loadSvg(context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!;
        } else if (snapshot.hasError) {
          // Final fallback: show icon
          return Icon(
            fallbackIcon,
            size: 24,
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
          );
        } else {
          // Loading
          return Icon(
            Icons.image_outlined,
            size: 24,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          );
        }
      },
    );
  }

  Future<Widget> _loadSvg(BuildContext context) async {
    try {
      // Try to load the primary asset
      return SvgPicture.asset(
        "assets/$assetPath",
        width: 24,
        height: 24,
        fit: BoxFit.contain,
      );
    } catch (e) {
      // Log the error
      debugPrint('Failed to load SVG asset: $assetPath - $e');

      // Try to load default.svg as fallback
      try {
        return SvgPicture.asset(
          'images/default.svg',
          width: 24,
          height: 24,
          fit: BoxFit.contain,
        );
      } catch (e2) {
        debugPrint('Failed to load default.svg fallback - $e2');
        rethrow; // Will trigger the error state in FutureBuilder
      }
    }
  }
}
