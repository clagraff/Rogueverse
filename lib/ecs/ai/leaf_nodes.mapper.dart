// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'leaf_nodes.dart';

class ConditionNodeMapper extends SubClassMapperBase<ConditionNode> {
  ConditionNodeMapper._();

  static ConditionNodeMapper? _instance;
  static ConditionNodeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ConditionNodeMapper._());
      NodeMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'ConditionNode';

  static Function _$condition(ConditionNode v) =>
      (v as dynamic).condition as Function;
  static dynamic _arg$condition(f) => f<bool Function(Entity)>();
  static const Field<ConditionNode, Function> _f$condition = Field(
    'condition',
    _$condition,
    mode: FieldMode.member,
    arg: _arg$condition,
  );

  @override
  final MappableFields<ConditionNode> fields = const {#condition: _f$condition};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'ConditionNode';
  @override
  late final ClassMapperBase superMapper = NodeMapper.ensureInitialized();

  static ConditionNode _instantiate(DecodingData data) {
    return ConditionNode.noop();
  }

  @override
  final Function instantiate = _instantiate;

  static ConditionNode fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ConditionNode>(map);
  }

  static ConditionNode fromJson(String json) {
    return ensureInitialized().decodeJson<ConditionNode>(json);
  }
}

mixin ConditionNodeMappable {
  String toJson() {
    return ConditionNodeMapper.ensureInitialized().encodeJson<ConditionNode>(
      this as ConditionNode,
    );
  }

  Map<String, dynamic> toMap() {
    return ConditionNodeMapper.ensureInitialized().encodeMap<ConditionNode>(
      this as ConditionNode,
    );
  }

  ConditionNodeCopyWith<ConditionNode, ConditionNode, ConditionNode>
  get copyWith => _ConditionNodeCopyWithImpl<ConditionNode, ConditionNode>(
    this as ConditionNode,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return ConditionNodeMapper.ensureInitialized().stringifyValue(
      this as ConditionNode,
    );
  }

  @override
  bool operator ==(Object other) {
    return ConditionNodeMapper.ensureInitialized().equalsValue(
      this as ConditionNode,
      other,
    );
  }

  @override
  int get hashCode {
    return ConditionNodeMapper.ensureInitialized().hashValue(
      this as ConditionNode,
    );
  }
}

extension ConditionNodeValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ConditionNode, $Out> {
  ConditionNodeCopyWith<$R, ConditionNode, $Out> get $asConditionNode =>
      $base.as((v, t, t2) => _ConditionNodeCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ConditionNodeCopyWith<$R, $In extends ConditionNode, $Out>
    implements NodeCopyWith<$R, $In, $Out> {
  @override
  $R call();
  ConditionNodeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ConditionNodeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ConditionNode, $Out>
    implements ConditionNodeCopyWith<$R, ConditionNode, $Out> {
  _ConditionNodeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ConditionNode> $mapper =
      ConditionNodeMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  ConditionNode $make(CopyWithData data) => ConditionNode.noop();

  @override
  ConditionNodeCopyWith<$R2, ConditionNode, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ConditionNodeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ActionNodeMapper extends SubClassMapperBase<ActionNode> {
  ActionNodeMapper._();

  static ActionNodeMapper? _instance;
  static ActionNodeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ActionNodeMapper._());
      NodeMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'ActionNode';

  static Function _$action(ActionNode v) => (v as dynamic).action as Function;
  static dynamic _arg$action(f) => f<BehaviorStatus Function(Entity)>();
  static const Field<ActionNode, Function> _f$action = Field(
    'action',
    _$action,
    arg: _arg$action,
  );

  @override
  final MappableFields<ActionNode> fields = const {#action: _f$action};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'ActionNode';
  @override
  late final ClassMapperBase superMapper = NodeMapper.ensureInitialized();

  static ActionNode _instantiate(DecodingData data) {
    return ActionNode(data.dec(_f$action));
  }

  @override
  final Function instantiate = _instantiate;

  static ActionNode fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ActionNode>(map);
  }

  static ActionNode fromJson(String json) {
    return ensureInitialized().decodeJson<ActionNode>(json);
  }
}

mixin ActionNodeMappable {
  String toJson() {
    return ActionNodeMapper.ensureInitialized().encodeJson<ActionNode>(
      this as ActionNode,
    );
  }

  Map<String, dynamic> toMap() {
    return ActionNodeMapper.ensureInitialized().encodeMap<ActionNode>(
      this as ActionNode,
    );
  }

  ActionNodeCopyWith<ActionNode, ActionNode, ActionNode> get copyWith =>
      _ActionNodeCopyWithImpl<ActionNode, ActionNode>(
        this as ActionNode,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ActionNodeMapper.ensureInitialized().stringifyValue(
      this as ActionNode,
    );
  }

  @override
  bool operator ==(Object other) {
    return ActionNodeMapper.ensureInitialized().equalsValue(
      this as ActionNode,
      other,
    );
  }

  @override
  int get hashCode {
    return ActionNodeMapper.ensureInitialized().hashValue(this as ActionNode);
  }
}

extension ActionNodeValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ActionNode, $Out> {
  ActionNodeCopyWith<$R, ActionNode, $Out> get $asActionNode =>
      $base.as((v, t, t2) => _ActionNodeCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ActionNodeCopyWith<$R, $In extends ActionNode, $Out>
    implements NodeCopyWith<$R, $In, $Out> {
  @override
  $R call({BehaviorStatus Function(Entity)? action});
  ActionNodeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ActionNodeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ActionNode, $Out>
    implements ActionNodeCopyWith<$R, ActionNode, $Out> {
  _ActionNodeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ActionNode> $mapper =
      ActionNodeMapper.ensureInitialized();
  @override
  $R call({BehaviorStatus Function(Entity)? action}) =>
      $apply(FieldCopyWithData({if (action != null) #action: action}));
  @override
  ActionNode $make(CopyWithData data) =>
      ActionNode(data.get(#action, or: $value.action));

  @override
  ActionNodeCopyWith<$R2, ActionNode, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ActionNodeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

