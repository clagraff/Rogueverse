import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/ecs.barrel.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/widgets/properties/properties.dart';

/// Helper widget to build a section accordion header with a delete button
Widget _buildSectionHeader({
  required BuildContext context,
  required String title,
  required bool expanded,
  required VoidCallback onTap,
  required VoidCallback onDelete,
}) {
  final scheme = Theme.of(context).colorScheme;

  return Container(
    height: 32,
    padding: const EdgeInsets.only(left: 12, right: 4),
    color: scheme.surfaceVariant.withOpacity(0.6),
    child: Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onTap,
            child: Row(
              children: [
                Icon(
                  expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 16),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: onDelete,
          tooltip: 'Remove component',
        ),
      ],
    ),
  );
}

class InspectorOverlay extends StatefulWidget {
  final ValueNotifier<Entity?> entityNotifier;

  const InspectorOverlay({super.key, required this.entityNotifier});

  @override
  State<InspectorOverlay> createState() => _InspectorOverlayState();
}

class _InspectorOverlayState extends State<InspectorOverlay> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Entity?>(
      valueListenable: widget.entityNotifier,
      builder: (context, entity, child) {
        if (entity == null) {
          return const SizedBox.shrink();
        }

        // Keying by entity.id ensures the panel resets state (like scroll position) when the entity changes.
        return Shortcuts(
          shortcuts: {
            LogicalKeySet(LogicalKeyboardKey.escape): const _CloseInspectorIntent(),
          },
          child: Actions(
            actions: {
              _CloseInspectorIntent: _CloseInspectorAction(widget.entityNotifier),
            },
            child: Focus(
              focusNode: _focusNode,
              autofocus: true,
              child: _InspectorPanel(key: Key(entity.id.toString()), entity: entity),
            ),
          ),
        );
      },
    );
  }
}

/// Intent to close the inspector
class _CloseInspectorIntent extends Intent {
  const _CloseInspectorIntent();
}

/// Action to close the inspector by setting the entity notifier to null
class _CloseInspectorAction extends Action<_CloseInspectorIntent> {
  final ValueNotifier<Entity?> entityNotifier;

  _CloseInspectorAction(this.entityNotifier);

  @override
  Object? invoke(_CloseInspectorIntent intent) {
    entityNotifier.value = null;
    return null;
  }
}

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
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          // Sections - listen to ALL entity changes to rebuild when components are added/removed
          Expanded(
            child: StreamBuilder<Change>(
              stream: entity.parentCell.onEntityChange(entity.id),
              builder: (context, snapshot) {
                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  children: [
                    // Core components
                    if (entity.has<Name>())
                      _NameSection(entity: entity),
                    if (entity.has<LocalPosition>())
                      _LocalPositionSection(entity: entity),
                    if (entity.has<Health>())
                      _HealthSection(entity: entity),
                    if (entity.has<Renderable>())
                      _RenderableSection(entity: entity),

                    // Inventory
                    if (entity.has<Inventory>())
                      _InventorySection(entity: entity),
                    if (entity.has<InventoryMaxCount>())
                      _InventoryMaxCountSection(entity: entity),

                    // Marker components
                    if (entity.has<PlayerControlled>())
                      _MarkerSection(entity: entity, componentType: 'PlayerControlled'),
                    if (entity.has<AiControlled>())
                      _MarkerSection(entity: entity, componentType: 'AiControlled'),
                    if (entity.has<BlocksMovement>())
                      _MarkerSection(entity: entity, componentType: 'BlocksMovement'),
                    if (entity.has<Pickupable>())
                      _MarkerSection(entity: entity, componentType: 'Pickupable'),
                    if (entity.has<Dead>())
                      _MarkerSection(entity: entity, componentType: 'Dead'),

                    // Temporary/Event components (read-only, for debugging)
                    if (entity.has<MoveByIntent>())
                      _MoveByIntentSection(entity: entity),
                    if (entity.has<DidMove>())
                      _DidMoveSection(entity: entity),
                    if (entity.has<BlockedMove>())
                      _BlockedMoveSection(entity: entity),

                    // Add Component button
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
}

/// Section for the Name component
class _NameSection extends StatefulWidget {
  final Entity entity;

  const _NameSection({super.key, required this.entity});

  @override
  State<_NameSection> createState() => _NameSectionState();
}

class _NameSectionState extends State<_NameSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        _buildSectionHeader(
          context: context,
          title: 'Name',
          expanded: _expanded,
          onTap: () => setState(() => _expanded = !_expanded),
          onDelete: () => widget.entity.remove<Name>(),
        ),
        // Content (rebuilds via StreamBuilder)
        if (_expanded)
          StreamBuilder<Change>(
            stream: widget.entity.parentCell.onEntityOnComponent<Name>(widget.entity.id),
            builder: (context, snapshot) {
              final name = widget.entity.get<Name>();
              if (name == null) return const SizedBox.shrink();

              const theme = PropertyPanelThemeData(labelColumnWidth: 140);
              return Column(
                children: [
                  PropertyRow(
                    key: ValueKey('name_${name.name}'),
                    item: StringPropertyItem(
                      id: "name",
                      label: "Name",
                      value: name.name,
                      onChanged: (String s) {
                        widget.entity.upsert<Name>(name.copyWith(name: s));
                      },
                    ),
                    theme: theme,
                  ),
                ],
              );
            },
          ),
        Divider(
          height: 1,
          thickness: 0.5,
          color: scheme.outlineVariant,
        ),
      ],
    );
  }
}

