// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'combat_system.dart';

class CombatSystemMapper extends SubClassMapperBase<CombatSystem> {
  CombatSystemMapper._();

  static CombatSystemMapper? _instance;
  static CombatSystemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CombatSystemMapper._());
      SystemMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'CombatSystem';

  @override
  final MappableFields<CombatSystem> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'CombatSystem';
  @override
  late final ClassMapperBase superMapper = SystemMapper.ensureInitialized();

  static CombatSystem _instantiate(DecodingData data) {
    return CombatSystem();
  }

  @override
  final Function instantiate = _instantiate;

  static CombatSystem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CombatSystem>(map);
  }

  static CombatSystem fromJson(String json) {
    return ensureInitialized().decodeJson<CombatSystem>(json);
  }
}

mixin CombatSystemMappable {
  String toJson() {
    return CombatSystemMapper.ensureInitialized().encodeJson<CombatSystem>(
      this as CombatSystem,
    );
  }

  Map<String, dynamic> toMap() {
    return CombatSystemMapper.ensureInitialized().encodeMap<CombatSystem>(
      this as CombatSystem,
    );
  }

  CombatSystemCopyWith<CombatSystem, CombatSystem, CombatSystem> get copyWith =>
      _CombatSystemCopyWithImpl<CombatSystem, CombatSystem>(
        this as CombatSystem,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CombatSystemMapper.ensureInitialized().stringifyValue(
      this as CombatSystem,
    );
  }

  @override
  bool operator ==(Object other) {
    return CombatSystemMapper.ensureInitialized().equalsValue(
      this as CombatSystem,
      other,
    );
  }

  @override
  int get hashCode {
    return CombatSystemMapper.ensureInitialized().hashValue(
      this as CombatSystem,
    );
  }
}

extension CombatSystemValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CombatSystem, $Out> {
  CombatSystemCopyWith<$R, CombatSystem, $Out> get $asCombatSystem =>
      $base.as((v, t, t2) => _CombatSystemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CombatSystemCopyWith<$R, $In extends CombatSystem, $Out>
    implements SystemCopyWith<$R, $In, $Out> {
  @override
  $R call();
  CombatSystemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CombatSystemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CombatSystem, $Out>
    implements CombatSystemCopyWith<$R, CombatSystem, $Out> {
  _CombatSystemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CombatSystem> $mapper =
      CombatSystemMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  CombatSystem $make(CopyWithData data) => CombatSystem();

  @override
  CombatSystemCopyWith<$R2, CombatSystem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CombatSystemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

