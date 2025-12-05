// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'behaviors.dart';

class MoveRandomlyNodeMapper extends SubClassMapperBase<MoveRandomlyNode> {
  MoveRandomlyNodeMapper._();

  static MoveRandomlyNodeMapper? _instance;
  static MoveRandomlyNodeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MoveRandomlyNodeMapper._());
      NodeMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'MoveRandomlyNode';

  static Random _$random(MoveRandomlyNode v) => v.random;
  static const Field<MoveRandomlyNode, Random> _f$random = Field(
    'random',
    _$random,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<MoveRandomlyNode> fields = const {#random: _f$random};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'MoveRandomlyNode';
  @override
  late final ClassMapperBase superMapper = NodeMapper.ensureInitialized();

  static MoveRandomlyNode _instantiate(DecodingData data) {
    return MoveRandomlyNode();
  }

  @override
  final Function instantiate = _instantiate;

  static MoveRandomlyNode fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MoveRandomlyNode>(map);
  }

  static MoveRandomlyNode fromJson(String json) {
    return ensureInitialized().decodeJson<MoveRandomlyNode>(json);
  }
}

mixin MoveRandomlyNodeMappable {
  String toJson() {
    return MoveRandomlyNodeMapper.ensureInitialized()
        .encodeJson<MoveRandomlyNode>(this as MoveRandomlyNode);
  }

  Map<String, dynamic> toMap() {
    return MoveRandomlyNodeMapper.ensureInitialized()
        .encodeMap<MoveRandomlyNode>(this as MoveRandomlyNode);
  }

  MoveRandomlyNodeCopyWith<MoveRandomlyNode, MoveRandomlyNode, MoveRandomlyNode>
  get copyWith =>
      _MoveRandomlyNodeCopyWithImpl<MoveRandomlyNode, MoveRandomlyNode>(
        this as MoveRandomlyNode,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MoveRandomlyNodeMapper.ensureInitialized().stringifyValue(
      this as MoveRandomlyNode,
    );
  }

  @override
  bool operator ==(Object other) {
    return MoveRandomlyNodeMapper.ensureInitialized().equalsValue(
      this as MoveRandomlyNode,
      other,
    );
  }

  @override
  int get hashCode {
    return MoveRandomlyNodeMapper.ensureInitialized().hashValue(
      this as MoveRandomlyNode,
    );
  }
}

extension MoveRandomlyNodeValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MoveRandomlyNode, $Out> {
  MoveRandomlyNodeCopyWith<$R, MoveRandomlyNode, $Out>
  get $asMoveRandomlyNode =>
      $base.as((v, t, t2) => _MoveRandomlyNodeCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MoveRandomlyNodeCopyWith<$R, $In extends MoveRandomlyNode, $Out>
    implements NodeCopyWith<$R, $In, $Out> {
  @override
  $R call();
  MoveRandomlyNodeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _MoveRandomlyNodeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MoveRandomlyNode, $Out>
    implements MoveRandomlyNodeCopyWith<$R, MoveRandomlyNode, $Out> {
  _MoveRandomlyNodeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MoveRandomlyNode> $mapper =
      MoveRandomlyNodeMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  MoveRandomlyNode $make(CopyWithData data) => MoveRandomlyNode();

  @override
  MoveRandomlyNodeCopyWith<$R2, MoveRandomlyNode, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MoveRandomlyNodeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

