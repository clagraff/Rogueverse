
import 'package:dart_mappable/dart_mappable.dart';
import 'package:rogueverse/ecs/ai/nodes.dart';
import 'package:rogueverse/ecs/entity.dart';

part 'decorator_nodes.mapper.dart';

/// Decorates a single child node by inverting its result.
///
/// This node is useful for creating logical NOT operations in the behavior tree.
@MappableClass()
class Inverter extends Node with InverterMappable {
  /// The child node whose result will be inverted
  final Node child;

  Inverter(this.child);

  @override
  BehaviorStatus tick(Entity blackboard) {
    final status = child.tick(blackboard);
    if (status == BehaviorStatus.success) return BehaviorStatus.failure;
    if (status == BehaviorStatus.failure) return BehaviorStatus.success;
    return BehaviorStatus.running;
  }

  @override
  void reset() {
    child.reset();
  }
}

/// Repeats execution of child node a specified number of times.
///
/// This node will continue to execute its child until the repeat count is reached,
/// regardless of whether the child succeeds or fails.
@MappableClass()
class Repeater extends Node with RepeaterMappable {
  /// The child node to repeat
  final Node child;

  /// Number of times to repeat the child node
  final int repeatCount;

  /// Current repetition count
  int _currentCount = 0;

  Repeater(this.child, this.repeatCount);

  @override
  BehaviorStatus tick(Entity blackboard) {
    final status = child.tick(blackboard);
    if (status == BehaviorStatus.running) return BehaviorStatus.running;

    _currentCount++;
    child.reset();

    if (_currentCount >= repeatCount) {
      reset();
      return BehaviorStatus.success;
    }

    return BehaviorStatus.running;
  }

  @override
  void reset() {
    _currentCount = 0;
    child.reset();
  }
}

/// Executes child only if a condition is met.
///
/// Acts as a guard or filter for its child node.
@MappableClass()
class Guard extends Node with GuardMappable {
  /// The condition to check
  final ConditionFunc condition;

  /// The child node to execute if condition is true
  final Node child;

  Guard(this.condition, this.child);

  @override
  BehaviorStatus tick(Entity blackboard) {
    if (!condition(blackboard)) {
      return BehaviorStatus.failure;
    }
    return child.tick(blackboard);
  }

  @override
  void reset() {
    child.reset();
  }
}

/// Fails if child doesn't complete within a specified time limit.
@MappableClass()
class Timeout extends Node with TimeoutMappable {
  /// The child node to execute with a time limit
  final Node child;

  /// Maximum execution time in milliseconds
  final int timeoutMs;

  /// When execution started
  DateTime? _startTime;

  Timeout(this.child, this.timeoutMs);

  @override
  BehaviorStatus tick(Entity blackboard) {
    _startTime ??= DateTime.now();

    final elapsed = DateTime.now().difference(_startTime!).inMilliseconds;
    if (elapsed > timeoutMs) {
      reset();
      return BehaviorStatus.failure;
    }

    final status = child.tick(blackboard);
    if (status != BehaviorStatus.running) {
      reset();
    }
    return status;
  }

  @override
  void reset() {
    _startTime = null;
    child.reset();
  }
}


// TODO: Add `UntilSuccess` decorator?
// TODO: Add `Succeeder` decorator, which always returns a Success regardless of if its child actually was?