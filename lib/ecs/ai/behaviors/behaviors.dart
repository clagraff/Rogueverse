import 'dart:math' show Random;

import 'package:dart_mappable/dart_mappable.dart';
import 'package:rogueverse/ecs/ai/nodes.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';

part 'behaviors.mapper.dart';

@MappableClass()
class MoveRandomlyNode extends Node with MoveRandomlyNodeMappable {
  final Random random = Random();

  @override
  void reset() {}

  @override
  BehaviorStatus tick(Entity e) {
    e.upsert<MoveByIntent>(
        MoveByIntent(dx: random.nextInt(3) - 1, dy: random.nextInt(3) - 1));
    return BehaviorStatus.success;
  }
}
