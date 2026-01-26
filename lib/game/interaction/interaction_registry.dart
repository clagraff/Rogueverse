import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/game/interaction/interaction_definition.dart';

/// Registry of all available interaction types.
///
/// Maps ECS components to user-facing interactions. Each interaction defines
/// how to detect availability and how to create the corresponding intent.
class InteractionRegistry {
  /// All registered interaction types (target-based interactions).
  static final List<InteractionDefinition> interactions = [
    // Door interactions
    InteractionDefinition(
      actionName: 'Open',
      actionVerb: 'Opening',
      genericLabel: 'Door',
      range: 1, // Adjacent only
      isAvailable: (e) => e.has<Openable>() && !e.get<Openable>()!.isOpen,
      createIntent: (e) => OpenIntent(targetEntityId: e.id),
    ),
    InteractionDefinition(
      actionName: 'Close',
      actionVerb: 'Closing',
      genericLabel: 'Door',
      range: 1, // Adjacent only
      isAvailable: (e) => e.has<Openable>() && e.get<Openable>()!.isOpen,
      createIntent: (e) => CloseIntent(targetEntityId: e.id),
    ),

    // Dialog interaction
    InteractionDefinition(
      actionName: 'Talk',
      actionVerb: 'Talking',
      genericLabel: 'NPC',
      range: 1, // Adjacent only
      isAvailable: (e) => e.has<DialogRef>(),
      createIntent: (e) => TalkIntent(targetEntityId: e.id),
    ),

    // Pickup interaction
    InteractionDefinition(
      actionName: 'Pick up',
      actionVerb: 'Picking up',
      genericLabel: 'Item',
      range: 1, // Adjacent or same tile
      isAvailable: (e) => e.has<Pickupable>(),
      createIntent: (e) => PickupIntent(e.id),
    ),

    // Future interactions (commented out for initial implementation):
    // InteractionDefinition(
    //   actionName: 'Take control',
    //   actionVerb: 'Taking control',
    //   genericLabel: 'Control Seat',
    //   range: 0, // Must be on same tile
    //   isAvailable: (e) => e.has<EnablesControl>(),
    //   createIntent: (e) => WantsControlIntent(targetEntityId: e.id),
    // ),
  ];

  /// Self-actions that don't target another entity.
  /// These are always available and shown in the menu.
  static final List<InteractionDefinition> selfInteractions = [
    InteractionDefinition(
      actionName: 'Wait',
      actionVerb: 'Waiting',
      isSelfAction: true,
      sortOrder: 1000, // Always last
      isAvailable: (_) => true, // Always available
      createIntent: (_) => WaitIntent(),
    ),
  ];

  /// All interactions combined, sorted by sortOrder.
  static List<InteractionDefinition> get allInteractions {
    final all = [...interactions, ...selfInteractions];
    all.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return all;
  }
}
