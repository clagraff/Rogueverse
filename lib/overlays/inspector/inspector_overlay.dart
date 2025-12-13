import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/ecs.barrel.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/widgets/properties/properties.dart';


class InspectorOverlay extends StatefulWidget {
  final ValueNotifier<Entity?> entityNotifier;

  const InspectorOverlay({super.key, required this.entityNotifier});

  @override
  State<InspectorOverlay> createState() => _InspectorOverlayState();
}

class _InspectorOverlayState extends State<InspectorOverlay> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Entity?>(
      valueListenable: widget.entityNotifier,
      builder: (context, entity, child) {
        if (entity == null) {
          return const SizedBox.shrink();
        }

        // Keying by entity.id ensures the panel resets state (like scroll position) when the entity changes.
        return _InspectorPanel(key: Key(entity.id.toString()), entity: entity);
      },
    );
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
          // Sections
          Expanded(
            child: ListView(
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
              ],
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
        // Accordion header (never rebuilds)
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: scheme.surfaceVariant.withOpacity(0.6),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  'Name',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
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
        // Accordion header (never rebuilds)
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: scheme.surfaceVariant.withOpacity(0.6),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  'LocalPosition',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        // Content (rebuilds via StreamBuilder)
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
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: scheme.surfaceVariant.withOpacity(0.6),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  'Health',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
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
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: scheme.surfaceVariant.withOpacity(0.6),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  'Renderable',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
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
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: scheme.surfaceVariant.withOpacity(0.6),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  'Inventory',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
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
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: scheme.surfaceVariant.withOpacity(0.6),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  'InventoryMaxCount',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
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
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: scheme.surfaceVariant.withOpacity(0.6),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.componentType,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
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
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: scheme.surfaceVariant.withOpacity(0.6),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  'MoveByIntent',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
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
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: scheme.surfaceVariant.withOpacity(0.6),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  'DidMove',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
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
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: scheme.surfaceVariant.withOpacity(0.6),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  'BlockedMove',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
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


