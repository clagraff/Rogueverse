import 'package:flame/components.dart' as flame;
import 'package:flame/debug.dart';
import 'package:rogueverse/main.dart';
import 'package:rogueverse/src/engine/engine.gen.dart';
import 'package:rogueverse/src/ui/components/components.gen.dart';

class GameWorld extends flame.World with Disposer {
  final _spawnedEntityIds = <int>{};

  @override
  Future<void> onLoad() async {
    final game = parent!.findGame() as MyGame;
    final chunk = game.liveChunk;

    // final player = Player(
    //   ecsWorld: chunk,
    //   entity: chunk.entity(playerId),
    //   svgAssetPath: 'images/player.svg',
    //   position: flame.Vector2(0, 0),
    // );
    // add(player);

    add(FpsComponent());
    add(TimeTrackComponent());

    var visibleTiles = Query().require<Renderable>().require<LocalPosition>();

    chunk.onInitQuery(visibleTiles, (entity) {
      if (_spawnedEntityIds.contains(entity.id)) return;
      _spawnedEntityIds.add(entity.id);

      var pos = entity.get<LocalPosition>()!;
      if (entity.has<PlayerControlled>()) {
        add(PlayerControlledAgent(
          chunk: chunk,
          entity: entity,
          svgAssetPath: entity.get<Renderable>()!.svgAssetPath,
          position: flame.Vector2(pos.x * 32, pos.y * 32),
        ));
      } else {
        if (entity.has<AiControlled>()) {
          add(Opponent(
            chunk: chunk,
            entity: entity,
            svgAssetPath: entity.get<Renderable>()!.svgAssetPath,
            position: flame.Vector2(pos.x * 32, pos.y * 32),
          ));
        } else {
          add(Agent(
            chunk: chunk,
            entity: entity,
            svgAssetPath: entity.get<Renderable>()!.svgAssetPath,
            position: flame.Vector2(pos.x * 32, pos.y * 32),
          ));
        }
      }

      return;
    });

    // Create ECS entity
    final playerId = chunk.create();

    Transaction(chunk, playerId)
      ..set(Renderable('images/player.svg'))
      ..set(LocalPosition(x: 0, y: 0))
      ..set(PlayerControlled())
      ..set(BlocksMovement())
      ..commit();

    // Create other
    final snakeId = chunk.create();

    Transaction(chunk, snakeId)
      ..set(Renderable('images/snake.svg'))
      ..set(LocalPosition(x: 1, y: 2))
      ..set(AiControlled())
      ..set(BlocksMovement())
      ..commit();

    final wall = chunk.create();

    Transaction(chunk, wall)
      ..set(Renderable('images/wall.svg'))
      ..set(LocalPosition(x: 1, y: 0))
      ..set(BlocksMovement())
      ..commit();

    //add(WallPlacer(chunk: chunk));

    // var wallType = Archetype()
    //     ..set<Renderable>(Renderable('images/wall.svg'))
    //     ..set<BlocksMovement>(BlocksMovement());

    //add(EntityPlacer(chunk: chunk, archetype: wallType));
  }

  @override
  void onRemove() {
    disposeAll();
  }
}
