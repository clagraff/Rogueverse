import 'dart:developer';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/systems/system.dart';
import 'package:rogueverse/ecs/world.dart';

part 'combat_system.mapper.dart';

@MappableClass()
class CombatSystem extends System with CombatSystemMappable {
  static final _logger = Logger('CombatSystem');

  @override
  void update(World world) {
    Timeline.timeSync("CombatSystem: update", () {
      final attackIntents = world.get<AttackIntent>();

      var components = Map.from(attackIntents);
      components.forEach((sourceId, intent) {
        var attackIntent = intent as AttackIntent;
        var source = world.getEntity(sourceId);

        // Skip if attacker is docked
        if (source.has<Docked>()) {
          _logger.finest("skipping docked entity combat", {"entity": source});
          source.remove<AttackIntent>();
          return;
        }

        var target = world.getEntity(attackIntent.targetId);

        var health = target.get<Health>(Health(0, 0))!;
        // TODO change how damage is calculated
        const damage = 1;

        // Use upsert to ensure change notifications fire
        target.upsert(Health(health.current - damage, health.max));

        _logger.finest("target damaged", {"attacker": source, "target": target, "damage": damage, "remainingHealth": health.current - damage});

        if (health.current - damage <= 0) {
          // TODO: this doesn't actually prevent other systems from processing
          // this now-dead entity.
          target.upsert(Dead());
          target.remove<BlocksMovement>();

          _logger.fine('target killed', {'attacker': source, 'target': target});
        }
        target.upsert(WasAttacked(sourceId: sourceId, damage: 1));
        // TODO notify on health change?

        source.remove<AttackIntent>();
        source.upsert<DidAttack>(DidAttack(targetId: target.id, damage: 1));
      });
    });
  }
}
