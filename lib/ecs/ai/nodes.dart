// @MappableLib(generateInitializerForScope: InitializerScope.package, discriminatorKey: "__type")
import 'package:dart_mappable/dart_mappable.dart';

import 'package:meta/meta.dart' show mustCallSuper;
import 'package:rogueverse/ecs/entity.dart';

part 'nodes.mapper.dart';

/// Status returned by behavior tree nodes after execution.
enum BehaviorStatus {
  /// Node completed its task successfully
  success,

  /// Node failed to complete its task
  failure,

  /// Node is still executing and needs more time
  running
}

/// Function type for condition evaluations that return a boolean
typedef ConditionFunc = bool Function(Entity);

/// Function type for actions that return a [BehaviorStatus]
typedef ActionFunc = BehaviorStatus Function(Entity);

/// Base abstract class for all behavior tree nodes.
///
/// All nodes in a behavior tree must implement this interface.
@MappableClass()
abstract class Node with NodeMappable {
  /// Executes the node's logic using the provided [blackboard].
  ///
  /// Returns a [BehaviorStatus] indicating the result of execution.
  BehaviorStatus tick(Entity blackboard);

  /// Resets the node to its initial state.
  ///
  /// This should be called when a node needs to be re-executed from scratch.
  @mustCallSuper
  void reset();
}