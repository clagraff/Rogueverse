import 'package:collection/collection.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import '../../engine/components.dart';
import '../../engine/entity.dart';

// Extension for select-like mapping on map entries
extension MapSelect<K, V> on Map<K, V> {
  List<T> select<T>(T Function(MapEntry<K, V>) fn) {
    List<T> results = [];
    for (var entry in entries) {
      results.add(fn(entry));
    }
    return results;
  }
}

class PlayerInventoryWidget extends StatefulWidget {
  final Game game;
  final List<Entity> inventory;
  final Function()? onClose;

  // TODO finish these
  // final bool allowMultiSelect;
  // final Function(List<Entity>, Entity)? onSelect;
  // final Function(List<Entity>, Entity)? onDeselect;

  const PlayerInventoryWidget({
    super.key,
    required this.game,
    required this.inventory,
    this.onClose,
  });

  @override
  State<PlayerInventoryWidget> createState() => _PlayerInventoryWidgetState();
}

class _PlayerInventoryWidgetState extends State<PlayerInventoryWidget> {
  final FocusNode _focusNode = FocusNode();
  int selected = -1;
  List<DataRow> selectedRows = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void closeOverlay() {
    widget.game.overlays.toggle("PlayerInventoryWidget");
    if (widget.onClose != null) {
      widget.onClose!();
    }
  }

  @override
  Widget build(BuildContext context) {
    var lines = widget.inventory
        .groupListsBy((entity) => entity.get<Name>()?.name)
        .select((entry) => (name: entry.key, count: entry.value.length))
        .asMap()  // Convert to a map with indices
        .entries  // Get entries with both index and value
        .map((indexedEntry) {
      final index = indexedEntry.key;  // This is the stable index for this row
      final entry = indexedEntry.value;

      onSelectChangedFn(s) {
        Logger("player_inventory_widget").info("Tapped: $s");
        if (s == true) {
          setState(() {
            Logger("player_inventory_widget").info("selected = $index");
            selected = index;
          });
        } else {
          setState(() { selected = -1; });
        }
      }

      return DataRow(
          selected: index == selected,
          cells: [
            DataCell(Text(entry.name ?? 'Unknown')),
            DataCell(Text(entry.count.toString())),
          ],
          onSelectChanged: index == selected ? onSelectChangedFn : null,
      );
    }).toList();


    var dataTable = buildDataTable(lines);

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.tab) {
          closeOverlay();
          return KeyEventResult.handled;
        }
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          if (selected > -1) {
            setState(() {
              selected = -1;
            }); // Unselected currently selected row.
          } else {
            closeOverlay(); // If no row was selected, I guess close the popup.
          }

          return KeyEventResult.handled;
        }

        if (event is KeyDownEvent &&
            [
              LogicalKeyboardKey.keyW,
              LogicalKeyboardKey.keyS,
            ].contains(event.logicalKey)) {
          var direction = event.logicalKey == LogicalKeyboardKey.keyW ? -1 : 1;
          var current = dataTable.rows.indexWhere((row) => row.selected);

          // on no match, current is `-1`, which results in next == 0. Perfect.
          var next = current + direction;
          if (next < 0) {
            setState(() {
              selected = 0;
            });
          } else if (next >= dataTable.rows.length) {
            setState(() {
              selected = dataTable.rows.length;
            });
          } else {
            setState(() {
              selected = next;
            });
          }

          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).dialogTheme.backgroundColor,
          //color: Theme.of(context).dialogBackgroundColor,
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Inventory",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            dataTable,
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: closeOverlay,
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }

  DataTable buildDataTable(List<DataRow> lines) {
    return DataTable(
      columnSpacing: 24,
      horizontalMargin: 12,
      sortColumnIndex: 0,
      sortAscending: true,
      showCheckboxColumn: false, // TODO make this toggleable based on whether or not multiselect is enabled.
      columns: const [
        DataColumn(label: Text("Item")),
        DataColumn(label: Text("Qty"), numeric: true),
      ],
      rows: lines,
    );
  }
}
