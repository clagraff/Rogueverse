// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'control_system.dart';

class ControlSystemMapper extends SubClassMapperBase<ControlSystem> {
  ControlSystemMapper._();

  static ControlSystemMapper? _instance;
  static ControlSystemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ControlSystemMapper._());
      SystemMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'ControlSystem';

  @override
  final MappableFields<ControlSystem> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'ControlSystem';
  @override
  late final ClassMapperBase superMapper = SystemMapper.ensureInitialized();

  static ControlSystem _instantiate(DecodingData data) {
    return ControlSystem();
  }

  @override
  final Function instantiate = _instantiate;

  static ControlSystem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ControlSystem>(map);
  }

  static ControlSystem fromJson(String json) {
    return ensureInitialized().decodeJson<ControlSystem>(json);
  }
}

mixin ControlSystemMappable {
  String toJson() {
    return ControlSystemMapper.ensureInitialized().encodeJson<ControlSystem>(
      this as ControlSystem,
    );
  }

  Map<String, dynamic> toMap() {
    return ControlSystemMapper.ensureInitialized().encodeMap<ControlSystem>(
      this as ControlSystem,
    );
  }

  ControlSystemCopyWith<ControlSystem, ControlSystem, ControlSystem>
  get copyWith => _ControlSystemCopyWithImpl<ControlSystem, ControlSystem>(
    this as ControlSystem,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return ControlSystemMapper.ensureInitialized().stringifyValue(
      this as ControlSystem,
    );
  }

  @override
  bool operator ==(Object other) {
    return ControlSystemMapper.ensureInitialized().equalsValue(
      this as ControlSystem,
      other,
    );
  }

  @override
  int get hashCode {
    return ControlSystemMapper.ensureInitialized().hashValue(
      this as ControlSystem,
    );
  }
}

extension ControlSystemValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ControlSystem, $Out> {
  ControlSystemCopyWith<$R, ControlSystem, $Out> get $asControlSystem =>
      $base.as((v, t, t2) => _ControlSystemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ControlSystemCopyWith<$R, $In extends ControlSystem, $Out>
    implements SystemCopyWith<$R, $In, $Out> {
  @override
  $R call();
  ControlSystemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ControlSystemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ControlSystem, $Out>
    implements ControlSystemCopyWith<$R, ControlSystem, $Out> {
  _ControlSystemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ControlSystem> $mapper =
      ControlSystemMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  ControlSystem $make(CopyWithData data) => ControlSystem();

  @override
  ControlSystemCopyWith<$R2, ControlSystem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ControlSystemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

