import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';

/// Represents a grouped inventory item for display.
class InventoryItem {
  final String name;
  final int quantity;
  final String? iconPath;

  InventoryItem({
    required this.name,
    required this.quantity,
    this.iconPath,
  });
}

/// Inventory tab content for the character screen.
///
/// Displays a sortable table of inventory items with icons, names, and quantities.
class InventoryTabContent extends StatefulWidget {
  final List<Entity> inventory;

  const InventoryTabContent({
    super.key,
    required this.inventory,
  });

  @override
  State<InventoryTabContent> createState() => _InventoryTabContentState();
}

class _InventoryTabContentState extends State<InventoryTabContent> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  int _selectedIndex = -1;

  /// Groups inventory items by name and calculates quantities.
  List<InventoryItem> _groupItems() {
    final grouped = widget.inventory.groupListsBy((entity) {
      return entity.get<Name>()?.name ?? 'Unknown';
    });

    return grouped.entries.map((entry) {
      // Get icon from first entity in group
      final firstEntity = entry.value.first;
      String? iconPath;
      final renderable = firstEntity.get<Renderable>();
      if (renderable != null && renderable.asset is ImageAsset) {
        iconPath = (renderable.asset as ImageAsset).svgAssetPath;
      }

      return InventoryItem(
        name: entry.key,
        quantity: entry.value.length,
        iconPath: iconPath,
      );
    }).toList();
  }

  /// Sorts items based on current sort settings.
  List<InventoryItem> _sortItems(List<InventoryItem> items) {
    final sorted = List<InventoryItem>.from(items);

    sorted.sort((a, b) {
      int comparison;
      if (_sortColumnIndex == 0) {
        // Sort by name
        comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      } else {
        // Sort by quantity
        comparison = a.quantity.compareTo(b.quantity);
      }
      return _sortAscending ? comparison : -comparison;
    });

    return sorted;
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  void _onRowTap(int index) {
    setState(() {
      _selectedIndex = _selectedIndex == index ? -1 : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final items = _sortItems(_groupItems());

    if (items.isEmpty) {
      return Center(
        child: Text(
          'Your inventory is empty.',
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: DataTable(
        columnSpacing: 24,
        horizontalMargin: 16,
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        showCheckboxColumn: false,
        headingRowColor: WidgetStateProperty.all(
          colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        ),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primaryContainer.withValues(alpha: 0.3);
          }
          if (states.contains(WidgetState.hovered)) {
            return colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
          }
          return null;
        }),
        columns: [
          DataColumn(
            label: const Text('Item'),
            onSort: _onSort,
          ),
          DataColumn(
            label: const Text('Qty'),
            numeric: true,
            onSort: _onSort,
          ),
        ],
        rows: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = index == _selectedIndex;

          return DataRow(
            selected: isSelected,
            onSelectChanged: (_) => _onRowTap(index),
            cells: [
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon (24x24)
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: item.iconPath != null
                          ? _buildAssetImage(item.iconPath!)
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(width: 8),
                    Text(item.name),
                  ],
                ),
              ),
              DataCell(Text(item.quantity.toString())),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// Builds an image widget for the given asset path.
  /// Handles both SVG and raster image formats (PNG, JPG, etc).
  Widget _buildAssetImage(String path) {
    final fullPath = 'assets/$path';
    final lowerPath = path.toLowerCase();

    if (lowerPath.endsWith('.svg')) {
      return SvgPicture.asset(
        fullPath,
        width: 24,
        height: 24,
        fit: BoxFit.contain,
      );
    } else {
      // PNG, JPG, or other raster formats
      return Image.asset(
        fullPath,
        width: 24,
        height: 24,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
    }
  }
}
