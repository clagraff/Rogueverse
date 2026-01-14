// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element

import '../app/services/keybinding_service.dart' as p0;
import 'ai/behaviors/behaviors.dart' as p1;
import 'ai/composite_nodes.dart' as p2;
import 'ai/decorator_nodes.dart' as p3;
import 'ai/leaf_nodes.dart' as p4;
import 'ai/nodes.dart' as p5;
import 'components.dart' as p6;
import 'entity_template.dart' as p7;
import 'systems.dart' as p8;
import 'world.dart' as p9;

void initializeMappers() {
  p0.KeyComboMapper.ensureInitialized();
  p0.KeyBindingMapper.ensureInitialized();
  p1.MoveRandomlyNodeMapper.ensureInitialized();
  p2.SelectorMapper.ensureInitialized();
  p2.ParallelMapper.ensureInitialized();
  p2.RandomSelectorMapper.ensureInitialized();
  p3.InverterMapper.ensureInitialized();
  p3.RepeaterMapper.ensureInitialized();
  p3.GuardMapper.ensureInitialized();
  p3.TimeoutMapper.ensureInitialized();
  p4.ConditionNodeMapper.ensureInitialized();
  p4.ActionNodeMapper.ensureInitialized();
  p5.NodeMapper.ensureInitialized();
  p6.ComponentMapper.ensureInitialized();
  p6.DirectionMapper.ensureInitialized();
  p6.LifetimeMapper.ensureInitialized();
  p6.BeforeTickMapper.ensureInitialized();
  p6.AfterTickMapper.ensureInitialized();
  p6.IntentComponentMapper.ensureInitialized();
  p6.WaitIntentMapper.ensureInitialized();
  p6.CellMapper.ensureInitialized();
  p6.NameMapper.ensureInitialized();
  p6.LocalPositionMapper.ensureInitialized();
  p6.MoveByIntentMapper.ensureInitialized();
  p6.DidMoveMapper.ensureInitialized();
  p6.BlocksMovementMapper.ensureInitialized();
  p6.BlockedMoveMapper.ensureInitialized();
  p6.AiControlledMapper.ensureInitialized();
  p6.PlayerMapper.ensureInitialized();
  p6.BehaviorMapper.ensureInitialized();
  p6.RenderableAssetMapper.ensureInitialized();
  p6.ImageAssetMapper.ensureInitialized();
  p6.TextAssetMapper.ensureInitialized();
  p6.RenderableMapper.ensureInitialized();
  p6.HealthMapper.ensureInitialized();
  p6.AttackIntentMapper.ensureInitialized();
  p6.DidAttackMapper.ensureInitialized();
  p6.WasAttackedMapper.ensureInitialized();
  p6.DeadMapper.ensureInitialized();
  p6.InventoryMapper.ensureInitialized();
  p6.InventoryMaxCountMapper.ensureInitialized();
  p6.InventoryFullFailureMapper.ensureInitialized();
  p6.PickupableMapper.ensureInitialized();
  p6.PickupIntentMapper.ensureInitialized();
  p6.PickedUpMapper.ensureInitialized();
  p6.BlocksSightMapper.ensureInitialized();
  p6.VisionRadiusMapper.ensureInitialized();
  p6.VisibleEntitiesMapper.ensureInitialized();
  p6.VisionMemoryMapper.ensureInitialized();
  p6.HasParentMapper.ensureInitialized();
  p6.PortalToPositionMapper.ensureInitialized();
  p6.PortalToAnchorMapper.ensureInitialized();
  p6.PortalAnchorMapper.ensureInitialized();
  p6.UsePortalIntentMapper.ensureInitialized();
  p6.DidPortalMapper.ensureInitialized();
  p6.FailedToPortalMapper.ensureInitialized();
  p6.ControllableMapper.ensureInitialized();
  p6.ControllingMapper.ensureInitialized();
  p6.EnablesControlMapper.ensureInitialized();
  p6.DockedMapper.ensureInitialized();
  p6.WantsControlIntentMapper.ensureInitialized();
  p6.ReleasesControlIntentMapper.ensureInitialized();
  p6.DockIntentMapper.ensureInitialized();
  p6.UndockIntentMapper.ensureInitialized();
  p6.OpenableMapper.ensureInitialized();
  p6.OpenIntentMapper.ensureInitialized();
  p6.CloseIntentMapper.ensureInitialized();
  p6.DidOpenMapper.ensureInitialized();
  p6.DidCloseMapper.ensureInitialized();
  p6.CompassDirectionMapper.ensureInitialized();
  p6.PortalFailureReasonMapper.ensureInitialized();
  p7.EntityTemplateMapper.ensureInitialized();
  p8.SystemMapper.ensureInitialized();
  p8.BudgetedSystemMapper.ensureInitialized();
  p8.HierarchySystemMapper.ensureInitialized();
  p8.CollisionSystemMapper.ensureInitialized();
  p8.MovementSystemMapper.ensureInitialized();
  p8.InventorySystemMapper.ensureInitialized();
  p8.CombatSystemMapper.ensureInitialized();
  p8.BehaviorSystemMapper.ensureInitialized();
  p8.VisionSystemMapper.ensureInitialized();
  p8.ControlSystemMapper.ensureInitialized();
  p8.OpenableSystemMapper.ensureInitialized();
  p8.PortalSystemMapper.ensureInitialized();
  p8.SaveSystemMapper.ensureInitialized();
  p9.WorldMapper.ensureInitialized();
}

