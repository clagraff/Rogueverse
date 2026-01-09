import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rogueverse/ecs/ecs.barrel.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_section.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/sections/sections.dart';
import 'package:rogueverse/ecs/events.dart';

/// Inspector overlay that displays and allows editing of entity component properties.
///
/// This widget appears as a side panel showing all components attached to the currently
/// selected entity. Components can be expanded to edit their properties, deleted, or
/// added dynamically. The panel can be dismissed by pressing ESC.
class InspectorPanel extends StatefulWidget {
  /// Notifier that tracks which entity (if any) is currently selected for inspection.
  final ValueNotifier<Entity?> entityNotifier;

  const InspectorPanel({super.key, required this.entityNotifier});

  @override
  State<InspectorPanel> createState() => _InspectorPanelState();
}

class _InspectorPanelState extends State<InspectorPanel> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _registerAllComponents();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  /// Registers all component metadata with the registry.
  ///
  /// This should be called once during initialization to ensure all component
  /// types are available in the inspector. New components should be registered here.
  void _registerAllComponents() {
    // Only register if not already registered (prevents double registration)
    if (ComponentRegistry.getAll().isEmpty) {
      // Core gameplay components
      ComponentRegistry.register(NameMetadata());
      ComponentRegistry.register(LocalPositionMetadata());
      ComponentRegistry.register(DirectionMetadata());
      ComponentRegistry.register(HealthMetadata());
      ComponentRegistry.register(RenderableMetadata());

      // Hierarchy components
      ComponentRegistry.register(HasParentMetadata());

      // Inventory components
      ComponentRegistry.register(InventoryMetadata());
      ComponentRegistry.register(InventoryMaxCountMetadata());
      ComponentRegistry.register(PickupIntentMetadata());
      ComponentRegistry.register(PickedUpMetadata());
      ComponentRegistry.register(InventoryFullFailureMetadata());
      ComponentRegistry.register(LootTableMetadata());

      // Marker components (tags with no data)
      ComponentRegistry.register(AiControlledMetadata());
      ComponentRegistry.register(BlocksMovementMetadata());
      ComponentRegistry.register(PickupableMetadata());
      ComponentRegistry.register(DeadMetadata());

      // Vision components
      ComponentRegistry.register(VisionRadiusMetadata());
      ComponentRegistry.register(VisibleEntitiesMetadata());
      ComponentRegistry.register(VisionMemoryMetadata());
      ComponentRegistry.register(BlocksSightMetadata());

      // Combat components
      ComponentRegistry.register(AttackIntentMetadata());
      ComponentRegistry.register(DidAttackMetadata());
      ComponentRegistry.register(WasAttackedMetadata());

      // Portal components
      ComponentRegistry.register(PortalToPositionMetadata());
      ComponentRegistry.register(PortalToAnchorMetadata());
      ComponentRegistry.register(PortalAnchorMetadata());
      ComponentRegistry.register(UsePortalIntentMetadata());
      ComponentRegistry.register(DidPortalMetadata());
      ComponentRegistry.register(FailedToPortalMetadata());

      // Control components
      ComponentRegistry.register(ControllableMetadata());
      ComponentRegistry.register(ControllingMetadata());
      ComponentRegistry.register(EnablesControlMetadata());
      ComponentRegistry.register(DockedMetadata());
      ComponentRegistry.register(WantsControlIntentMetadata());
      ComponentRegistry.register(ReleasesControlIntentMetadata());
      ComponentRegistry.register(DockIntentMetadata());
      ComponentRegistry.register(UndockIntentMetadata());

      // Openable components
      ComponentRegistry.register(OpenableMetadata());
      ComponentRegistry.register(OpenIntentMetadata());
      ComponentRegistry.register(CloseIntentMetadata());
      ComponentRegistry.register(DidOpenMetadata());
      ComponentRegistry.register(DidCloseMetadata());

      // AI/Behavior components
      ComponentRegistry.register(BehaviorMetadata());

      // Transient event components (for debugging)
      ComponentRegistry.register(MoveByIntentMetadata());
      ComponentRegistry.register(DidMoveMetadata());
      ComponentRegistry.register(BlockedMoveMetadata());
    }
  }

  /// Requests focus for keyboard handling after the widget is built.
  void _requestFocusAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Entity?>(
      valueListenable: widget.entityNotifier,
      builder: (context, entity, child) {
        if (entity == null) {
          return const SizedBox.shrink();
        }

        // Request focus to enable keyboard navigation and ESC handling
        _requestFocusAfterBuild();

        // Using entity.id as the key forces a complete widget rebuild when inspecting
        // a different entity, which resets internal state like scroll position
        return KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (event) {
            // Process ESC key only on key down events to avoid duplicate handling
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.escape) {
              // Determine if a text input field or other focusable widget currently has focus
              final currentFocus = FocusScope.of(context).focusedChild;

              // Allow text fields to handle ESC for unfocusing; otherwise dismiss the inspector panel
              // This prevents closing the panel when the user is just trying to unfocus an input
              if (currentFocus == null || currentFocus == _focusNode) {
                widget.entityNotifier.value = null;
              }
            }
          },
          child: GestureDetector(
            // Restore focus to the panel when clicking outside of interactive elements
            // This ensures keyboard shortcuts work after interacting with text fields
            onTap: () {
              _focusNode.requestFocus();
            },
            child: _InspectorPanel(
              key: Key(entity.id.toString()),
              entity: entity,
            ),
          ),
        );
      },
    );
  }
}

/// The main inspector panel that displays component sections and the add button.
class _InspectorPanel extends StatelessWidget {
  final Entity entity;

  const _InspectorPanel({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Panel header displaying "Properties" title
          _buildHeader(context),
          // Component sections list - rebuilds whenever any component is added, removed, or modified
          Expanded(
            child: StreamBuilder<Change>(
              stream: entity.parentCell.componentChanges.onEntityChange(entity.id),
              builder: (context, snapshot) {
                final presentComponents = ComponentRegistry.getPresent(entity);

                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  children: [
                    // Display a section for each component present on the entity
                    ...presentComponents.map(
                      (metadata) => ComponentSection(
                        entity: entity,
                        metadata: metadata,
                      ),
                    ),
                    // Interactive button to add new components
                    _AddComponentButton(entity: entity),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the panel header with "Properties" title.
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Text(
        'Properties',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Button that opens a menu to add new components to the entity.
///
/// Only components that are not already present on the entity are shown in the menu.
class _AddComponentButton extends StatelessWidget {
  final Entity entity;

  const _AddComponentButton({required this.entity});

  /// Adds a component to the entity and shows a confirmation snackbar.
  void _addComponent(BuildContext context, ComponentMetadata metadata) {
    final component = metadata.createDefault();
    entity.upsertByName(component);

    // Display a temporary notification confirming the component was added
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${metadata.componentName}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final available = ComponentRegistry.getAvailable(entity);

    // Hide button if all components are already present
    if (available.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: PopupMenuButton<ComponentMetadata>(
        onSelected: (metadata) => _addComponent(context, metadata),
        itemBuilder: (context) => available
            .map(
              (metadata) => PopupMenuItem<ComponentMetadata>(
                value: metadata,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(metadata.componentName,
                    style: const TextStyle(fontSize: 12)),
              ),
            )
            .toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add,
                size: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Add Component',
                style: const TextStyle(
                  fontSize: 12,
                ).copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
