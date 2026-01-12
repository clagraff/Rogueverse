import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/events.dart';
import 'package:rogueverse/ecs/world.dart';

/// The mode for how game ticks are triggered.
enum TickMode {
  /// Tick every [TickScheduler.tickDuration] (OSRS-style).
  /// AI and player act on the same cadence.
  periodic,

  /// Tick when player sets an intent (classic roguelike).
  /// AI only acts when player acts.
  onPlayerIntent,
}

/// Manages game tick scheduling with support for both periodic and
/// player-intent-triggered modes.
///
/// In [TickMode.periodic] mode, ticks fire at regular intervals (default 600ms).
/// In [TickMode.onPlayerIntent] mode, ticks fire when the player sets an intent.
class TickScheduler {
  static final _logger = Logger('TickScheduler');

  /// Default tick duration (600ms = 0.6s, matching OSRS tick rate).
  static const Duration defaultTickDuration = Duration(milliseconds: 600);

  /// The duration between periodic ticks.
  final Duration tickDuration;

  /// Callback invoked when a tick should be processed.
  final void Function() onTick;

  /// The world to watch for intent changes (for onPlayerIntent mode).
  World _world;

  /// Notifier for the current player entity ID (for onPlayerIntent mode).
  /// When this changes, the scheduler re-subscribes to the new entity.
  final ValueNotifier<int?> playerEntityIdNotifier;

  /// The current tick mode.
  TickMode _mode;

  /// Accumulated time since last tick (for periodic mode).
  Duration _accumulated = Duration.zero;

  /// Whether the scheduler is paused.
  bool _isPaused = false;

  /// Flag set when player intent is detected, cleared after tick.
  /// Used to defer tick execution to the update loop.
  bool _pendingTick = false;

  /// Subscription to world changes (for onPlayerIntent mode).
  StreamSubscription<Change>? _intentSubscription;

  /// Creates a new tick scheduler.
  ///
  /// [tickDuration] - How often to tick in periodic mode (default 600ms).
  /// [onTick] - Callback to invoke when a tick should occur.
  /// [world] - The ECS world to watch for intent changes.
  /// [playerEntityIdNotifier] - Notifier for the current player entity ID.
  /// [initialMode] - The initial tick mode (defaults to onPlayerIntent).
  TickScheduler({
    this.tickDuration = defaultTickDuration,
    required this.onTick,
    required World world,
    required this.playerEntityIdNotifier,
    TickMode initialMode = TickMode.onPlayerIntent,
  }) : _world = world, _mode = initialMode {
    // Listen for player entity changes to re-subscribe
    playerEntityIdNotifier.addListener(_onPlayerEntityChanged);

    // Set up initial subscription if in onPlayerIntent mode
    if (_mode == TickMode.onPlayerIntent) {
      _subscribeToPlayerIntents();
    }
  }

  /// The current tick mode.
  TickMode get mode => _mode;

  /// Whether the scheduler is currently paused.
  bool get isPaused => _isPaused;

  /// Progress towards the next tick (0.0 to 1.0).
  /// Only meaningful in periodic mode.
  double get tickProgress {
    if (_mode != TickMode.periodic) return 0.0;
    return _accumulated.inMicroseconds / tickDuration.inMicroseconds;
  }

  /// Time remaining until next tick.
  /// Only meaningful in periodic mode.
  Duration get timeUntilNextTick {
    if (_mode != TickMode.periodic) return Duration.zero;
    return tickDuration - _accumulated;
  }

  /// Sets the tick mode.
  void setMode(TickMode newMode) {
    if (_mode == newMode) return;

    _mode = newMode;

    // Update subscription based on mode
    if (newMode == TickMode.onPlayerIntent) {
      _subscribeToPlayerIntents();
    } else {
      _intentSubscription?.cancel();
      _intentSubscription = null;
    }

    // Reset state when switching modes
    _accumulated = Duration.zero;
    _pendingTick = false;
  }

  /// Called when the player entity ID changes.
  void _onPlayerEntityChanged() {
    _logger.info("player entity changed: ${playerEntityIdNotifier.value}");
    if (_mode == TickMode.onPlayerIntent) {
      _subscribeToPlayerIntents();
    }
  }

  /// Subscribes to intent changes on the current player entity.
  /// Sets [_pendingTick] flag instead of triggering tick directly.
  void _subscribeToPlayerIntents() {
    // Clean up existing subscription
    _intentSubscription?.cancel();
    _intentSubscription = null;

    final playerEntityId = playerEntityIdNotifier.value;
    _logger.info("subscribing to player intents: playerEntityId=$playerEntityId, mode=$_mode");
    if (playerEntityId == null) return;

    // Subscribe to intent changes on the player entity
    _intentSubscription = _world.componentChanges
        .onEntityChange(playerEntityId)
        .where((change) =>
            change.kind == ChangeKind.added &&
            change.newValue is IntentComponent)
        .listen((_) {
          _logger.info("intent detected, setting pending tick flag");
          _pendingTick = true;
        });
  }

  /// Updates the scheduler with elapsed time.
  ///
  /// Call this from your game's update loop with the delta time.
  void update(Duration delta) {
    if (_isPaused) return;

    if (_mode == TickMode.onPlayerIntent) {
      // Check if an intent was detected since last update
      if (_pendingTick) {
        _pendingTick = false;
        _triggerTick();
      }
    } else {
      // Periodic mode: accumulate time and tick at intervals
      _accumulated += delta;

      // Process ticks while we have enough accumulated time
      while (_accumulated >= tickDuration) {
        _accumulated -= tickDuration;
        _triggerTick();
      }
    }
  }

  /// Convenience method to call update with a double (seconds).
  void updateSeconds(double dt) {
    update(Duration(microseconds: (dt * 1000000).round()));
  }

  /// Pauses the scheduler.
  ///
  /// In periodic mode, stops accumulating time.
  /// In onPlayerIntent mode, stops triggering ticks on intent.
  void pause() {
    _isPaused = true;
  }

  /// Resumes the scheduler.
  void resume() {
    _isPaused = false;
  }

  /// Forces an immediate tick, regardless of mode or accumulated time.
  ///
  /// Useful for debugging or manual tick advancement.
  void forceTick() {
    _triggerTick();
    // Reset accumulated time to avoid double-ticking
    _accumulated = Duration.zero;
  }

  /// Disposes of the scheduler and cleans up resources.
  void dispose() {
    playerEntityIdNotifier.removeListener(_onPlayerEntityChanged);
    _intentSubscription?.cancel();
    _intentSubscription = null;
  }

  /// Updates the world reference and re-subscribes to intent changes.
  ///
  /// Call this when the world is replaced (e.g., after loading a save).
  void updateWorld(World newWorld) {
    _logger.info("updating world reference");
    _world = newWorld;
    // Re-subscribe to the new world if in onPlayerIntent mode
    if (_mode == TickMode.onPlayerIntent) {
      _subscribeToPlayerIntents();
    }
  }

  void _triggerTick() {
    _logger.info("triggering tick");
    onTick();
  }
}