/// Section for the LocalPosition component
class _LocalPositionSection extends StatefulWidget {
  final Entity entity;

  const _LocalPositionSection({super.key, required this.entity});

  @override
  State<_LocalPositionSection> createState() => _LocalPositionSectionState();
}

class _LocalPositionSectionState extends State<_LocalPositionSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        _buildSectionHeader(
          context: context,
          title: 'LocalPosition',
          expanded: _expanded,
          onTap: () => setState(() => _expanded = !_expanded),
          onDelete: () => widget.entity.remove<LocalPosition>(),
        ),
        if (_expanded)
          StreamBuilder<Change>(
            stream: widget.entity.parentCell.onEntityOnComponent<LocalPosition>(widget.entity.id),
            builder: (context, snapshot) {
              final localPosition = widget.entity.get<LocalPosition>();
              if (localPosition == null) return const SizedBox.shrink();

              Logger("LocalPositionSection").info("Rebuilding content with x=${localPosition.x}, y=${localPosition.y}");

              const theme = PropertyPanelThemeData(labelColumnWidth: 140);
              return Column(
                children: [
                  PropertyRow(
                    key: ValueKey('x_${localPosition.x}'),
                    item: IntPropertyItem(
                      id: "x",
                      label: "X",
                      value: localPosition.x,
                      onChanged: (int newX) {
                        widget.entity.upsert<LocalPosition>(localPosition.copyWith(x: newX));
                      },
                    ),
                    theme: theme,
                  ),
                  PropertyRow(
                    key: ValueKey('y_${localPosition.y}'),
                    item: IntPropertyItem(
                      id: "y",
                      label: "Y",
                      value: localPosition.y,
                      onChanged: (int newY) {
                        widget.entity.upsert<LocalPosition>(localPosition.copyWith(y: newY));
                      },
                    ),
                    theme: theme,
                  ),
                ],
              );
            },
          ),
        Divider(
          height: 1,
          thickness: 0.5,
          color: scheme.outlineVariant,
        ),
      ],
    );
  }
}

/// Section for the Health component
class _HealthSection extends StatefulWidget {
  final Entity entity;

  const _HealthSection({super.key, required this.entity});

  @override
  State<_HealthSection> createState() => _HealthSectionState();
}

class _HealthSectionState extends State<_HealthSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        _buildSectionHeader(
          context: context,
          title: 'Health',
          expanded: _expanded,
          onTap: () => setState(() => _expanded = !_expanded),
          onDelete: () => widget.entity.remove<Health>(),
        ),
        if (_expanded)
          StreamBuilder<Change>(
            stream: widget.entity.parentCell.onEntityOnComponent<Health>(widget.entity.id),
            builder: (context, snapshot) {
              final health = widget.entity.get<Health>();
              if (health == null) return const SizedBox.shrink();

              const theme = PropertyPanelThemeData(labelColumnWidth: 140);
              return Column(
                children: [
                  PropertyRow(
                    key: ValueKey('health_current_${health.current}'),
                    item: IntPropertyItem(
                      id: "current",
                      label: "Current",
                      value: health.current,
                      onChanged: (int newCurrent) {
                        widget.entity.upsert<Health>(health.copyWith(current: newCurrent));
                      },
                    ),
                    theme: theme,
                  ),
                  PropertyRow(
                    key: ValueKey('health_max_${health.max}'),
                    item: IntPropertyItem(
                      id: "max",
                      label: "Max",
                      value: health.max,
                      onChanged: (int newMax) {
                        widget.entity.upsert<Health>(health.copyWith(max: newMax));
                      },
                    ),
                    theme: theme,
                  ),
                ],
              );
            },
          ),
        Divider(
          height: 1,
          thickness: 0.5,
          color: scheme.outlineVariant,
        ),
      ],
    );
  }
}

