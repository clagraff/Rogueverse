// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'crafting_system.dart';

class CraftingSystemMapper extends SubClassMapperBase<CraftingSystem> {
  CraftingSystemMapper._();

  static CraftingSystemMapper? _instance;
  static CraftingSystemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CraftingSystemMapper._());
      SystemMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'CraftingSystem';

  @override
  final MappableFields<CraftingSystem> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'CraftingSystem';
  @override
  late final ClassMapperBase superMapper = SystemMapper.ensureInitialized();

  static CraftingSystem _instantiate(DecodingData data) {
    return CraftingSystem();
  }

  @override
  final Function instantiate = _instantiate;

  static CraftingSystem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CraftingSystem>(map);
  }

  static CraftingSystem fromJson(String json) {
    return ensureInitialized().decodeJson<CraftingSystem>(json);
  }
}

mixin CraftingSystemMappable {
  String toJson() {
    return CraftingSystemMapper.ensureInitialized().encodeJson<CraftingSystem>(
      this as CraftingSystem,
    );
  }

  Map<String, dynamic> toMap() {
    return CraftingSystemMapper.ensureInitialized().encodeMap<CraftingSystem>(
      this as CraftingSystem,
    );
  }

  CraftingSystemCopyWith<CraftingSystem, CraftingSystem, CraftingSystem>
  get copyWith => _CraftingSystemCopyWithImpl<CraftingSystem, CraftingSystem>(
    this as CraftingSystem,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return CraftingSystemMapper.ensureInitialized().stringifyValue(
      this as CraftingSystem,
    );
  }

  @override
  bool operator ==(Object other) {
    return CraftingSystemMapper.ensureInitialized().equalsValue(
      this as CraftingSystem,
      other,
    );
  }

  @override
  int get hashCode {
    return CraftingSystemMapper.ensureInitialized().hashValue(
      this as CraftingSystem,
    );
  }
}

extension CraftingSystemValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CraftingSystem, $Out> {
  CraftingSystemCopyWith<$R, CraftingSystem, $Out> get $asCraftingSystem =>
      $base.as((v, t, t2) => _CraftingSystemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CraftingSystemCopyWith<$R, $In extends CraftingSystem, $Out>
    implements SystemCopyWith<$R, $In, $Out> {
  @override
  $R call();
  CraftingSystemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CraftingSystemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CraftingSystem, $Out>
    implements CraftingSystemCopyWith<$R, CraftingSystem, $Out> {
  _CraftingSystemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CraftingSystem> $mapper =
      CraftingSystemMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  CraftingSystem $make(CopyWithData data) => CraftingSystem();

  @override
  CraftingSystemCopyWith<$R2, CraftingSystem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CraftingSystemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

