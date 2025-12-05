
import 'dart:math';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:rogueverse/ecs/ai/nodes.dart';
import 'package:rogueverse/ecs/entity.dart';

part 'composite_nodes.mapper.dart';

/// Executes child nodes in order until one succeeds.
///
/// A Selector node represents an OR relationship between its children.
/// Only one child needs to succeed for the Selector to succeed.
@MappableClass()
class Selector extends Node with SelectorMappable {
  /// List of child nodes to try in order
  final List<Node> children;

  Selector(this.children);

  @override
  BehaviorStatus tick(Entity entity) {
    for (final child in children) {
      final status = child.tick(entity);
      if (status == BehaviorStatus.running ||
          status == BehaviorStatus.success) {
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
  void _resetLowerPriorityNodes(Node activeNode) {
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


/// Executes all child nodes in parallel.
///
/// A Parallel node can be configured with different policies for success/failure.
/// Child nodes do not _execute_ in parallel. They execute sequentially in the order
/// they are given.
@MappableClass()
class Parallel extends Node with ParallelMappable {
  /// List of child nodes to execute in parallel
  final List<Node> children;

  /// If true, requires all children to succeed for this node to succeed.
  /// If false, requires only one child to succeed.
  final bool requireAllSuccess;

  /// If true, fails if all children fail.
  /// If false, fails if any child fails.
  final bool requireAllFailure;

  Parallel(this.children,
      {this.requireAllSuccess = true, this.requireAllFailure = false});

  @override
  BehaviorStatus tick(Entity entity) {
    int successCount = 0;
    int failureCount = 0;

    for (final child in children) {
      final status = child.tick(entity);

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
@MappableClass()
class RandomSelector extends Node with RandomSelectorMappable {
  /// List of child nodes to choose from
  final List<Node> children;

  /// Currently selected child index
  int? _selectedIndex;

  /// Random number generator
  final Random _random = Random();

  RandomSelector(this.children);

  @override
  BehaviorStatus tick(Entity entity) {
    _selectedIndex ??= _random.nextInt(children.length);

    final status = children[_selectedIndex!].tick(entity);
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
