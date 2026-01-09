import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/ecs.barrel.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/ecs/events.dart';

/// Metadata for the Behavior component (read-only display of behavior tree).
class BehaviorMetadata extends ComponentMetadata {
  @override
  String get componentName => 'Behavior';

  @override
  bool hasComponent(Entity entity) => entity.has<Behavior>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<Behavior>(entity.id),
      builder: (context, snapshot) {
        final behavior = entity.get<Behavior>();
        if (behavior == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Behavior Tree',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'Root: ${behavior.behavior.runtimeType}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Component createDefault() {
    // Behavior requires a Node, which is complex to create.
    // This is a placeholder that won't work in practice.
    throw UnimplementedError(
      'Cannot create default Behavior - requires behavior tree node',
    );
  }

  @override
  void removeComponent(Entity entity) => entity.remove<Behavior>();
}
