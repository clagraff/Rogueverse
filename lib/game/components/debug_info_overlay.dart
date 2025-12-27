import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'package:rogueverse/ecs/components.dart' hide Component;
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/game/game_area.dart';

/// Displays debug information about the currently selected entity and observer.
class DebugInfoOverlay extends PositionComponent with HasVisibility {
  final ValueNotifier<Entity?> selectedEntityNotifier;
  final ValueNotifier<int?> observerEntityIdNotifier;
  final GameArea game;

  late TextComponent _debugText;

  DebugInfoOverlay({
    required this.selectedEntityNotifier,
    required this.observerEntityIdNotifier,
    required this.game,
  });

  @override
  Future<void> onLoad() async {
    _debugText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 14,
          fontFamily: 'monospace',
          backgroundColor: Color(0xAA000000),
        ),
      ),
      position: Vector2(10, 10),
    );
    add(_debugText);

    // Update text whenever notifiers change
    selectedEntityNotifier.addListener(_updateDebugText);
    observerEntityIdNotifier.addListener(_updateDebugText);

    _updateDebugText();
  }

  void _updateDebugText() {
    final selectedEntity = selectedEntityNotifier.value;
    final observerId = observerEntityIdNotifier.value;

    final lines = <String>[
      '=== DEBUG INFO ===',
      'Selected Entity: ${selectedEntity?.id ?? "None"}',
    ];

    if (selectedEntity != null) {
      final name = selectedEntity.get<Name>()?.name ?? 'Unnamed';
      final pos = selectedEntity.get<LocalPosition>();
      lines.add('  Name: $name');
      if (pos != null) {
        lines.add('  Position: (${pos.x}, ${pos.y})');
      }
      lines.add('  Has VisionRadius: ${selectedEntity.has<VisionRadius>()}');
    }

    lines.add('Observer Entity ID: ${observerId ?? "None"}');

    if (observerId != null) {
      final observer = game.currentWorld.getEntity(observerId);
      final visibleEntities = observer.get<VisibleEntities>();
      lines
          .add('  Visible Entities: ${visibleEntities?.entityIds.length ?? 0}');
    }

    lines.add('Inspector Active: ${game.overlays.isActive('inspectorPanel')}');
    lines.add(
        'Template Panel Active: ${game.overlays.isActive('templatePanel')}');

    _debugText.text = lines.join('\n');
  }

  @override
  void onRemove() {
    selectedEntityNotifier.removeListener(_updateDebugText);
    observerEntityIdNotifier.removeListener(_updateDebugText);
    super.onRemove();
  }
}
