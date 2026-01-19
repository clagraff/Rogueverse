// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'collision_system.dart';

class CollisionSystemMapper extends SubClassMapperBase<CollisionSystem> {
  CollisionSystemMapper._();

  static CollisionSystemMapper? _instance;
  static CollisionSystemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CollisionSystemMapper._());
      SystemMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'CollisionSystem';

  @override
  final MappableFields<CollisionSystem> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'CollisionSystem';
  @override
  late final ClassMapperBase superMapper = SystemMapper.ensureInitialized();

  static CollisionSystem _instantiate(DecodingData data) {
    return CollisionSystem();
  }

  @override
  final Function instantiate = _instantiate;

  static CollisionSystem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CollisionSystem>(map);
  }

  static CollisionSystem fromJson(String json) {
    return ensureInitialized().decodeJson<CollisionSystem>(json);
  }
}

mixin CollisionSystemMappable {
  String toJson() {
    return CollisionSystemMapper.ensureInitialized()
        .encodeJson<CollisionSystem>(this as CollisionSystem);
  }

  Map<String, dynamic> toMap() {
    return CollisionSystemMapper.ensureInitialized().encodeMap<CollisionSystem>(
      this as CollisionSystem,
    );
  }

  CollisionSystemCopyWith<CollisionSystem, CollisionSystem, CollisionSystem>
  get copyWith =>
      _CollisionSystemCopyWithImpl<CollisionSystem, CollisionSystem>(
        this as CollisionSystem,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CollisionSystemMapper.ensureInitialized().stringifyValue(
      this as CollisionSystem,
    );
  }

  @override
  bool operator ==(Object other) {
    return CollisionSystemMapper.ensureInitialized().equalsValue(
      this as CollisionSystem,
      other,
    );
  }

  @override
  int get hashCode {
    return CollisionSystemMapper.ensureInitialized().hashValue(
      this as CollisionSystem,
    );
  }
}

extension CollisionSystemValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CollisionSystem, $Out> {
  CollisionSystemCopyWith<$R, CollisionSystem, $Out> get $asCollisionSystem =>
      $base.as((v, t, t2) => _CollisionSystemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CollisionSystemCopyWith<$R, $In extends CollisionSystem, $Out>
    implements SystemCopyWith<$R, $In, $Out> {
  @override
  $R call();
  CollisionSystemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CollisionSystemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CollisionSystem, $Out>
    implements CollisionSystemCopyWith<$R, CollisionSystem, $Out> {
  _CollisionSystemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CollisionSystem> $mapper =
      CollisionSystemMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  CollisionSystem $make(CopyWithData data) => CollisionSystem();

  @override
  CollisionSystemCopyWith<$R2, CollisionSystem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CollisionSystemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

