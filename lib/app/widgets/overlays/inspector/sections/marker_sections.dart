import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';

/// Base class for marker component metadata.
///
/// Marker components are tags with no data fields (e.g., PlayerControlled, Dead).
/// This base class provides the common display logic for all marker components.
abstract class MarkerComponentMetadata extends ComponentMetadata {
  @override
  Widget buildContent(Entity entity) {
    return Builder(
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return Container(
          padding: const EdgeInsets.all(12),
          child: Text(
            'Marker component (no editable fields)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
        );
      },
    );
  }
}

/// Metadata for the PlayerControlled marker component.
class PlayerControlledMetadata extends MarkerComponentMetadata {
  @override
  String get componentName => 'PlayerControlled';

  @override
  bool hasComponent(Entity entity) => entity.has<PlayerControlled>();

  @override
  Component createDefault() => PlayerControlled();

  @override
  void removeComponent(Entity entity) => entity.remove<PlayerControlled>();
}

/// Metadata for the AiControlled marker component.
class AiControlledMetadata extends MarkerComponentMetadata {
  @override
  String get componentName => 'AiControlled';

  @override
  bool hasComponent(Entity entity) => entity.has<AiControlled>();

  @override
  Component createDefault() => AiControlled();

  @override
  void removeComponent(Entity entity) => entity.remove<AiControlled>();
}

/// Metadata for the BlocksMovement marker component.
class BlocksMovementMetadata extends MarkerComponentMetadata {
  @override
  String get componentName => 'BlocksMovement';

  @override
  bool hasComponent(Entity entity) => entity.has<BlocksMovement>();

  @override
  Component createDefault() => BlocksMovement();

  @override
  void removeComponent(Entity entity) => entity.remove<BlocksMovement>();
}

/// Metadata for the Pickupable marker component.
class PickupableMetadata extends MarkerComponentMetadata {
  @override
  String get componentName => 'Pickupable';

  @override
  bool hasComponent(Entity entity) => entity.has<Pickupable>();

  @override
  Component createDefault() => Pickupable();

  @override
  void removeComponent(Entity entity) => entity.remove<Pickupable>();
}

/// Metadata for the Dead marker component.
class DeadMetadata extends MarkerComponentMetadata {
  @override
  String get componentName => 'Dead';

  @override
  bool hasComponent(Entity entity) => entity.has<Dead>();

  @override
  Component createDefault() => Dead();

  @override
  void removeComponent(Entity entity) => entity.remove<Dead>();
}
