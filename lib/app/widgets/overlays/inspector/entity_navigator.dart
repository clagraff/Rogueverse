import 'package:flutter/material.dart';

import 'package:rogueverse/ecs/entity.dart';

/// InheritedWidget that provides entity navigation capability to descendants.
///
/// Wrap the inspector UI with this widget to allow component sections to
/// navigate to other entities (e.g., "Go to" buttons for entity references).
class EntityNavigator extends InheritedWidget {
  /// Callback to navigate to a specific entity by selecting it in the inspector.
  final void Function(Entity entity) onNavigateToEntity;

  const EntityNavigator({
    super.key,
    required this.onNavigateToEntity,
    required super.child,
  });

  /// Gets the nearest EntityNavigator, or null if none exists.
  static EntityNavigator? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<EntityNavigator>();
  }

  /// Navigates to the given entity if an EntityNavigator is available.
  /// Returns true if navigation was performed, false otherwise.
  static bool navigateTo(BuildContext context, Entity entity) {
    final navigator = maybeOf(context);
    if (navigator != null) {
      navigator.onNavigateToEntity(entity);
      return true;
    }
    return false;
  }

  @override
  bool updateShouldNotify(EntityNavigator oldWidget) {
    return onNavigateToEntity != oldWidget.onNavigateToEntity;
  }
}
