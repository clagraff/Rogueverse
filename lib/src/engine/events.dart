import 'dart:async';

/// Event types for component changes
enum EventType {
  added,
  updated,
  removed
}

/// Generic event class
class Event<T> {
  final EventType eventType;
  final dynamic id;
  final T value;

  Event({required this.eventType, required this.id, required this.value});

  @override
  String toString() => 'Event<${T.runtimeType}>(type: $eventType)';
}

/// Generic event bus implemented as a singleton
class EventBus {
  // Singleton instance
  static final EventBus _instance = EventBus._internal();

  // Factory constructor to return the singleton instance
  factory EventBus() => _instance;

  // Private constructor for singleton
  EventBus._internal();

  // Type-based stream controllers
  final Map<Type, StreamController<dynamic>> _controllers = {};

  // Get or create a stream controller for a type
  StreamController<Event<T>> _getController<T>() {
    final type = T;
    if (!_controllers.containsKey(type)) {
      _controllers[type] = StreamController<Event<T>>.broadcast();
    }
    return _controllers[type] as StreamController<Event<T>>;
  }

  /// Subscribe to events for a specific type
  Stream<Event<T>> on<T>([int? onId, List<EventType>? onType]) {
    var stream = _getController<T>().stream;

    if (onId != null) {
      stream = stream.where((e) => e.id == onId);
    }

    if (onType != null) {
      stream = stream.where((e) => onType.contains(e.eventType));
    }

    return stream;
  }

  /// Publish an event
  void publish<T>(Event<T> event) {
    _getController<T>().add(event);
  }

  /// Dispose all resources
  void dispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }

  /// Reset the event bus (useful for testing)
  void reset() {
    dispose();
  }
}

extension EventBusCombinationExtension on EventBus {
  /// Listen for events of two different types and emit a combined result when both occur
  /// within the specified duration window
  Stream<(Event<T1>, Event<T2>)> onBoth<T1, T2>({Duration window = const Duration(milliseconds: 100)}) {
    final stream1 = on<T1>();
    final stream2 = on<T2>();

    // Use Rx operators to combine the streams
    return stream1.asyncExpand((event1) {
      // For each event from stream1, create a window to listen for events from stream2
      return stream2
          .where((event2) => true) // Accept any event2
          .take(1) // Take only the first matching event2
          .timeout(
        window,
        onTimeout: (sink) => sink.close(), // Close if no event2 arrives in time
      )
          .map((event2) => (event1, event2)); // Combine the events
    });
  }

  /// Listen for events of two different types for the same entity and emit a combined result
  /// when both occur within the specified duration window
  Stream<(Event<T1>, Event<T2>)> onBothForEntity<T1, T2>(dynamic entityId, {Duration window = const Duration(milliseconds: 100)}) {
    final stream1 = on<T1>().where((event) => event.id == entityId);
    final stream2 = on<T2>().where((event) => event.id == entityId);

    return stream1.asyncExpand((event1) {
      return stream2
          .take(1)
          .timeout(
        window,
        onTimeout: (sink) => sink.close(),
      )
          .map((event2) => (event1, event2));
    });
  }

  /// Listen for events of three different types and emit a combined result when all occur
  /// within the specified duration window
  Stream<(Event<T1>, Event<T2>, Event<T3>)> onAll<T1, T2, T3>({Duration window = const Duration(milliseconds: 100)}) {
    return onBoth<T1, T2>(window: window).asyncExpand((events) {
      final (event1, event2) = events;
      return on<T3>()
          .take(1)
          .timeout(
        window,
        onTimeout: (sink) => sink.close(),
      )
          .map((event3) => (event1, event2, event3));
    });
  }

  Future<Event<T>> once<T>({int? id, List<EventType>? type}) {
    late StreamSubscription<Event<T>> sub;

    final controller = Completer<Event<T>>();

    sub = on<T>(id, type).listen((event) {
      controller.complete(event);
      sub.cancel();
    });

    return controller.future;
  }

  Future<Event<T>> waitFor<T>(bool Function(Event<T>) test) {
    late StreamSubscription<Event<T>> sub;
    final completer = Completer<Event<T>>();

    sub = on<T>().listen((event) {
      if (test(event)) {
        completer.complete(event);
        sub.cancel(); // Now works because `sub` is declared
      }
    });

    return completer.future;
  }

}
