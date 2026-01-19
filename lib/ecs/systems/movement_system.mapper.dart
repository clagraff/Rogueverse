// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'movement_system.dart';

class MovementSystemMapper extends SubClassMapperBase<MovementSystem> {
  MovementSystemMapper._();

  static MovementSystemMapper? _instance;
  static MovementSystemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MovementSystemMapper._());
      SystemMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'MovementSystem';

  @override
  final MappableFields<MovementSystem> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'MovementSystem';
  @override
  late final ClassMapperBase superMapper = SystemMapper.ensureInitialized();

  static MovementSystem _instantiate(DecodingData data) {
    return MovementSystem();
  }

  @override
  final Function instantiate = _instantiate;

  static MovementSystem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MovementSystem>(map);
  }

  static MovementSystem fromJson(String json) {
    return ensureInitialized().decodeJson<MovementSystem>(json);
  }
}

mixin MovementSystemMappable {
  String toJson() {
    return MovementSystemMapper.ensureInitialized().encodeJson<MovementSystem>(
      this as MovementSystem,
    );
  }

  Map<String, dynamic> toMap() {
    return MovementSystemMapper.ensureInitialized().encodeMap<MovementSystem>(
      this as MovementSystem,
    );
  }

  MovementSystemCopyWith<MovementSystem, MovementSystem, MovementSystem>
  get copyWith => _MovementSystemCopyWithImpl<MovementSystem, MovementSystem>(
    this as MovementSystem,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return MovementSystemMapper.ensureInitialized().stringifyValue(
      this as MovementSystem,
    );
  }

  @override
  bool operator ==(Object other) {
    return MovementSystemMapper.ensureInitialized().equalsValue(
      this as MovementSystem,
      other,
    );
  }

  @override
  int get hashCode {
    return MovementSystemMapper.ensureInitialized().hashValue(
      this as MovementSystem,
    );
  }
}

extension MovementSystemValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MovementSystem, $Out> {
  MovementSystemCopyWith<$R, MovementSystem, $Out> get $asMovementSystem =>
      $base.as((v, t, t2) => _MovementSystemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MovementSystemCopyWith<$R, $In extends MovementSystem, $Out>
    implements SystemCopyWith<$R, $In, $Out> {
  @override
  $R call();
  MovementSystemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _MovementSystemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MovementSystem, $Out>
    implements MovementSystemCopyWith<$R, MovementSystem, $Out> {
  _MovementSystemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MovementSystem> $mapper =
      MovementSystemMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  MovementSystem $make(CopyWithData data) => MovementSystem();

  @override
  MovementSystemCopyWith<$R2, MovementSystem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MovementSystemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

