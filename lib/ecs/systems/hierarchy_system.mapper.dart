// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'hierarchy_system.dart';

class HierarchySystemMapper extends SubClassMapperBase<HierarchySystem> {
  HierarchySystemMapper._();

  static HierarchySystemMapper? _instance;
  static HierarchySystemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = HierarchySystemMapper._());
      SystemMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'HierarchySystem';

  @override
  final MappableFields<HierarchySystem> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'HierarchySystem';
  @override
  late final ClassMapperBase superMapper = SystemMapper.ensureInitialized();

  static HierarchySystem _instantiate(DecodingData data) {
    return HierarchySystem();
  }

  @override
  final Function instantiate = _instantiate;

  static HierarchySystem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<HierarchySystem>(map);
  }

  static HierarchySystem fromJson(String json) {
    return ensureInitialized().decodeJson<HierarchySystem>(json);
  }
}

mixin HierarchySystemMappable {
  String toJson() {
    return HierarchySystemMapper.ensureInitialized()
        .encodeJson<HierarchySystem>(this as HierarchySystem);
  }

  Map<String, dynamic> toMap() {
    return HierarchySystemMapper.ensureInitialized().encodeMap<HierarchySystem>(
      this as HierarchySystem,
    );
  }

  HierarchySystemCopyWith<HierarchySystem, HierarchySystem, HierarchySystem>
  get copyWith =>
      _HierarchySystemCopyWithImpl<HierarchySystem, HierarchySystem>(
        this as HierarchySystem,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return HierarchySystemMapper.ensureInitialized().stringifyValue(
      this as HierarchySystem,
    );
  }

  @override
  bool operator ==(Object other) {
    return HierarchySystemMapper.ensureInitialized().equalsValue(
      this as HierarchySystem,
      other,
    );
  }

  @override
  int get hashCode {
    return HierarchySystemMapper.ensureInitialized().hashValue(
      this as HierarchySystem,
    );
  }
}

extension HierarchySystemValueCopy<$R, $Out>
    on ObjectCopyWith<$R, HierarchySystem, $Out> {
  HierarchySystemCopyWith<$R, HierarchySystem, $Out> get $asHierarchySystem =>
      $base.as((v, t, t2) => _HierarchySystemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class HierarchySystemCopyWith<$R, $In extends HierarchySystem, $Out>
    implements SystemCopyWith<$R, $In, $Out> {
  @override
  $R call();
  HierarchySystemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _HierarchySystemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, HierarchySystem, $Out>
    implements HierarchySystemCopyWith<$R, HierarchySystem, $Out> {
  _HierarchySystemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<HierarchySystem> $mapper =
      HierarchySystemMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  HierarchySystem $make(CopyWithData data) => HierarchySystem();

  @override
  HierarchySystemCopyWith<$R2, HierarchySystem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _HierarchySystemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

