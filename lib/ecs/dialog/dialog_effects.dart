import 'package:dart_mappable/dart_mappable.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';

part 'dialog_effects.mapper.dart';

/// Base class for dialog effects.
///
/// Effects modify game state when triggered during dialog.
/// They execute immediately when the dialog node is reached.
@MappableClass()
abstract class DialogEffect with DialogEffectMappable {
  const DialogEffect();

  /// Executes the effect.
  void execute(Entity player, Entity npc);
}

/// Triggers one or more game ticks.
///
/// Use this to advance game time during dialog (e.g., resting at an inn).
@MappableClass()
class TriggerTickEffect extends DialogEffect with TriggerTickEffectMappable {
  /// Number of ticks to trigger.
  final int count;

  const TriggerTickEffect({this.count = 1});

  @override
  void execute(Entity player, Entity npc) {
    final world = player.parentCell;
    for (int i = 0; i < count; i++) {
      world.tick();
    }
  }
}

/// Heals the player or NPC.
@MappableClass()
class HealEffect extends DialogEffect with HealEffectMappable {
  /// Amount to heal (absolute value).
  final int? amount;

  /// Whether to heal to full health.
  final bool fullHeal;

  /// Whether to heal player (true) or NPC (false).
  final bool targetPlayer;

  const HealEffect({
    this.amount,
    this.fullHeal = false,
    this.targetPlayer = true,
  });

  @override
  void execute(Entity player, Entity npc) {
    final target = targetPlayer ? player : npc;
    final health = target.get<Health>();
    if (health == null) return;

    if (fullHeal) {
      target.upsert(Health(health.max, health.max));
    } else if (amount != null) {
      target.upsert(health.cloneRelative(amount!));
    }
  }
}

/// Deals damage to the player or NPC.
@MappableClass()
class DamageEffect extends DialogEffect with DamageEffectMappable {
  /// Amount of damage to deal.
  final int amount;

  /// Whether to damage player (true) or NPC (false).
  final bool targetPlayer;

  const DamageEffect({
    required this.amount,
    this.targetPlayer = true,
  });

  @override
  void execute(Entity player, Entity npc) {
    final target = targetPlayer ? player : npc;
    final health = target.get<Health>();
    if (health == null) return;

    target.upsert(health.cloneRelative(-amount));
  }
}

/// Adds an item to the player's inventory.
///
/// Creates a new entity from a template or by name.
@MappableClass()
class GiveItemEffect extends DialogEffect with GiveItemEffectMappable {
  /// Name of the item to give.
  final String itemName;

  /// Number of items to give.
  final int count;

  const GiveItemEffect({
    required this.itemName,
    this.count = 1,
  });

  @override
  void execute(Entity player, Entity npc) {
    final inventory = player.get<Inventory>();
    if (inventory == null) return;

    final maxCount = player.get<InventoryMaxCount>();
    final currentCount = inventory.items.length;

    // Create items and add to inventory
    final newItems = <int>[];
    for (int i = 0; i < count; i++) {
      // Check capacity
      if (maxCount != null && currentCount + newItems.length >= maxCount.maxAmount) {
        break;
      }

      // Create a simple item entity
      final item = player.parentCell.add([
        Name(name: itemName),
      ]);
      newItems.add(item.id);
    }

    if (newItems.isNotEmpty) {
      player.upsert(Inventory([...inventory.items, ...newItems]));
    }
  }
}

/// Removes an item from the player's inventory.
@MappableClass()
class RemoveItemEffect extends DialogEffect with RemoveItemEffectMappable {
  /// Name of the item to remove.
  final String itemName;

  /// Number of items to remove.
  final int count;

  const RemoveItemEffect({
    required this.itemName,
    this.count = 1,
  });

  @override
  void execute(Entity player, Entity npc) {
    final inventory = player.get<Inventory>();
    if (inventory == null) return;

    final remaining = <int>[];
    int removed = 0;

    for (final itemId in inventory.items) {
      if (removed >= count) {
        remaining.add(itemId);
        continue;
      }

      final item = player.parentCell.getEntity(itemId);
      final name = item.get<Name>();
      if (name?.name == itemName) {
        // Remove this item from the world
        player.parentCell.remove(itemId);
        removed++;
      } else {
        remaining.add(itemId);
      }
    }

    player.upsert(Inventory(remaining));
  }
}

/// Teleports the player to a specific position.
@MappableClass()
class TeleportEffect extends DialogEffect with TeleportEffectMappable {
  /// Target X position.
  final int x;

  /// Target Y position.
  final int y;

  /// Optional parent entity ID to teleport to (for moving between rooms).
  final int? targetParentId;

  const TeleportEffect({
    required this.x,
    required this.y,
    this.targetParentId,
  });

  @override
  void execute(Entity player, Entity npc) {
    // Update position
    player.upsert(LocalPosition(x: x, y: y));

    // Update parent if specified
    if (targetParentId != null) {
      player.upsert(HasParent(targetParentId!));
    }
  }
}

/// Moves an entity (player or NPC) to a specific position.
@MappableClass()
class MoveEntityEffect extends DialogEffect with MoveEntityEffectMappable {
  /// Target X position.
  final int x;

  /// Target Y position.
  final int y;

  /// Whether to move player (true) or NPC (false).
  final bool targetPlayer;

  const MoveEntityEffect({
    required this.x,
    required this.y,
    this.targetPlayer = true,
  });

  @override
  void execute(Entity player, Entity npc) {
    final target = targetPlayer ? player : npc;
    target.upsert(LocalPosition(x: x, y: y));
  }
}

