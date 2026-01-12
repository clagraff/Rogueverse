import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/world.dart';

/// Overlay panel for selecting which entity's vision to observe.
///
/// Shows a list of entities with VisionRadius components and allows
/// selecting one to use as the observer for vision-based rendering.
/// Only shows entities within the currently viewed parent.
class VisionObserverPanel extends StatefulWidget {
  /// The overlay name used to register and toggle this panel.
  static const String overlayName = 'visionObserverPanel';

  /// The ECS world containing all entities
  final World world;

  /// Notifier for the currently observed entity ID
  final ValueNotifier<int?> observerEntityIdNotifier;

  /// Notifier for the currently viewed parent ID (for filtering entities)
  final ValueNotifier<int?> viewedParentIdNotifier;

  /// Callback to close the panel
  final VoidCallback onClose;

  const VisionObserverPanel({
    super.key,
    required this.world,
    required this.observerEntityIdNotifier,
    required this.viewedParentIdNotifier,
    required this.onClose,
  });

  @override
  State<VisionObserverPanel> createState() => _VisionObserverPanelState();
}

class _VisionObserverPanelState extends State<VisionObserverPanel> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _requestFocusAfterBuild();
  }

  void _requestFocusAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _selectObserver(int? entityId) {
    widget.observerEntityIdNotifier.value = entityId;
  }

  /// Determines if an entity should be shown based on the viewed parent filter.
  bool _shouldShowEntity(Entity entity, int? viewedParentId) {
    if (viewedParentId == null) {
      return true; // Show all entities if no parent filter
    }

    final hasParent = entity.get<HasParent>();
    if (hasParent == null) {
      return false; // Entity has no parent, don't show when filtering
    }

    return hasParent.parentEntityId == viewedParentId;
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: false,
      onKeyEvent: (event) {
        if (event is! KeyDownEvent) return;

        // Handle ESC key to close panel
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          widget.onClose();
        }
      },
      child: Material(
        elevation: 4,
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ValueListenableBuilder<int?>(
                valueListenable: widget.observerEntityIdNotifier,
                builder: (context, observerId, _) {
                  // Also rebuild when viewedParentId changes
                  return ValueListenableBuilder<int?>(
                    valueListenable: widget.viewedParentIdNotifier,
                    builder: (context, viewedParentId, _) {
                      return _buildEntityList(context, observerId);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the panel header with title and close button
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Vision Observer',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: widget.onClose,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// Builds the list of entities with vision
  Widget _buildEntityList(BuildContext context, int? observerId) {
    final viewedParentId = widget.viewedParentIdNotifier.value;

    // Find all entities with VisionRadius in the current viewed parent
    final entitiesWithVision = widget.world
        .entities()
        .where((e) => e.has<VisionRadius>())
        .where((e) => _shouldShowEntity(e, viewedParentId))
        .toList();

    if (entitiesWithVision.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.visibility_off,
                size: 40,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3),
              ),
              const SizedBox(height: 12),
              Text(
                'No entities with vision',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ).copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Add VisionRadius components to entities',
                style: const TextStyle(fontSize: 11).copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        // "No Observer" option
        _buildEntityCard(
          context: context,
          entityId: null,
          entityName: 'No Observer',
          subtitle: 'Show all entities',
          isSelected: observerId == null,
          icon: Icons.visibility_off,
        ),
        const Divider(height: 16),
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            'Entities with Vision',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // List of entities with vision
        ...entitiesWithVision.map((entity) {
          final nameComponent = entity.get<Name>();
          final visionRadius = entity.get<VisionRadius>();
          final entityName = nameComponent?.name ?? 'Entity #${entity.id}';
          final radius = visionRadius?.radius ?? 0;
          final fov = visionRadius?.fieldOfViewDegrees ?? 360;

          String subtitle = 'Radius: $radius';
          if (fov < 360) {
            subtitle += ', FOV: $fov°';
          }

          return _buildEntityCard(
            context: context,
            entityId: entity.id,
            entityName: entityName,
            subtitle: subtitle,
            isSelected: observerId == entity.id,
            icon: Icons.visibility,
          );
        }),
      ],
    );
  }

  /// Builds a card for an entity
  Widget _buildEntityCard({
    required BuildContext context,
    required int? entityId,
    required String entityName,
    required String subtitle,
    required bool isSelected,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected
          ? Theme.of(context)
              .colorScheme
              .primaryContainer
              .withValues(alpha: 0.3)
          : null,
      child: InkWell(
        onTap: () => _selectObserver(entityId),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Icon
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
              ),
              const SizedBox(width: 12),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entityName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // Selection indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