/// Section for the Renderable component
class _RenderableSection extends StatefulWidget {
  final Entity entity;

  const _RenderableSection({super.key, required this.entity});

  @override
  State<_RenderableSection> createState() => _RenderableSectionState();
}

class _RenderableSectionState extends State<_RenderableSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        _buildSectionHeader(
          context: context,
          title: 'Renderable',
          expanded: _expanded,
          onTap: () => setState(() => _expanded = !_expanded),
          onDelete: () => widget.entity.remove<Renderable>(),
        ),
        if (_expanded)
          StreamBuilder<Change>(
            stream: widget.entity.parentCell.onEntityOnComponent<Renderable>(widget.entity.id),
            builder: (context, snapshot) {
              final renderable = widget.entity.get<Renderable>();
              if (renderable == null) return const SizedBox.shrink();

              const theme = PropertyPanelThemeData(labelColumnWidth: 140);
              return Column(
                children: [
                  PropertyRow(
                    key: ValueKey('renderable_${renderable.svgAssetPath}'),
                    item: StringPropertyItem(
                      id: "svgAssetPath",
                      label: "SVG Asset Path",
                      value: renderable.svgAssetPath,
                      onChanged: (String newPath) {
                        widget.entity.upsert<Renderable>(renderable.copyWith(svgAssetPath: newPath));
                      },
                    ),
                    theme: theme,
                  ),
                ],
              );
            },
          ),
        Divider(
          height: 1,
          thickness: 0.5,
          color: scheme.outlineVariant,
        ),
      ],
    );
  }
}

/// Section for the Inventory component
class _InventorySection extends StatefulWidget {
  final Entity entity;

  const _InventorySection({super.key, required this.entity});

  @override
  State<_InventorySection> createState() => _InventorySectionState();
}

class _InventorySectionState extends State<_InventorySection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        _buildSectionHeader(
          context: context,
          title: 'Inventory',
          expanded: _expanded,
          onTap: () => setState(() => _expanded = !_expanded),
          onDelete: () => widget.entity.remove<Inventory>(),
        ),
        if (_expanded)
          StreamBuilder<Change>(
            stream: widget.entity.parentCell.onEntityOnComponent<Inventory>(widget.entity.id),
            builder: (context, snapshot) {
              final inventory = widget.entity.get<Inventory>();
              if (inventory == null) return const SizedBox.shrink();

              const theme = PropertyPanelThemeData(labelColumnWidth: 140);
              return Column(
                children: [
                  PropertyRow(
                    key: ValueKey('inventory_${inventory.items.length}'),
                    item: ReadonlyPropertyItem(
                      id: "itemCount",
                      label: "Item Count",
                      value: inventory.items.length.toString(),
                    ),
                    theme: theme,
                  ),
                  PropertyRow(
                    key: ValueKey('inventory_items_${inventory.items.join(",")}'),
                    item: ReadonlyPropertyItem(
                      id: "items",
                      label: "Items",
                      value: inventory.items.isEmpty ? '[]' : inventory.items.join(', '),
                    ),
                    theme: theme,
                  ),
                ],
              );
            },
          ),
        Divider(
          height: 1,
          thickness: 0.5,
          color: scheme.outlineVariant,
        ),
      ],
    );
  }
}

/// Section for the InventoryMaxCount component
class _InventoryMaxCountSection extends StatefulWidget {
  final Entity entity;

  const _InventoryMaxCountSection({super.key, required this.entity});

  @override
  State<_InventoryMaxCountSection> createState() => _InventoryMaxCountSectionState();
}

class _InventoryMaxCountSectionState extends State<_InventoryMaxCountSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        _buildSectionHeader(
          context: context,
          title: 'InventoryMaxCount',
          expanded: _expanded,
          onTap: () => setState(() => _expanded = !_expanded),
          onDelete: () => widget.entity.remove<InventoryMaxCount>(),
        ),
        if (_expanded)
          StreamBuilder<Change>(
            stream: widget.entity.parentCell.onEntityOnComponent<InventoryMaxCount>(widget.entity.id),
            builder: (context, snapshot) {
              final maxCount = widget.entity.get<InventoryMaxCount>();
              if (maxCount == null) return const SizedBox.shrink();

              const theme = PropertyPanelThemeData(labelColumnWidth: 140);
              return Column(
                children: [
                  PropertyRow(
                    key: ValueKey('inventoryMaxCount_${maxCount.maxAmount}'),
                    item: IntPropertyItem(
                      id: "maxAmount",
                      label: "Max Amount",
                      value: maxCount.maxAmount,
                      onChanged: (int newMax) {
                        widget.entity.upsert<InventoryMaxCount>(maxCount.copyWith(maxAmount: newMax));
                      },
                    ),
                    theme: theme,
                  ),
                ],
              );
            },
          ),
        Divider(
          height: 1,
          thickness: 0.5,
          color: scheme.outlineVariant,
        ),
      ],
    );
  }
}

