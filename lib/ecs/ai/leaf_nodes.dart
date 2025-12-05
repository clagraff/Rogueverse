
import 'package:dart_mappable/dart_mappable.dart';
import 'package:rogueverse/ecs/ai/nodes.dart';
import 'package:rogueverse/ecs/entity.dart';

part 'leaf_nodes.mapper.dart';

/// Leaf node that evaluates a boolean condition.
///
/// This node doesn't perform any actions but simply checks a condition.
@MappableClass()
class ConditionNode extends Node with ConditionNodeMappable {
  /// Function that evaluates the condition
  final ConditionFunc condition;

  @MappableConstructor()
  ConditionNode.noop() : this((E) =>true);

  ConditionNode(this.condition);

  @override
  BehaviorStatus tick(Entity entity) {
    return condition(entity)
        ? BehaviorStatus.success
        : BehaviorStatus.failure;
  }

  @override
  void reset() {}
}

/// Leaf node that executes an action function.
///
/// This node performs the actual work in the behavior tree.
@MappableClass()
class ActionNode extends Node with ActionNodeMappable {
  /// Function that performs the action
  final ActionFunc action;

  ActionNode(this.action);


  @override
  BehaviorStatus tick(Entity entity) => action(entity);

  @override
  void reset() {}
}