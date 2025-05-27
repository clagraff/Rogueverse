import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/widgets.dart';

class ScrollDispatcher extends Component {
  static final _key = ComponentKey.named("ScrollDispatcher");

  @override
  get key => _key;

  final List<ScrollCallback> _listeners = [];

  void _register(ScrollCallback c) {
    _listeners.add(c);
  }

  void _unregister(ScrollCallback c) {
    _listeners.remove(c);
  }

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

  /// Auto-register with dispatcher when mounted.
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

  /// Auto-unregister when removed.
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