/// Generic section for marker components (components with no data fields)
class _MarkerSection extends StatefulWidget {
  final Entity entity;
  final String componentType;

  const _MarkerSection({super.key, required this.entity, required this.componentType});

  @override
  State<_MarkerSection> createState() => _MarkerSectionState();
}

class _MarkerSectionState extends State<_MarkerSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        _buildSectionHeader(
          context: context,
          title: widget.componentType,
          expanded: _expanded,
          onTap: () => setState(() => _expanded = !_expanded),
          onDelete: () => widget.entity.removeByName(widget.componentType),
        ),
        if (_expanded)
          Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Marker component (no editable fields)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: scheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        Divider(
          height: 1,
          thickness: 0.5,
          color: scheme.outlineVariant,
        ),
      ],
    );
  }
}

/// Section for the MoveByIntent component
class _MoveByIntentSection extends StatefulWidget {
  final Entity entity;

  const _MoveByIntentSection({super.key, required this.entity});

  @override
  State<_MoveByIntentSection> createState() => _MoveByIntentSectionState();
}

class _MoveByIntentSectionState extends State<_MoveByIntentSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        _buildSectionHeader(
          context: context,
          title: 'MoveByIntent',
          expanded: _expanded,
          onTap: () => setState(() => _expanded = !_expanded),
          onDelete: () => widget.entity.remove<MoveByIntent>(),
        ),
        if (_expanded)
          StreamBuilder<Change>(
            stream: widget.entity.parentCell.onEntityOnComponent<MoveByIntent>(widget.entity.id),
            builder: (context, snapshot) {
              final intent = widget.entity.get<MoveByIntent>();
              if (intent == null) return const SizedBox.shrink();

              const theme = PropertyPanelThemeData(labelColumnWidth: 140);
              return Column(
                children: [
                  PropertyRow(
                    item: ReadonlyPropertyItem(
                      id: "dx",
                      label: "Delta X",
                      value: intent.dx.toString(),
                    ),
                    theme: theme,
                  ),
                  PropertyRow(
                    item: ReadonlyPropertyItem(
                      id: "dy",
                      label: "Delta Y",
                      value: intent.dy.toString(),
                    ),
                    theme: theme,
                  ),
                ],
              );
            },
          ),
        Divider(
          height: 1,
          thickness: 0.5,
          color: scheme.outlineVariant,
        ),
      ],
    );
  }
}

/// Section for the DidMove component
class _DidMoveSection extends StatefulWidget {
  final Entity entity;

  const _DidMoveSection({super.key, required this.entity});

  @override
  State<_DidMoveSection> createState() => _DidMoveSectionState();
}

class _DidMoveSectionState extends State<_DidMoveSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        _buildSectionHeader(
          context: context,
          title: 'DidMove',
          expanded: _expanded,
          onTap: () => setState(() => _expanded = !_expanded),
          onDelete: () => widget.entity.remove<DidMove>(),
        ),
        if (_expanded)
          StreamBuilder<Change>(
            stream: widget.entity.parentCell.onEntityOnComponent<DidMove>(widget.entity.id),
            builder: (context, snapshot) {
              final didMove = widget.entity.get<DidMove>();
              if (didMove == null) return const SizedBox.shrink();

              const theme = PropertyPanelThemeData(labelColumnWidth: 140);
              return Column(
                children: [
                  PropertyRow(
                    item: ReadonlyPropertyItem(
                      id: "from",
                      label: "From",
                      value: '(${didMove.from.x}, ${didMove.from.y})',
                    ),
                    theme: theme,
                  ),
                  PropertyRow(
                    item: ReadonlyPropertyItem(
                      id: "to",
                      label: "To",
                      value: '(${didMove.to.x}, ${didMove.to.y})',
                    ),
                    theme: theme,
                  ),
                ],
              );
            },
          ),
        Divider(
          height: 1,
          thickness: 0.5,
          color: scheme.outlineVariant,
        ),
      ],
    );
  }
}

