import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/sections/sections.dart';

/// Registers all component metadata with the ComponentRegistry.
///
/// This should be called once at app startup (in main.dart) before
/// any inspector UI is displayed. The registry handles duplicate
/// registrations gracefully via map overwrite.
void registerAllComponents() {
  // Core gameplay components
  ComponentRegistry.register(NameMetadata());
  ComponentRegistry.register(LocalPositionMetadata());
  ComponentRegistry.register(DirectionMetadata());
  ComponentRegistry.register(HealthMetadata());
  ComponentRegistry.register(RenderableMetadata());
  ComponentRegistry.register(EditorRenderableMetadata());
  ComponentRegistry.register(DirectionBasedRenderingMetadata());

  // Hierarchy components
  ComponentRegistry.register(HasParentMetadata());

  // Inventory components
  ComponentRegistry.register(InventoryMetadata());
  ComponentRegistry.register(InventoryMaxCountMetadata());
  ComponentRegistry.register(PickupIntentMetadata());
  ComponentRegistry.register(PickedUpMetadata());
  ComponentRegistry.register(InventoryFullFailureMetadata());

  // Item components
  ComponentRegistry.register(ItemMetadata());
  ComponentRegistry.register(DescriptionMetadata());
  ComponentRegistry.register(LootTableMetadata());

  // Marker components (tags with no data)
  ComponentRegistry.register(AiControlledMetadata());
  ComponentRegistry.register(BlocksMovementMetadata());
  ComponentRegistry.register(PickupableMetadata());
  ComponentRegistry.register(DeadMetadata());
  ComponentRegistry.register(PlayerMetadata());

  // Vision components
  ComponentRegistry.register(VisionRadiusMetadata());
  ComponentRegistry.register(VisibleEntitiesMetadata());
  ComponentRegistry.register(VisionMemoryMetadata());
  ComponentRegistry.register(BlocksSightMetadata());

  // Combat components
  ComponentRegistry.register(AttackIntentMetadata());
  ComponentRegistry.register(DidAttackMetadata());
  ComponentRegistry.register(WasAttackedMetadata());

  // Portal components
  ComponentRegistry.register(PortalToPositionMetadata());
  ComponentRegistry.register(PortalToAnchorMetadata());
  ComponentRegistry.register(PortalAnchorMetadata());
  ComponentRegistry.register(UsePortalIntentMetadata());
  ComponentRegistry.register(DidPortalMetadata());
  ComponentRegistry.register(FailedToPortalMetadata());

  // Control components
  ComponentRegistry.register(ControllableMetadata());
  ComponentRegistry.register(ControllingMetadata());
  ComponentRegistry.register(EnablesControlMetadata());
  ComponentRegistry.register(DockedMetadata());
  ComponentRegistry.register(WantsControlIntentMetadata());
  ComponentRegistry.register(ReleasesControlIntentMetadata());
  ComponentRegistry.register(DockIntentMetadata());
  ComponentRegistry.register(UndockIntentMetadata());

  // Openable components
  ComponentRegistry.register(OpenableMetadata());
  ComponentRegistry.register(OpenIntentMetadata());
  ComponentRegistry.register(CloseIntentMetadata());
  ComponentRegistry.register(DidOpenMetadata());
  ComponentRegistry.register(DidCloseMetadata());

  // AI/Behavior components
  ComponentRegistry.register(BehaviorMetadata());

  // Dialog components
  ComponentRegistry.register(DialogMetadata());

  // Transient event components (for debugging)
  ComponentRegistry.register(MoveByIntentMetadata());
  ComponentRegistry.register(DidMoveMetadata());
  ComponentRegistry.register(BlockedMoveMetadata());
  ComponentRegistry.register(DirectionIntentMetadata());
  ComponentRegistry.register(DidChangeDirectionMetadata());

  // Lifecycle components
  ComponentRegistry.register(LifetimeMetadata());
  ComponentRegistry.register(BeforeTickMetadata());
  ComponentRegistry.register(AfterTickMetadata());

  // Grid components
  ComponentRegistry.register(CellMetadata());

  // Template components
  ComponentRegistry.register(IsTemplateMetadata());
  ComponentRegistry.register(FromTemplateMetadata());
}
