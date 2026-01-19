// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'direction_system.dart';

class DirectionSystemMapper extends SubClassMapperBase<DirectionSystem> {
  DirectionSystemMapper._();

  static DirectionSystemMapper? _instance;
  static DirectionSystemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DirectionSystemMapper._());
      SystemMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'DirectionSystem';

  @override
  final MappableFields<DirectionSystem> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'DirectionSystem';
  @override
  late final ClassMapperBase superMapper = SystemMapper.ensureInitialized();

  static DirectionSystem _instantiate(DecodingData data) {
    return DirectionSystem();
  }

  @override
  final Function instantiate = _instantiate;

  static DirectionSystem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DirectionSystem>(map);
  }

  static DirectionSystem fromJson(String json) {
    return ensureInitialized().decodeJson<DirectionSystem>(json);
  }
}

mixin DirectionSystemMappable {
  String toJson() {
    return DirectionSystemMapper.ensureInitialized()
        .encodeJson<DirectionSystem>(this as DirectionSystem);
  }

  Map<String, dynamic> toMap() {
    return DirectionSystemMapper.ensureInitialized().encodeMap<DirectionSystem>(
      this as DirectionSystem,
    );
  }

  DirectionSystemCopyWith<DirectionSystem, DirectionSystem, DirectionSystem>
  get copyWith =>
      _DirectionSystemCopyWithImpl<DirectionSystem, DirectionSystem>(
        this as DirectionSystem,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DirectionSystemMapper.ensureInitialized().stringifyValue(
      this as DirectionSystem,
    );
  }

  @override
  bool operator ==(Object other) {
    return DirectionSystemMapper.ensureInitialized().equalsValue(
      this as DirectionSystem,
      other,
    );
  }

  @override
  int get hashCode {
    return DirectionSystemMapper.ensureInitialized().hashValue(
      this as DirectionSystem,
    );
  }
}

extension DirectionSystemValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DirectionSystem, $Out> {
  DirectionSystemCopyWith<$R, DirectionSystem, $Out> get $asDirectionSystem =>
      $base.as((v, t, t2) => _DirectionSystemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DirectionSystemCopyWith<$R, $In extends DirectionSystem, $Out>
    implements SystemCopyWith<$R, $In, $Out> {
  @override
  $R call();
  DirectionSystemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _DirectionSystemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DirectionSystem, $Out>
    implements DirectionSystemCopyWith<$R, DirectionSystem, $Out> {
  _DirectionSystemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DirectionSystem> $mapper =
      DirectionSystemMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  DirectionSystem $make(CopyWithData data) => DirectionSystem();

  @override
  DirectionSystemCopyWith<$R2, DirectionSystem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DirectionSystemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

