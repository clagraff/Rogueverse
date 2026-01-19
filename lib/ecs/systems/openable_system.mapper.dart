// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'openable_system.dart';

class OpenableSystemMapper extends SubClassMapperBase<OpenableSystem> {
  OpenableSystemMapper._();

  static OpenableSystemMapper? _instance;
  static OpenableSystemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OpenableSystemMapper._());
      SystemMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'OpenableSystem';

  @override
  final MappableFields<OpenableSystem> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'OpenableSystem';
  @override
  late final ClassMapperBase superMapper = SystemMapper.ensureInitialized();

  static OpenableSystem _instantiate(DecodingData data) {
    return OpenableSystem();
  }

  @override
  final Function instantiate = _instantiate;

  static OpenableSystem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OpenableSystem>(map);
  }

  static OpenableSystem fromJson(String json) {
    return ensureInitialized().decodeJson<OpenableSystem>(json);
  }
}

mixin OpenableSystemMappable {
  String toJson() {
    return OpenableSystemMapper.ensureInitialized().encodeJson<OpenableSystem>(
      this as OpenableSystem,
    );
  }

  Map<String, dynamic> toMap() {
    return OpenableSystemMapper.ensureInitialized().encodeMap<OpenableSystem>(
      this as OpenableSystem,
    );
  }

  OpenableSystemCopyWith<OpenableSystem, OpenableSystem, OpenableSystem>
  get copyWith => _OpenableSystemCopyWithImpl<OpenableSystem, OpenableSystem>(
    this as OpenableSystem,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return OpenableSystemMapper.ensureInitialized().stringifyValue(
      this as OpenableSystem,
    );
  }

  @override
  bool operator ==(Object other) {
    return OpenableSystemMapper.ensureInitialized().equalsValue(
      this as OpenableSystem,
      other,
    );
  }

  @override
  int get hashCode {
    return OpenableSystemMapper.ensureInitialized().hashValue(
      this as OpenableSystem,
    );
  }
}

extension OpenableSystemValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OpenableSystem, $Out> {
  OpenableSystemCopyWith<$R, OpenableSystem, $Out> get $asOpenableSystem =>
      $base.as((v, t, t2) => _OpenableSystemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class OpenableSystemCopyWith<$R, $In extends OpenableSystem, $Out>
    implements SystemCopyWith<$R, $In, $Out> {
  @override
  $R call();
  OpenableSystemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _OpenableSystemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OpenableSystem, $Out>
    implements OpenableSystemCopyWith<$R, OpenableSystem, $Out> {
  _OpenableSystemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OpenableSystem> $mapper =
      OpenableSystemMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  OpenableSystem $make(CopyWithData data) => OpenableSystem();

  @override
  OpenableSystemCopyWith<$R2, OpenableSystem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _OpenableSystemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

