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

/// Metadata for the PickupIntent component.
class PickupIntentMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'PickupIntent';

  @override
  bool hasComponent(Entity entity) => entity.has<PickupIntent>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<PickupIntent>(entity.id),
      builder: (context, snapshot) {
        final intent = entity.get<PickupIntent>();
        if (intent == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "targetEntityId",
                label: "Target Entity ID",
                value: intent.targetEntityId.toString(),
              ),
              theme: _theme,
            ),
          ],
        );
      },
    );
  }

  @override
  Component createDefault() => PickupIntent(0);

  @override
  void removeComponent(Entity entity) => entity.remove<PickupIntent>();
}

/// Metadata for the PickedUp component.
class PickedUpMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'PickedUp';

  @override
  bool hasComponent(Entity entity) => entity.has<PickedUp>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<PickedUp>(entity.id),
      builder: (context, snapshot) {
        final pickedUp = entity.get<PickedUp>();
        if (pickedUp == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "targetEntityId",
                label: "Target Entity ID",
                value: pickedUp.targetEntityId.toString(),
              ),
              theme: _theme,
            ),
          ],
        );
      },
    );
  }

  @override
  Component createDefault() => PickedUp(0);

  @override
  void removeComponent(Entity entity) => entity.remove<PickedUp>();
}

/// Metadata for the InventoryFullFailure component.
class InventoryFullFailureMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'InventoryFullFailure';

  @override
  bool hasComponent(Entity entity) => entity.has<InventoryFullFailure>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<InventoryFullFailure>(entity.id),
      builder: (context, snapshot) {
        final failure = entity.get<InventoryFullFailure>();
        if (failure == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "targetEntityId",
                label: "Target Entity ID",
                value: failure.targetEntityId.toString(),
              ),
              theme: _theme,
            ),
          ],
        );
      },
    );
  }

  @override
  Component createDefault() => InventoryFullFailure(0);

  @override
  void removeComponent(Entity entity) => entity.remove<InventoryFullFailure>();
}

/// Metadata for the LootTable component (read-only display).
class LootTableMetadata extends ComponentMetadata {
  @override
  String get componentName => 'LootTable';

  @override
  bool hasComponent(Entity entity) => entity.has<LootTable>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<LootTable>(entity.id),
      builder: (context, snapshot) {
        final lootTable = entity.get<LootTable>();
        if (lootTable == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Loot Entries: ${lootTable.lootables.length}',
                  style: const TextStyle(fontSize: 12)),
              ...lootTable.lootables.asMap().entries.map((entry) {
                final loot = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Text(
                    '${entry.key + 1}. ${loot.components.length} components, '
                    '${(loot.probability * 100).toStringAsFixed(0)}% chance, '
                    'qty: ${loot.quantity}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Component createDefault() => LootTable([]);

  @override
  void removeComponent(Entity entity) => entity.remove<LootTable>();
}
