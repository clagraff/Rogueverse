import 'dart:async';

import 'package:flame/components.dart' hide World;
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'package:rogueverse/ecs/components.dart' hide Component;
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/events.dart';
import 'package:rogueverse/ecs/systems.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/game/components/entity_sprite.dart';

/// Manages the lifecycle of renderable entities in the game world.
///
/// Responsibilities:
/// - Tracks which entities are currently rendered as Flame components
/// - Filters entities based on the viewed parent (room/location)
/// - Spawns/removes Flame components when entities enter/leave view
/// - Listens for component changes to spawn new renderable entities
class RenderableEntityManager extends Component {
  static final _logger = Logger('RenderableEntityManager');

  final World world;
  final ValueNotifier<int?> viewedParentNotifier;
  final ValueNotifier<int?> observerEntityIdNotifier;

  final Set<int> _renderedEntities = {};
  StreamSubscription<Change>? _spawnListener;

  RenderableEntityManager({
    required this.world,
    required this.viewedParentNotifier,
    required this.observerEntityIdNotifier,
  });

  @override
  Future<void> onLoad() async {
    // Listen for when Renderable or LocalPosition are added to an entity
    // and both are present, so we can spawn a new Flame component for it.
    _spawnListener = world.componentChanges.listen((change) {
      if (change.kind != ChangeKind.added) return;

      if (change.componentType == Renderable(ImageAsset('')).componentType ||
          change.componentType == LocalPosition(x: 0, y: 0).componentType) {
        _spawnRenderableEntity(world.getEntity(change.entityId));
      }
    });

    // Listen to viewedParentId changes to filter rendered entities
    viewedParentNotifier.addListener(_onViewedParentChanged);

    // Spawn all existing renderable entities
    world
        .entities()
        .where((e) => e.has<LocalPosition>() && e.has<Renderable>())
        .forEach((entity) {
      _spawnRenderableEntity(world.getEntity(entity.id));
    });

    // Trigger final vision update now that all components (including Agents) are spawned.
    // This ensures VisibleEntities is populated and Agent opacity is correct on initial load.
    if (observerEntityIdNotifier.value != null) {
      final visionSystem = world.systems.whereType<VisionSystem>().firstOrNull;
      visionSystem?.updateVisionForObserver(world, observerEntityIdNotifier.value!);
    }
  }

  void _onViewedParentChanged() {
    _logger.fine('viewed parent changed', {'id': viewedParentNotifier.value});
    _updateRenderedEntities();
  }

  @override
  void onRemove() {
    _spawnListener?.cancel();
    viewedParentNotifier.removeListener(_onViewedParentChanged);
  }

  /// Determines if an entity should be rendered based on the viewed parent filter.
  ///
  /// Returns true if:
  /// - viewedParentId is null: show only root-level entities (no HasParent)
  /// - viewedParentId is set: show only entities with HasParent matching that ID
  bool _shouldRenderEntity(Entity entity, int? viewedParentId) {
    // Check HasParent directly from component map for reliable lookup
    final hasParentMap = entity.parentCell.get<HasParent>();
    final hasParent = hasParentMap[entity.id];

    if (viewedParentId == null) {
      // At root level, only show entities WITHOUT HasParent
      return hasParent == null;
    }

    if (hasParent == null) {
      return false; // Entity has no parent, don't show when filtering by parent
    }

    return hasParent.parentEntityId == viewedParentId;
  }

  /// Updates which entities are rendered based on the current viewedParentId filter.
  void _updateRenderedEntities() {
    final viewedParentId = viewedParentNotifier.value;

    // Get all entities that should be rendered
    final entitiesToRender = world
        .entities()
        .where((e) => e.has<LocalPosition>() && e.has<Renderable>())
        .where((e) => _shouldRenderEntity(e, viewedParentId))
        .toSet();

    // Find Flame components that correspond to rendered entities
    final componentsToKeep = <int>{};
    final componentsToRemove = <Component>[];

    // Check all child components
    for (final component in parent!.children) {
      if (component is EntitySprite) {
        final entityId = component.entity.id;
        if (entitiesToRender.any((e) => e.id == entityId)) {
          componentsToKeep.add(entityId);
        } else {
          componentsToRemove.add(component);
        }
      }
    }

    // Remove components that shouldn't be visible
    for (final component in componentsToRemove) {
      if (component is EntitySprite) {
        _renderedEntities.remove(component.entity.id);
      }
      component.removeFromParent();
    }

    // Add components for entities that should be visible but aren't rendered yet
    for (final entity in entitiesToRender) {
      if (!componentsToKeep.contains(entity.id) &&
          !_renderedEntities.contains(entity.id)) {
        _spawnRenderableEntity(entity);
      }
    }
  }

  void _spawnRenderableEntity(Entity entity) {
    if (_renderedEntities.contains(entity.id)) return;
    final renderable = entity.get<Renderable>();
    final lp = entity.get<LocalPosition>();
    if (renderable == null || lp == null) return;

    // Check if entity should be rendered based on viewedParentId filter
    if (!_shouldRenderEntity(entity, viewedParentNotifier.value)) {
      return;
    }

    final position = Vector2(lp.x * 32, lp.y * 32);
    final sprite = EntitySprite(
      world: world,
      entity: world.getEntity(entity.id),
      asset: renderable.asset,
      position: position,
    );

    parent!.add(sprite);
    _renderedEntities.add(entity.id);
  }
}
