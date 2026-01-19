// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'save_system.dart';

class SaveSystemMapper extends SubClassMapperBase<SaveSystem> {
  SaveSystemMapper._();

  static SaveSystemMapper? _instance;
  static SaveSystemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SaveSystemMapper._());
      SystemMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'SaveSystem';

  @override
  final MappableFields<SaveSystem> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'SaveSystem';
  @override
  late final ClassMapperBase superMapper = SystemMapper.ensureInitialized();

  static SaveSystem _instantiate(DecodingData data) {
    return SaveSystem();
  }

  @override
  final Function instantiate = _instantiate;

  static SaveSystem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SaveSystem>(map);
  }

  static SaveSystem fromJson(String json) {
    return ensureInitialized().decodeJson<SaveSystem>(json);
  }
}

mixin SaveSystemMappable {
  String toJson() {
    return SaveSystemMapper.ensureInitialized().encodeJson<SaveSystem>(
      this as SaveSystem,
    );
  }

  Map<String, dynamic> toMap() {
    return SaveSystemMapper.ensureInitialized().encodeMap<SaveSystem>(
      this as SaveSystem,
    );
  }

  SaveSystemCopyWith<SaveSystem, SaveSystem, SaveSystem> get copyWith =>
      _SaveSystemCopyWithImpl<SaveSystem, SaveSystem>(
        this as SaveSystem,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return SaveSystemMapper.ensureInitialized().stringifyValue(
      this as SaveSystem,
    );
  }

  @override
  bool operator ==(Object other) {
    return SaveSystemMapper.ensureInitialized().equalsValue(
      this as SaveSystem,
      other,
    );
  }

  @override
  int get hashCode {
    return SaveSystemMapper.ensureInitialized().hashValue(this as SaveSystem);
  }
}

extension SaveSystemValueCopy<$R, $Out>
    on ObjectCopyWith<$R, SaveSystem, $Out> {
  SaveSystemCopyWith<$R, SaveSystem, $Out> get $asSaveSystem =>
      $base.as((v, t, t2) => _SaveSystemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class SaveSystemCopyWith<$R, $In extends SaveSystem, $Out>
    implements SystemCopyWith<$R, $In, $Out> {
  @override
  $R call();
  SaveSystemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _SaveSystemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SaveSystem, $Out>
    implements SaveSystemCopyWith<$R, SaveSystem, $Out> {
  _SaveSystemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SaveSystem> $mapper =
      SaveSystemMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  SaveSystem $make(CopyWithData data) => SaveSystem();

  @override
  SaveSystemCopyWith<$R2, SaveSystem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _SaveSystemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

