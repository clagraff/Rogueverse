import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/ecs.barrel.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/properties.dart';
import 'package:rogueverse/ecs/events.dart';

/// Metadata for the Inventory component, which stores a list of item entity IDs.
class InventoryMetadata extends ComponentMetadata {
  /// Theme used for property panel layout.
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'Inventory';

  @override
  bool hasComponent(Entity entity) => entity.has<Inventory>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<Inventory>(entity.id),
      builder: (context, snapshot) {
        final inventory = entity.get<Inventory>();
        if (inventory == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              key: ValueKey('inventory_${inventory.items.length}'),
              item: ReadonlyPropertyItem(
                id: "itemCount",
                label: "Item Count",
                value: inventory.items.length.toString(),
              ),
              theme: _theme,
            ),
            PropertyRow(
              key: ValueKey('inventory_items_${inventory.items.join(",")}'),
              item: ReadonlyPropertyItem(
                id: "items",
                label: "Items",
                value: inventory.items.isEmpty ? '[]' : inventory.items.join(', '),
              ),
              theme: _theme,
            ),
          ],
        );
      },
    );
  }

  @override
  Component createDefault() => Inventory([]);

  @override
  void removeComponent(Entity entity) => entity.remove<Inventory>();
}

/// Metadata for the InventoryMaxCount component, which limits inventory capacity.
class InventoryMaxCountMetadata extends ComponentMetadata {
  /// Theme used for property panel layout.
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'InventoryMaxCount';

  @override
  bool hasComponent(Entity entity) => entity.has<InventoryMaxCount>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<InventoryMaxCount>(entity.id),
      builder: (context, snapshot) {
        final maxCount = entity.get<InventoryMaxCount>();
        if (maxCount == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              key: ValueKey('inventoryMaxCount_${maxCount.maxAmount}'),
              item: IntPropertyItem(
                id: "maxAmount",
                label: "Max Amount",
                value: maxCount.maxAmount,
                onChanged: (int newMax) {
                  entity.upsert<InventoryMaxCount>(maxCount.copyWith(maxAmount: newMax));
                },
              ),
              theme: _theme,
            ),
          ],
        );
      },
    );
  }

  @override
  Component createDefault() => InventoryMaxCount(10);

  @override
  void removeComponent(Entity entity) => entity.remove<InventoryMaxCount>();
}
