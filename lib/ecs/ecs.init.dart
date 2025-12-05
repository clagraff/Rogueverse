// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element

import 'ai/behaviors/behaviors.dart' as p0;
import 'ai/composite_nodes.dart' as p1;
import 'ai/decorator_nodes.dart' as p2;
import 'ai/leaf_nodes.dart' as p3;
import 'ai/nodes.dart' as p4;
import 'components.dart' as p5;
import 'systems.dart' as p6;
import 'world.dart' as p7;

void initializeMappers() {
  p0.MoveRandomlyNodeMapper.ensureInitialized();
  p1.SelectorMapper.ensureInitialized();
  p1.ParallelMapper.ensureInitialized();
  p1.RandomSelectorMapper.ensureInitialized();
  p2.InverterMapper.ensureInitialized();
  p2.RepeaterMapper.ensureInitialized();
  p2.GuardMapper.ensureInitialized();
  p2.TimeoutMapper.ensureInitialized();
  p3.ConditionNodeMapper.ensureInitialized();
  p3.ActionNodeMapper.ensureInitialized();
  p4.NodeMapper.ensureInitialized();
  p5.ComponentMapper.ensureInitialized();
  p5.LifetimeMapper.ensureInitialized();
  p5.BeforeTickMapper.ensureInitialized();
  p5.AfterTickMapper.ensureInitialized();
  p5.CellMapper.ensureInitialized();
  p5.NameMapper.ensureInitialized();
  p5.LocalPositionMapper.ensureInitialized();
  p5.MoveByIntentMapper.ensureInitialized();
  p5.DidMoveMapper.ensureInitialized();
  p5.BlocksMovementMapper.ensureInitialized();
  p5.BlockedMoveMapper.ensureInitialized();
  p5.PlayerControlledMapper.ensureInitialized();
  p5.AiControlledMapper.ensureInitialized();
  p5.BehaviorMapper.ensureInitialized();
  p5.RenderableMapper.ensureInitialized();
  p5.HealthMapper.ensureInitialized();
  p5.AttackIntentMapper.ensureInitialized();
  p5.DidAttackMapper.ensureInitialized();
  p5.WasAttackedMapper.ensureInitialized();
  p5.DeadMapper.ensureInitialized();
  p5.InventoryMapper.ensureInitialized();
  p5.InventoryMaxCountMapper.ensureInitialized();
  p5.LootMapper.ensureInitialized();
  p5.LootTableMapper.ensureInitialized();
  p5.InventoryFullFailureMapper.ensureInitialized();
  p5.PickupableMapper.ensureInitialized();
  p5.PickupIntentMapper.ensureInitialized();
  p5.PickedUpMapper.ensureInitialized();
  p6.SystemMapper.ensureInitialized();
  p6.CollisionSystemMapper.ensureInitialized();
  p6.MovementSystemMapper.ensureInitialized();
  p6.InventorySystemMapper.ensureInitialized();
  p6.CombatSystemMapper.ensureInitialized();
  p6.BehaviorSystemMapper.ensureInitialized();
  p7.WorldMapper.ensureInitialized();
}

