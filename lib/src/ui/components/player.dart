import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rogueverse/main.dart';
import 'package:rogueverse/src/application_ui/overlays/player_inventory_widget.dart';
import '../../ui/components/components.gen.dart';
import '../../engine/engine.gen.dart';

class KeyBindingMap<T> {
  final Map<Set<LogicalKeyboardKey>, T> _bindings = {};

  void bind(T action, List<LogicalKeyboardKey> keys) {
    _bindings[{...keys}] = action;
  }

  /// Tries to resolve the current keypress set to a mapped action.
  T? resolve(
      Set<LogicalKeyboardKey> keysPressed, LogicalKeyboardKey latestKey) {
    for (final entry in _bindings.entries) {
      if (entry.key.length == keysPressed.length &&
          entry.key.containsAll(keysPressed)) {
        return entry.value;
      }
    }
    return null;
  }
}

enum Movement { up, right, down, left }

final movementControls = KeyBindingMap<Movement>()
  ..bind(Movement.left, [LogicalKeyboardKey.keyA])
  ..bind(Movement.right, [LogicalKeyboardKey.keyD])
  ..bind(Movement.up, [LogicalKeyboardKey.keyW])
  ..bind(Movement.down, [LogicalKeyboardKey.keyS]);

enum Meta { paused }

final metaControls = KeyBindingMap<Meta>()
  ..bind(Meta.paused, [LogicalKeyboardKey.space]);

enum Interactions { interactAtPosition }

final interactionControls = KeyBindingMap<Interactions>()
  ..bind(Interactions.interactAtPosition, [LogicalKeyboardKey.keyE]);

class PlayerControlledAgent extends Agent with KeyboardHandler, TapCallbacks {
  Effect? effect;

  PlayerControlledAgent(
      {required super.chunk,
      required super.entity,
      required super.svgAssetPath,
      super.position,
      super.size});

  static const movementDistance = 1; // ECS units, not pixels!

  final _inputToDelta = {
    LogicalKeyboardKey.keyA: Vector2(-1, 0),
    LogicalKeyboardKey.keyD: Vector2(1, 0),
    LogicalKeyboardKey.keyW: Vector2(0, -1),
    LogicalKeyboardKey.keyS: Vector2(0, 1),
  };

  void showInventoryOverlay(
      BuildContext context, List<InventoryItem> inventoryList) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final entry = OverlayEntry(
      builder: (context) => PlayerInventoryWidget(
        inventory: inventoryList,
        margin: const EdgeInsets.only(top: 20, right: 20),
        padding: const EdgeInsets.all(16),
      ),
    );

    overlay.insert(entry);

    // Optional: Store `entry` somewhere if you want to remove it later
  }

  void showTable(BuildContext context) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final entry = OverlayEntry(
      builder: (context) => Material(type: MaterialType.transparency, child: Theme(data: ThemeData.dark(), child: Center(
        child: Container(
          width: 300, // Control width
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8), // Semi-transparent background
            border: Border.all(color: Colors.white, width: 2), // Game-style border
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
                  DataColumn(label: Text("Value"), numeric: true),
                ],
                rows: <DataRow>[
                  DataRow(cells: [
                    DataCell(Text("Long Sword")),
                    DataCell(Text("1")),
                    DataCell(Text("350")),
                  ]),
                  DataRow(cells: [
                    DataCell(Text("Iron Helm")),
                    DataCell(Text("1")),
                    DataCell(Text("50")),
                  ]),
                  DataRow(cells: [
                    DataCell(Text("Copper Greaves")),
                    DataCell(Text("2")),
                    DataCell(Text("100")),
                  ]),
                  DataRow(cells: [
                    DataCell(Text("Gold")),
                    DataCell(Text("1500")),
                    DataCell(Text("1500")),
                  ]),
                  DataRow(cells: [
                    DataCell(Text("Magic Potion")),
                    DataCell(Text("16")),
                    DataCell(Text("3600")),
                  ]),
                  // ... other rows remain the same
                ],
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => {

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: Text("Close"),
              ),
            ],
          ),
        ),
      ))),
    );

    overlay.insert(entry);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    var game = (parent?.findGame() as MyGame);

    if (event is KeyDownEvent) {
      var check = metaControls.resolve(keysPressed, event.logicalKey);
      if (check != null && check == Meta.paused) {
        // TODO remove this later
        // ----------
        var health = entity.get<Health>()!;
        entity.set<Health>(health.cloneRelative(-1));

        // var i = entity.get<Inventory>();
        // if (i != null && i.entityIds.length > 0) {
        //   List<InventoryItem> items = [];
        //   for (var id in i.entityIds) {
        //     var itemEntity = chunk.get<Name>(id)!;
        //     items.add(InventoryItem(name: itemEntity.name, quantity: 1));
        //   }
        //   showInventoryOverlay(game.buildContext!, items);
        // }

        showTable(game.buildContext!);

        // -----------

        game.tickEcs();
        return false;
      }

      var interaction =
          interactionControls.resolve(keysPressed, event.logicalKey);
      if (interaction != null) {
        switch (interaction) {
          case Interactions.interactAtPosition:
            var pos = entity.get<LocalPosition>()!;

            var firstItemAtFeet = Query()
                .require<LocalPosition>((c) {
                  return c.x == pos.x && c.y == pos.y;
                })
                .require<Pickupable>()
                .first(chunk);
            if (firstItemAtFeet != null) {
              entity.set<PickupIntent>(PickupIntent(firstItemAtFeet.id));

              game.tickEcs();
              return false;
            }
          default:
            break; // no-op
        }
      }

      var result = movementControls.resolve(keysPressed, event.logicalKey);
      if (result != null) {
        switch (result) {
          case Movement.up:
            entity.set(MoveByIntent(dx: 0, dy: -1));
            break;
          case Movement.right:
            entity.set(MoveByIntent(dx: 1, dy: 0));
            break;
          case Movement.down:
            entity.set(MoveByIntent(dx: 0, dy: 1));
            break;
          case Movement.left:
            entity.set(MoveByIntent(dx: -1, dy: 0));
            break;
        }
        game.tickEcs(); // Run tick after input
        return false;
      }
    }
    return true;
  }
}
