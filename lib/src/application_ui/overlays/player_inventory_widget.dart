import 'package:collection/collection.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    // Group items by name and build rows
    var lines = widget.inventory
        .groupListsBy((entity) => entity.get<Name>()?.name)
        .select((entry) => (name: entry.key, count: entry.value.length))
        .map((entry) => DataRow(cells: [
      DataCell(Text(entry.name ?? 'Unknown')),
      DataCell(Text(entry.count.toString())),
    ]))
        .toList();

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.tab) {
          closeOverlay();
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
            buildDataTable(lines),
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
      columns: const [
        DataColumn(label: Text("Item")),
        DataColumn(label: Text("Qty"), numeric: true),
      ],
      rows: lines,
    );
  }
}
