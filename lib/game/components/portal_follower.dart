import 'dart:async';

import 'package:flame/components.dart' hide World;
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'package:rogueverse/ecs/components.dart' hide Component;
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/events.dart';
import 'package:rogueverse/ecs/world.dart';

/// Automatically follows the selected entity through portals.
///
/// When the selected entity's `HasParent` component changes (indicating they
/// moved to a different room/location via a portal), this component updates
/// `viewedParentId` to follow them to the new location.
///
/// Uses efficient per-entity subscription (only listens to the selected entity's
/// HasParent changes, not all entities in the world).
class PortalFollower extends Component {
  static final _logger = Logger('PortalFollower');

  final ValueNotifier<Entity?> selectedEntityNotifier;
  final ValueNotifier<int?> viewedParentIdNotifier;
  final World world;

  int? _trackedEntityId;
  StreamSubscription<Change>? _hasParentSubscription;
  VoidCallback? _selectionListener;

  PortalFollower({
    required this.selectedEntityNotifier,
    required this.viewedParentIdNotifier,
    required this.world,
  });

  @override
  Future<void> onLoad() async {
    // When selected entity changes, re-subscribe to the new entity
    _selectionListener = _onSelectedEntityChanged;
    selectedEntityNotifier.addListener(_selectionListener!);

    // Initial setup if there's already a selected entity
    _onSelectedEntityChanged();
  }

  void _onSelectedEntityChanged() {
    final newEntityId = selectedEntityNotifier.value?.id;
    if (newEntityId == _trackedEntityId) return;

    // Cancel old subscription
    _hasParentSubscription?.cancel();
    _hasParentSubscription = null;
    _trackedEntityId = newEntityId;

    if (newEntityId != null) {
      // Subscribe ONLY to this entity's HasParent changes
      _hasParentSubscription = world.componentChanges
          .onEntityOnComponent<HasParent>(newEntityId)
          .listen(_onParentChanged);
    }
  }

  void _onParentChanged(Change change) {
    if (change.kind != ChangeKind.updated) return;

    final entity = world.getEntity(change.entityId);
    final newParent = entity.get<HasParent>();
    if (newParent != null) {
      viewedParentIdNotifier.value = newParent.parentEntityId;
      _logger.info('following selected entity to new parent', {
        'entityId': change.entityId,
        'parentId': newParent.parentEntityId,
      });
    }
  }

  @override
  void onRemove() {
    _hasParentSubscription?.cancel();
    if (_selectionListener != null) {
      selectedEntityNotifier.removeListener(_selectionListener!);
    }
  }
}
