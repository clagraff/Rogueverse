// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'vision_system.dart';

class VisionSystemMapper extends SubClassMapperBase<VisionSystem> {
  VisionSystemMapper._();

  static VisionSystemMapper? _instance;
  static VisionSystemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = VisionSystemMapper._());
      BudgetedSystemMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'VisionSystem';

  static Queue<Entity> _$queue(VisionSystem v) => v.queue;
  static const Field<VisionSystem, Queue<Entity>> _f$queue = Field(
    'queue',
    _$queue,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<VisionSystem> fields = const {#queue: _f$queue};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'VisionSystem';
  @override
  late final ClassMapperBase superMapper =
      BudgetedSystemMapper.ensureInitialized();

  static VisionSystem _instantiate(DecodingData data) {
    return VisionSystem();
  }

  @override
  final Function instantiate = _instantiate;

  static VisionSystem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<VisionSystem>(map);
  }

  static VisionSystem fromJson(String json) {
    return ensureInitialized().decodeJson<VisionSystem>(json);
  }
}

mixin VisionSystemMappable {
  String toJson() {
    return VisionSystemMapper.ensureInitialized().encodeJson<VisionSystem>(
      this as VisionSystem,
    );
  }

  Map<String, dynamic> toMap() {
    return VisionSystemMapper.ensureInitialized().encodeMap<VisionSystem>(
      this as VisionSystem,
    );
  }

  VisionSystemCopyWith<VisionSystem, VisionSystem, VisionSystem> get copyWith =>
      _VisionSystemCopyWithImpl<VisionSystem, VisionSystem>(
        this as VisionSystem,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return VisionSystemMapper.ensureInitialized().stringifyValue(
      this as VisionSystem,
    );
  }

  @override
  bool operator ==(Object other) {
    return VisionSystemMapper.ensureInitialized().equalsValue(
      this as VisionSystem,
      other,
    );
  }

  @override
  int get hashCode {
    return VisionSystemMapper.ensureInitialized().hashValue(
      this as VisionSystem,
    );
  }
}

extension VisionSystemValueCopy<$R, $Out>
    on ObjectCopyWith<$R, VisionSystem, $Out> {
  VisionSystemCopyWith<$R, VisionSystem, $Out> get $asVisionSystem =>
      $base.as((v, t, t2) => _VisionSystemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class VisionSystemCopyWith<$R, $In extends VisionSystem, $Out>
    implements BudgetedSystemCopyWith<$R, $In, $Out> {
  @override
  $R call();
  VisionSystemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _VisionSystemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, VisionSystem, $Out>
    implements VisionSystemCopyWith<$R, VisionSystem, $Out> {
  _VisionSystemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<VisionSystem> $mapper =
      VisionSystemMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  VisionSystem $make(CopyWithData data) => VisionSystem();

  @override
  VisionSystemCopyWith<$R2, VisionSystem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _VisionSystemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

