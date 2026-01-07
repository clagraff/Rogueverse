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
import 'entity_template.dart' as p6;
import 'systems.dart' as p7;
import 'world.dart' as p8;

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
  p5.DirectionMapper.ensureInitialized();
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
  p5.BlocksSightMapper.ensureInitialized();
  p5.VisionRadiusMapper.ensureInitialized();
  p5.VisibleEntitiesMapper.ensureInitialized();
  p5.VisionMemoryMapper.ensureInitialized();
  p5.HasParentMapper.ensureInitialized();
  p5.PortalToPositionMapper.ensureInitialized();
  p5.PortalToAnchorMapper.ensureInitialized();
  p5.PortalAnchorMapper.ensureInitialized();
  p5.UsePortalIntentMapper.ensureInitialized();
  p5.DidPortalMapper.ensureInitialized();
  p5.FailedToPortalMapper.ensureInitialized();
  p5.ControllableMapper.ensureInitialized();
  p5.ControllingMapper.ensureInitialized();
  p5.EnablesControlMapper.ensureInitialized();
  p5.DockedMapper.ensureInitialized();
  p5.WantsControlIntentMapper.ensureInitialized();
  p5.ReleasesControlIntentMapper.ensureInitialized();
  p5.DockIntentMapper.ensureInitialized();
  p5.UndockIntentMapper.ensureInitialized();
  p5.CompassDirectionMapper.ensureInitialized();
  p5.PortalFailureReasonMapper.ensureInitialized();
  p6.EntityTemplateMapper.ensureInitialized();
  p7.SystemMapper.ensureInitialized();
  p7.BudgetedSystemMapper.ensureInitialized();
  p7.HierarchySystemMapper.ensureInitialized();
  p7.CollisionSystemMapper.ensureInitialized();
  p7.MovementSystemMapper.ensureInitialized();
  p7.InventorySystemMapper.ensureInitialized();
  p7.CombatSystemMapper.ensureInitialized();
  p7.BehaviorSystemMapper.ensureInitialized();
  p7.VisionSystemMapper.ensureInitialized();
  p7.ControlSystemMapper.ensureInitialized();
  p7.PortalSystemMapper.ensureInitialized();
  p8.WorldMapper.ensureInitialized();
}

