import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/widgets.dart';

/// A dispatcher component that manages and distributes scroll events to registered [ScrollCallback] components.
///
/// This component maintains a list of scroll listeners and dispatches scroll events to them in priority order.
/// Components with higher combined priority (including parent priorities) receive events first.
class ScrollDispatcher extends Component {
  static final _key = ComponentKey.named("ScrollDispatcher");

  /// Returns the unique component key used to identify this dispatcher in the component tree.
  @override
  get key => _key;

  final List<ScrollCallback> _listeners = [];

  void _register(ScrollCallback c) {
    _listeners.add(c);
  }

  void _unregister(ScrollCallback c) {
    _listeners.remove(c);
  }

  /// Dispatches a scroll event to all registered listeners in priority order (highest priority first).
  ///
  /// Only mounted and loaded components receive the event. Returns [true] if any listener
  /// consumed the event (returned [true] from onScroll), [false] otherwise.
  bool dispatch(PointerScrollInfo info) {
    final ordered = _listeners
        .where((c) => c.isMounted && c.isLoaded)
        .toList()
      ..sort((a, b) => _prioritySum(a).compareTo(_prioritySum(b)));

    for (final c in ordered.reversed) {
      if (c.onScroll(info)) return true;
    }
    return false;
  }

  static int _prioritySum(Component? c) {
    int total = 0;
    while (c != null) {
      total += c.priority;
      c = c.parent;
    }
    return total;
  }
}


/// ScrollCallback is used to mark a component to receive PointerScrollInfo
/// whenever a scroll gesture occurs.
/// Either by scroll-wheel or touch-pinching.
mixin ScrollCallback on Component {
  /// Callback to be executed whenever a scroll event occurs.
  ///
  /// Return [true] when the event should continue to propagate.
  bool onScroll(PointerScrollInfo info) => true;

  /// Automatically registers this component with the [ScrollDispatcher] when mounted.
  ///
  /// Searches for the dispatcher in the root game and registers this component as a listener.
  @override
  @mustCallSuper
  void onMount() async {
    super.onMount();

    final game = findRootGame()!;
    final dispatcher = game.findByKey(ScrollDispatcher._key)
    as ScrollDispatcher?;

    if (dispatcher != null) {
      dispatcher._register(this);
    }
  }

  /// Automatically unregisters this component from the [ScrollDispatcher] when removed.
  ///
  /// Searches for the dispatcher in the root game and removes this component from the listener list.
  @override
  @mustCallSuper
  void onRemove() {
    super.onRemove();

    final game = findRootGame();
    if (game != null) {
      final dispatcher =
      game.findByKey(ScrollDispatcher._key) as ScrollDispatcher?;
      dispatcher?._unregister(this);
    }
  }
}