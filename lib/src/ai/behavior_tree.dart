import 'dart:math';

import 'package:rogueverse/src/engine/ecs.dart';

/// Status returned by behavior tree nodes after execution.
enum BehaviorStatus {
  /// Node completed its task successfully
  success,

  /// Node failed to complete its task
  failure,

  /// Node is still executing and needs more time
  running
}

/// Shared data storage used by behavior tree nodes to share state.
///
/// The Blackboard acts as a central repository for data that needs to be
/// accessed by multiple nodes in the behavior tree.
class Blackboard {
  final Map<String, dynamic> _data = {};

  /// Retrieves a value of type [T] associated with [key].
  ///
  /// Returns null if the key doesn't exist or if the value can't be cast to [T].
  T? get<T>(String key) => _data[key] as T?;

  /// Associates [value] of type [T] with [key] in the blackboard.
  void set<T>(String key, T value) => _data[key] = value;

  /// Checks if [key] exists in the blackboard.
  ///
  /// Returns true if the key exists, false otherwise.
  bool has(String key) => _data.containsKey(key);

  /// Removes the entry associated with [key] from the blackboard.
  void remove(String key) => _data.remove(key);
}

/// Base abstract class for all behavior tree nodes.
///
/// All nodes in a behavior tree must implement this interface.
abstract class BehaviorNode {
  /// Executes the node's logic using the provided [blackboard].
  ///
  /// Returns a [BehaviorStatus] indicating the result of execution.
  BehaviorStatus tick(Blackboard blackboard);

  /// Resets the node to its initial state.
  ///
  /// This should be called when a node needs to be re-executed from scratch.
  void reset();
}

/// Executes child nodes in sequence until one fails or all succeed.
///
/// A Sequence node represents an AND relationship between its children.
/// All children must succeed for the Sequence to succeed.
class Sequence extends BehaviorNode {
  /// List of child nodes to execute in sequence
  final List<BehaviorNode> children;

  /// Index of the currently executing child
  int _currentIndex = 0;

  Sequence(this.children);

  @override
  BehaviorStatus tick(Blackboard blackboard) {
    while (_currentIndex < children.length) {
      final status = children[_currentIndex].tick(blackboard);
      if (status == BehaviorStatus.running) return BehaviorStatus.running;
      if (status == BehaviorStatus.failure) {
        reset();
        return BehaviorStatus.failure;
      }
      _currentIndex++;
    }
    reset();
    return BehaviorStatus.success;
  }

  @override
  void reset() {
    _currentIndex = 0;
    for (final child in children) {
      child.reset();
    }
  }
}

/// Executes child nodes in order until one succeeds.
///
/// A Selector node represents an OR relationship between its children.
/// Only one child needs to succeed for the Selector to succeed.
class Selector extends BehaviorNode {
  /// List of child nodes to try in order
  final List<BehaviorNode> children;

  Selector(this.children);

  @override
  BehaviorStatus tick(Blackboard blackboard) {
    for (final child in children) {
      final status = child.tick(blackboard);
      if (status == BehaviorStatus.running || status == BehaviorStatus.success) {
        _resetLowerPriorityNodes(child);
        return status;
      }
    }
    return BehaviorStatus.failure;
  }

  /// Resets all nodes with lower priority than the currently active node.
  ///
  /// This ensures that when execution returns to this selector,
  /// lower priority nodes start from a clean state.
  void _resetLowerPriorityNodes(BehaviorNode activeNode) {
    final idx = children.indexOf(activeNode);
    for (var i = idx + 1; i < children.length; i++) {
      children[i].reset();
    }
  }

  @override
  void reset() {
    for (final child in children) {
      child.reset();
    }
  }
}

// ==========================
// Decorator Nodes
// ==========================

/// Decorates a single child node by inverting its result.
///
/// This node is useful for creating logical NOT operations in the behavior tree.
class Inverter extends BehaviorNode {
  /// The child node whose result will be inverted
  final BehaviorNode child;

  Inverter(this.child);

