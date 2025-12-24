import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart' hide World;
import 'package:flutter/material.dart';

import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/world.dart';

/// Renders a vision cone overlay showing which tiles an entity can see.
/// 
/// Updates automatically when the entity's VisibleEntities component changes.
/// Tiles farther from the observer have less prominent fill color (gradient fade).
class VisionConeComponent extends PositionComponent with HasPaint {
  final World world;
  final int observedEntityId;
  
  StreamSubscription<Change>? _visionSubscription;
  
  // Cached vision data for rendering
  Set<LocalPosition> _visibleTiles = {};
  LocalPosition? _observerPosition;
  
  VisionConeComponent({
    required this.world,
    required this.observedEntityId,
  });
  
  @override
  Future<void> onLoad() async {
    _attachToEntity();
    return super.onLoad();
  }
  
  void _attachToEntity() {
    // Subscribe ONLY to VisibleEntities changes (which already includes position/direction)
    // VisionSystem updates VisibleEntities AFTER MovementSystem runs, so we always get
    // vision data that reflects the current position and direction.
    _visionSubscription = world
        .onEntityOnComponent<VisibleEntities>(observedEntityId)
        .listen(_onVisionChanged);
    
    // Initial render
    _regenerateVisionCone();
  }
  
  void _onVisionChanged(Change change) {
    print('[VisionCone] _onVisionChanged fired: kind=${change.kind}');
    if (change.kind == ChangeKind.removed) {
      // Entity lost vision - clear the cone
      _visibleTiles = {};
      _observerPosition = null;
      return;
    }
    _regenerateVisionCone();
  }
  
  void _regenerateVisionCone() {
    final entity = world.getEntity(observedEntityId);
    final visibleEntities = entity.get<VisibleEntities>();
    final position = entity.get<LocalPosition>();
    
    print('[VisionCone] _regenerateVisionCone: tiles=${visibleEntities?.visibleTiles.length}, pos=${position?.x},${position?.y}');
    
    if (visibleEntities == null || position == null) {
      _visibleTiles = {};
      _observerPosition = null;
      return;
    }
    
    _visibleTiles = visibleEntities.visibleTiles;
    _observerPosition = position;
    
    // Flame will automatically call render() on next frame
  }
  
  @override
  void render(Canvas canvas) {
    if (_visibleTiles.isEmpty || _observerPosition == null) return;
    
    // Calculate max distance for gradient fade
    final maxDistance = _calculateMaxDistance();
    
    // Base color: semi-transparent yellow
    const baseColor = Color(0xFFFFFF00); // Yellow
    
    for (final tile in _visibleTiles) {
      // Calculate distance from observer
      final distance = _calculateDistance(_observerPosition!, tile);
      
      // Calculate alpha: farther tiles are less prominent (fade out)
      // Distance 0 (observer's tile) = max alpha (0.4)
      // Max distance = min alpha (0.05)
      final normalizedDistance = maxDistance > 0 ? distance / maxDistance : 0.0;
      final alpha = 0.4 - (normalizedDistance * 0.35); // Range: 0.4 -> 0.05
      
      paint.color = baseColor.withValues(alpha: alpha.clamp(0.05, 0.4));
      paint.style = PaintingStyle.fill;
      
      // Draw tile as filled rectangle (32x32 grid)
      final rect = Rect.fromLTWH(
        tile.x * 32.0,
        tile.y * 32.0,
        32.0,
        32.0,
      );
      canvas.drawRect(rect, paint);
    }
  }
  
  /// Calculate Euclidean distance between two positions
  double _calculateDistance(LocalPosition from, LocalPosition to) {
    final dx = (to.x - from.x).toDouble();
    final dy = (to.y - from.y).toDouble();
    return sqrt(dx * dx + dy * dy);
  }
  
  /// Find the maximum distance in the visible tiles set
  double _calculateMaxDistance() {
    if (_visibleTiles.isEmpty || _observerPosition == null) return 0.0;
    
    double max = 0.0;
    for (final tile in _visibleTiles) {
      final distance = _calculateDistance(_observerPosition!, tile);
      if (distance > max) max = distance;
    }
    return max;
  }
  
  @override
  void onRemove() {
    _visionSubscription?.cancel();
    super.onRemove();
  }
}
