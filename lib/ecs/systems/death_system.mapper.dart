// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'death_system.dart';

class DeathSystemMapper extends SubClassMapperBase<DeathSystem> {
  DeathSystemMapper._();

  static DeathSystemMapper? _instance;
  static DeathSystemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DeathSystemMapper._());
      SystemMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'DeathSystem';

  @override
  final MappableFields<DeathSystem> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'DeathSystem';
  @override
  late final ClassMapperBase superMapper = SystemMapper.ensureInitialized();

  static DeathSystem _instantiate(DecodingData data) {
    return DeathSystem();
  }

  @override
  final Function instantiate = _instantiate;

  static DeathSystem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DeathSystem>(map);
  }

  static DeathSystem fromJson(String json) {
    return ensureInitialized().decodeJson<DeathSystem>(json);
  }
}

mixin DeathSystemMappable {
  String toJson() {
    return DeathSystemMapper.ensureInitialized().encodeJson<DeathSystem>(
      this as DeathSystem,
    );
  }

  Map<String, dynamic> toMap() {
    return DeathSystemMapper.ensureInitialized().encodeMap<DeathSystem>(
      this as DeathSystem,
    );
  }

  DeathSystemCopyWith<DeathSystem, DeathSystem, DeathSystem> get copyWith =>
      _DeathSystemCopyWithImpl<DeathSystem, DeathSystem>(
        this as DeathSystem,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DeathSystemMapper.ensureInitialized().stringifyValue(
      this as DeathSystem,
    );
  }

  @override
  bool operator ==(Object other) {
    return DeathSystemMapper.ensureInitialized().equalsValue(
      this as DeathSystem,
      other,
    );
  }

  @override
  int get hashCode {
    return DeathSystemMapper.ensureInitialized().hashValue(this as DeathSystem);
  }
}

extension DeathSystemValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DeathSystem, $Out> {
  DeathSystemCopyWith<$R, DeathSystem, $Out> get $asDeathSystem =>
      $base.as((v, t, t2) => _DeathSystemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DeathSystemCopyWith<$R, $In extends DeathSystem, $Out>
    implements SystemCopyWith<$R, $In, $Out> {
  @override
  $R call();
  DeathSystemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DeathSystemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DeathSystem, $Out>
    implements DeathSystemCopyWith<$R, DeathSystem, $Out> {
  _DeathSystemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DeathSystem> $mapper =
      DeathSystemMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  DeathSystem $make(CopyWithData data) => DeathSystem();

  @override
  DeathSystemCopyWith<$R2, DeathSystem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DeathSystemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