/// Section for the BlockedMove component
class _BlockedMoveSection extends StatefulWidget {
  final Entity entity;

  const _BlockedMoveSection({super.key, required this.entity});

  @override
  State<_BlockedMoveSection> createState() => _BlockedMoveSectionState();
}

class _BlockedMoveSectionState extends State<_BlockedMoveSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        _buildSectionHeader(
          context: context,
          title: 'BlockedMove',
          expanded: _expanded,
          onTap: () => setState(() => _expanded = !_expanded),
          onDelete: () => widget.entity.remove<BlockedMove>(),
        ),
        if (_expanded)
          StreamBuilder<Change>(
            stream: widget.entity.parentCell.onEntityOnComponent<BlockedMove>(widget.entity.id),
            builder: (context, snapshot) {
              final blockedMove = widget.entity.get<BlockedMove>();
              if (blockedMove == null) return const SizedBox.shrink();

              const theme = PropertyPanelThemeData(labelColumnWidth: 140);
              return Column(
                children: [
                  PropertyRow(
                    item: ReadonlyPropertyItem(
                      id: "attempted",
                      label: "Attempted",
                      value: '(${blockedMove.attempted.x}, ${blockedMove.attempted.y})',
                    ),
                    theme: theme,
                  ),
                ],
              );
            },
          ),
        Divider(
          height: 1,
          thickness: 0.5,
          color: scheme.outlineVariant,
        ),
      ],
    );
  }
}

/// Button to add new components to the entity
class _AddComponentButton extends StatelessWidget {
  final Entity entity;

  const _AddComponentButton({required this.entity});

  /// Create a default instance of a component by name
  Component _createDefaultComponent(String componentType) {
    switch (componentType) {
      case 'Name':
        return Name(name: 'Unnamed');
      case 'LocalPosition':
        return LocalPosition(x: 0, y: 0);
      case 'Health':
        return Health(10, 10);
      case 'Renderable':
        return Renderable('assets/sprites/default.svg');
      case 'Inventory':
        return Inventory([]);
      case 'InventoryMaxCount':
        return InventoryMaxCount(10);
      case 'PlayerControlled':
        return PlayerControlled();
      case 'AiControlled':
        return AiControlled();
      case 'BlocksMovement':
        return BlocksMovement();
      case 'Pickupable':
        return Pickupable();
      case 'Dead':
        return Dead();
      case 'MoveByIntent':
        return MoveByIntent(dx: 0, dy: 0);
      case 'BlockedMove':
        return BlockedMove(LocalPosition(x: 0, y: 0));
      default:
        throw Exception('Unknown component type: $componentType');
    }
  }

  /// Get list of component types that can be added (not already on entity)
  List<String> _getAvailableComponents() {
    final all = [
      'Name',
      'LocalPosition',
      'Health',
      'Renderable',
      'Inventory',
      'InventoryMaxCount',
      'PlayerControlled',
      'AiControlled',
      'BlocksMovement',
      'Pickupable',
      'Dead',
      'MoveByIntent',
      'BlockedMove',
    ];

    return all.where((type) {
      switch (type) {
        case 'Name':
          return !entity.has<Name>();
        case 'LocalPosition':
          return !entity.has<LocalPosition>();
        case 'Health':
          return !entity.has<Health>();
        case 'Renderable':
          return !entity.has<Renderable>();
        case 'Inventory':
          return !entity.has<Inventory>();
        case 'InventoryMaxCount':
          return !entity.has<InventoryMaxCount>();
        case 'PlayerControlled':
          return !entity.has<PlayerControlled>();
        case 'AiControlled':
          return !entity.has<AiControlled>();
        case 'BlocksMovement':
          return !entity.has<BlocksMovement>();
        case 'Pickupable':
          return !entity.has<Pickupable>();
        case 'Dead':
          return !entity.has<Dead>();
        case 'MoveByIntent':
          return !entity.has<MoveByIntent>();
        case 'BlockedMove':
          return !entity.has<BlockedMove>();
        default:
          return false;
      }
    }).toList();
  }

  void _addComponent(BuildContext context, String componentType) {
    final component = _createDefaultComponent(componentType);
    entity.upsertByName(component);

    // Show a brief confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $componentType'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final available = _getAvailableComponents();

    if (available.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: PopupMenuButton<String>(
        onSelected: (componentType) => _addComponent(context, componentType),
        itemBuilder: (context) => available
            .map((type) => PopupMenuItem<String>(
                  value: type,
                  child: Text(type),
                ))
            .toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Add Component',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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