/// Opens an Openable entity (door, container, etc.).
@MappableClass()
class OpenDoorEffect extends DialogEffect with OpenDoorEffectMappable {
  /// Entity ID of the door to open.
  final int doorEntityId;

  const OpenDoorEffect({required this.doorEntityId});

  @override
  void execute(Entity player, Entity npc) {
    final door = player.parentCell.getEntity(doorEntityId);
    final openable = door.get<Openable>();
    if (openable != null && !openable.isOpen) {
      door.upsert(Openable(
        isOpen: true,
        openRenderablePath: openable.openRenderablePath,
        closedRenderablePath: openable.closedRenderablePath,
        blocksMovementWhenClosed: openable.blocksMovementWhenClosed,
        blocksVisionWhenClosed: openable.blocksVisionWhenClosed,
      ));
    }
  }
}

/// Closes an Openable entity (door, container, etc.).
@MappableClass()
class CloseDoorEffect extends DialogEffect with CloseDoorEffectMappable {
  /// Entity ID of the door to close.
  final int doorEntityId;

  const CloseDoorEffect({required this.doorEntityId});

  @override
  void execute(Entity player, Entity npc) {
    final door = player.parentCell.getEntity(doorEntityId);
    final openable = door.get<Openable>();
    if (openable != null && openable.isOpen) {
      door.upsert(Openable(
        isOpen: false,
        openRenderablePath: openable.openRenderablePath,
        closedRenderablePath: openable.closedRenderablePath,
        blocksMovementWhenClosed: openable.blocksMovementWhenClosed,
        blocksVisionWhenClosed: openable.blocksVisionWhenClosed,
      ));
    }
  }
}

/// Target for SetParentEffect.
enum ParentTarget {
  /// Use the player's entity ID as the parent.
  player,
  /// Use the NPC's entity ID as the parent.
  npc,
  /// Use a custom entity ID as the parent.
  customId,
}

/// Sets the HasParent component on player or NPC.
@MappableClass()
class SetParentEffect extends DialogEffect with SetParentEffectMappable {
  /// Whether to set parent on player (true) or NPC (false).
  final bool targetPlayer;

  /// What to set as the parent.
  final ParentTarget parentTarget;

  /// Custom entity ID to use as parent (only used when parentTarget is customId).
  final int? customParentId;

  const SetParentEffect({
    this.targetPlayer = true,
    this.parentTarget = ParentTarget.player,
    this.customParentId,
  });

  @override
  void execute(Entity player, Entity npc) {
    final target = targetPlayer ? player : npc;

    final int parentId;
    switch (parentTarget) {
      case ParentTarget.player:
        parentId = player.id;
        break;
      case ParentTarget.npc:
        parentId = npc.id;
        break;
      case ParentTarget.customId:
        if (customParentId == null) return;
        parentId = customParentId!;
        break;
    }

    target.upsert(HasParent(parentId));
  }
}

/// Removes the HasParent component from player or NPC.
@MappableClass()
class RemoveParentEffect extends DialogEffect with RemoveParentEffectMappable {
  /// Whether to remove parent from player (true) or NPC (false).
  final bool targetPlayer;

  const RemoveParentEffect({this.targetPlayer = true});

  @override
  void execute(Entity player, Entity npc) {
    final target = targetPlayer ? player : npc;
    target.remove<HasParent>();
  }
}

/// Adds a component to an entity.
@MappableClass()
class AddComponentEffect extends DialogEffect with AddComponentEffectMappable {
  /// The component to add (serialized).
  final Component component;

  /// Whether to add to player (true) or NPC (false).
  final bool targetPlayer;

  const AddComponentEffect({
    required this.component,
    this.targetPlayer = true,
  });

  @override
  void execute(Entity player, Entity npc) {
    final target = targetPlayer ? player : npc;
    target.upsertByName(component);
  }
}

/// Removes a component from an entity.
@MappableClass()
class RemoveComponentEffect extends DialogEffect
    with RemoveComponentEffectMappable {
  /// The component type name to remove.
  final String componentType;

  /// Whether to remove from player (true) or NPC (false).
  final bool targetPlayer;

  const RemoveComponentEffect({
    required this.componentType,
    this.targetPlayer = true,
  });

  @override
  void execute(Entity player, Entity npc) {
    final target = targetPlayer ? player : npc;
    target.removeByName(componentType);
  }
}

/// Executes multiple effects in sequence.
@MappableClass()
class SequenceEffect extends DialogEffect with SequenceEffectMappable {
  final List<DialogEffect> effects;

  const SequenceEffect(this.effects);

  @override
  void execute(Entity player, Entity npc) {
    for (final effect in effects) {
      effect.execute(player, npc);
    }
  }
}

/// Custom effect using a function.
///
/// Note: Custom functions cannot be serialized, so this is for runtime use only.
/// For persistent dialogs, use the built-in effect types.
@MappableClass()
class CustomEffect extends DialogEffect with CustomEffectMappable {
  @MappableField(hook: IgnoreHook())
  final void Function(Entity player, Entity npc)? executor;

  const CustomEffect({this.executor});

  @override
  void execute(Entity player, Entity npc) {
    executor?.call(player, npc);
  }
}

/// Hook to ignore a field during serialization.
class IgnoreHook extends MappingHook {
  const IgnoreHook();

  @override
  Object? beforeDecode(Object? value) => null;

  @override
  Object? afterEncode(Object? value) => null;
}
