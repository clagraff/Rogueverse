// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'portal_system.dart';

class PortalSystemMapper extends SubClassMapperBase<PortalSystem> {
  PortalSystemMapper._();

  static PortalSystemMapper? _instance;
  static PortalSystemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PortalSystemMapper._());
      SystemMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'PortalSystem';

  @override
  final MappableFields<PortalSystem> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'PortalSystem';
  @override
  late final ClassMapperBase superMapper = SystemMapper.ensureInitialized();

  static PortalSystem _instantiate(DecodingData data) {
    return PortalSystem();
  }

  @override
  final Function instantiate = _instantiate;

  static PortalSystem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PortalSystem>(map);
  }

  static PortalSystem fromJson(String json) {
    return ensureInitialized().decodeJson<PortalSystem>(json);
  }
}

mixin PortalSystemMappable {
  String toJson() {
    return PortalSystemMapper.ensureInitialized().encodeJson<PortalSystem>(
      this as PortalSystem,
    );
  }

  Map<String, dynamic> toMap() {
    return PortalSystemMapper.ensureInitialized().encodeMap<PortalSystem>(
      this as PortalSystem,
    );
  }

  PortalSystemCopyWith<PortalSystem, PortalSystem, PortalSystem> get copyWith =>
      _PortalSystemCopyWithImpl<PortalSystem, PortalSystem>(
        this as PortalSystem,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PortalSystemMapper.ensureInitialized().stringifyValue(
      this as PortalSystem,
    );
  }

  @override
  bool operator ==(Object other) {
    return PortalSystemMapper.ensureInitialized().equalsValue(
      this as PortalSystem,
      other,
    );
  }

  @override
  int get hashCode {
    return PortalSystemMapper.ensureInitialized().hashValue(
      this as PortalSystem,
    );
  }
}

extension PortalSystemValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PortalSystem, $Out> {
  PortalSystemCopyWith<$R, PortalSystem, $Out> get $asPortalSystem =>
      $base.as((v, t, t2) => _PortalSystemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PortalSystemCopyWith<$R, $In extends PortalSystem, $Out>
    implements SystemCopyWith<$R, $In, $Out> {
  @override
  $R call();
  PortalSystemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PortalSystemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PortalSystem, $Out>
    implements PortalSystemCopyWith<$R, PortalSystem, $Out> {
  _PortalSystemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PortalSystem> $mapper =
      PortalSystemMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  PortalSystem $make(CopyWithData data) => PortalSystem();

  @override
  PortalSystemCopyWith<$R2, PortalSystem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PortalSystemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