  @override
  BehaviorStatus tick(Blackboard blackboard) {
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
class Repeater extends BehaviorNode {
  /// The child node to repeat
  final BehaviorNode child;

  /// Number of times to repeat the child node
  final int repeatCount;

  /// Current repetition count
  int _currentCount = 0;

  Repeater(this.child, this.repeatCount);

  @override
  BehaviorStatus tick(Blackboard blackboard) {
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
class Guard extends BehaviorNode {
  /// The condition to check
  final ConditionFunc condition;

  /// The child node to execute if condition is true
  final BehaviorNode child;

  Guard(this.condition, this.child);

  @override
  BehaviorStatus tick(Blackboard blackboard) {
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
class Timeout extends BehaviorNode {
  /// The child node to execute with a time limit
  final BehaviorNode child;

  /// Maximum execution time in milliseconds
  final int timeoutMs;

  /// When execution started
  DateTime? _startTime;

  Timeout(this.child, this.timeoutMs);

  @override
  BehaviorStatus tick(Blackboard blackboard) {
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

// ==========================
// Composite Nodes
// ==========================

/// Executes all child nodes in parallel.
///
/// A Parallel node can be configured with different policies for success/failure.
/// Child nodes do not _execute_ in parallel. They execute sequentially in the order
/// they are given.
class Parallel extends BehaviorNode {
  /// List of child nodes to execute in parallel
  final List<BehaviorNode> children;

  /// If true, requires all children to succeed for this node to succeed.
  /// If false, requires only one child to succeed.
  final bool requireAllSuccess;

  /// If true, fails if all children fail.
  /// If false, fails if any child fails.
  final bool requireAllFailure;

  Parallel(this.children, {this.requireAllSuccess = true, this.requireAllFailure = false});

  @override
  BehaviorStatus tick(Blackboard blackboard) {
    int successCount = 0;
    int failureCount = 0;

    for (final child in children) {
      final status = child.tick(blackboard);

      if (status == BehaviorStatus.success) {
        successCount++;
        if (!requireAllSuccess && successCount > 0) {
          return BehaviorStatus.success;
        }
      } else if (status == BehaviorStatus.failure) {
        failureCount++;
        if (!requireAllFailure && failureCount > 0) {
          return BehaviorStatus.failure;
        }
      }
    }

    if (requireAllSuccess && successCount == children.length) {
      return BehaviorStatus.success;
    }

    if (requireAllFailure && failureCount == children.length) {
      return BehaviorStatus.failure;
    }

    return BehaviorStatus.running;
  }

  @override
  void reset() {
    for (final child in children) {
      child.reset();
    }
  }
}

/// Executes a randomly selected child node.
class RandomSelector extends BehaviorNode {
  /// List of child nodes to choose from
  final List<BehaviorNode> children;

  /// Currently selected child index
  int? _selectedIndex;

  /// Random number generator
  final Random _random = Random();

  RandomSelector(this.children);

  @override
  BehaviorStatus tick(Blackboard blackboard) {
    _selectedIndex ??= _random.nextInt(children.length);

    final status = children[_selectedIndex!].tick(blackboard);
    if (status != BehaviorStatus.running) {
      reset();
    }
    return status;
  }

  @override
  void reset() {
    _selectedIndex = null;
    for (final child in children) {
      child.reset();
    }
  }
}

// ==========================
// Leaf Nodes
// ==========================

/// Function type for condition evaluations that return a boolean
typedef ConditionFunc = bool Function(Blackboard);

/// Function type for actions that return a [BehaviorStatus]
typedef ActionFunc = BehaviorStatus Function(Blackboard);

/// Leaf node that evaluates a boolean condition.
///
/// This node doesn't perform any actions but simply checks a condition.
class ConditionNode extends BehaviorNode {
  /// Function that evaluates the condition
  final ConditionFunc condition;

  ConditionNode(this.condition);

  @override
  BehaviorStatus tick(Blackboard blackboard) {
    return condition(blackboard) ? BehaviorStatus.success : BehaviorStatus.failure;
  }

  @override
  void reset() {}
}

/// Leaf node that executes an action function.
///
/// This node performs the actual work in the behavior tree.
class ActionNode extends BehaviorNode {
  /// Function that performs the action
  final ActionFunc action;

  ActionNode(this.action);

  @override
  BehaviorStatus tick(Blackboard blackboard) => action(blackboard);

  @override
  void reset() {}
}

/// Container class for managing a behavior tree.
///
/// Provides methods for executing the tree and accessing the blackboard.
class BehaviorTree {
  /// Root node of the behavior tree
  final BehaviorNode root;

  /// Shared data storage for the tree
  final Blackboard blackboard;

  /// Creates a new behavior tree with the specified [root] node.
  ///
  /// If [blackboard] is not provided, a new empty blackboard will be created.
  BehaviorTree(this.root, {Blackboard? blackboard})
      : blackboard = blackboard ?? Blackboard();

  /// Executes one tick of the behavior tree.
  ///
  /// Returns the status of the root node after execution.
  BehaviorStatus tick() {
    return root.tick(blackboard);
  }

  /// Resets the entire tree to its initial state.
  void reset() {
    root.reset();
  }
}