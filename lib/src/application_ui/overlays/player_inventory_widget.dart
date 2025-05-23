import 'package:collection/collection.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../engine/components.dart';
import '../../engine/ecs.dart';

extension MapSelect<K, V> on Map<K, V> {
  List<T> select<T>(T Function(MapEntry<K, V>) fn) {
    List<T> results = [];
    for (var entry in entries) {
      results.add(fn(entry));
    }

    return results;
  }
}

class PlayerInventoryWidget extends StatelessWidget {
  final Game game;
  final List<Entity> inventory;

  final Query query = Query().require<Name>();

  PlayerInventoryWidget(
      {super.key, required this.game, required this.inventory});

  @override
  Widget build(BuildContext context) {
    var lines = inventory.groupListsBy((entity) {
      return entity.get<Name>()?.name;
    }).select((entry) {
      return (name: entry.key, count: entry.value.length);
    }).map((entry) {
      return DataRow(cells: [
        DataCell(Text(entry.name as String)),
        DataCell(Text((entry.count).toString())),
      ]);
    }).toList();

    return Container(
      width: 300, // Control width
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).dialogBackgroundColor,
        // Semi-transparent background
        //color: Colors.black.withValues(alpha: 0.8), // Semi-transparent background
        border: Border.all(color: Colors.white, width: 2),
        // Game-style border
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Inventory",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          SizedBox(height: 12),
          DataTable(
            columnSpacing: 24,
            horizontalMargin: 12,
            sortColumnIndex: 0,
            sortAscending: true,
            columns: <DataColumn>[
              DataColumn(label: Text("Item")),
              DataColumn(label: Text("Qty"), numeric: true),
              //DataColumn(label: Text("Value"), numeric: true),
            ],
            rows: lines,
            // rows: <DataRow>[
            //   DataRow(cells: [
            //     DataCell(Text("Long Sword")),
            //     DataCell(Text("1")),
            //     DataCell(Text("350")),
            //   ]),
            //   DataRow(cells: [
            //     DataCell(Text("Iron Helm")),
            //     DataCell(Text("1")),
            //     DataCell(Text("50")),
            //   ]),
            //   DataRow(cells: [
            //     DataCell(Text("Copper Greaves")),
            //     DataCell(Text("2")),
            //     DataCell(Text("100")),
            //   ]),
            //   DataRow(cells: [
            //     DataCell(Text("Gold")),
            //     DataCell(Text("1500")),
            //     DataCell(Text("1500")),
            //   ]),
            //   DataRow(cells: [
            //     DataCell(Text("Magic Potion")),
            //     DataCell(Text("16")),
            //     DataCell(Text("3600")),
            //   ]),
            //   // ... other rows remain the same
            // ],
          ),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => {game.overlays.toggle("PlayerInventoryWidget")},
            // style: ElevatedButton.styleFrom(
            //   backgroundColor: Colors.white,
            //   foregroundColor: Colors.black,
            // ),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }
}
