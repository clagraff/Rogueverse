import 'dart:async' show StreamController;

import 'package:rogueverse/ecs/events.dart';

/// Event bus for broadcasting component changes in the ECS.
///
/// Provides a centralized stream for all component change events.
/// Used internally by World for change notification dispatch.
class ComponentEventBus {
  final _controller = StreamController<Change>.broadcast(sync: true);

  /// Stream of all component changes
  Stream<Change> get changes => _controller.stream;

  /// Emit a component change event
  void emit(Change change) {
    _controller.add(change);
  }

  /// Check if the stream has any listeners
  bool get hasListener => _controller.hasListener;

  /// Dispose of this event bus, closing the stream
  void dispose() {
    _controller.close();
  }
}
