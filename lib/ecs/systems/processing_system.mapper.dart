// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'processing_system.dart';

class ProcessingSystemMapper extends SubClassMapperBase<ProcessingSystem> {
  ProcessingSystemMapper._();

  static ProcessingSystemMapper? _instance;
  static ProcessingSystemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ProcessingSystemMapper._());
      SystemMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'ProcessingSystem';

  @override
  final MappableFields<ProcessingSystem> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'ProcessingSystem';
  @override
  late final ClassMapperBase superMapper = SystemMapper.ensureInitialized();

  static ProcessingSystem _instantiate(DecodingData data) {
    return ProcessingSystem();
  }

  @override
  final Function instantiate = _instantiate;

  static ProcessingSystem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ProcessingSystem>(map);
  }

  static ProcessingSystem fromJson(String json) {
    return ensureInitialized().decodeJson<ProcessingSystem>(json);
  }
}

mixin ProcessingSystemMappable {
  String toJson() {
    return ProcessingSystemMapper.ensureInitialized()
        .encodeJson<ProcessingSystem>(this as ProcessingSystem);
  }

  Map<String, dynamic> toMap() {
    return ProcessingSystemMapper.ensureInitialized()
        .encodeMap<ProcessingSystem>(this as ProcessingSystem);
  }

  ProcessingSystemCopyWith<ProcessingSystem, ProcessingSystem, ProcessingSystem>
  get copyWith =>
      _ProcessingSystemCopyWithImpl<ProcessingSystem, ProcessingSystem>(
        this as ProcessingSystem,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ProcessingSystemMapper.ensureInitialized().stringifyValue(
      this as ProcessingSystem,
    );
  }

  @override
  bool operator ==(Object other) {
    return ProcessingSystemMapper.ensureInitialized().equalsValue(
      this as ProcessingSystem,
      other,
    );
  }

  @override
  int get hashCode {
    return ProcessingSystemMapper.ensureInitialized().hashValue(
      this as ProcessingSystem,
    );
  }
}

extension ProcessingSystemValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ProcessingSystem, $Out> {
  ProcessingSystemCopyWith<$R, ProcessingSystem, $Out>
  get $asProcessingSystem =>
      $base.as((v, t, t2) => _ProcessingSystemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ProcessingSystemCopyWith<$R, $In extends ProcessingSystem, $Out>
    implements SystemCopyWith<$R, $In, $Out> {
  @override
  $R call();
  ProcessingSystemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ProcessingSystemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ProcessingSystem, $Out>
    implements ProcessingSystemCopyWith<$R, ProcessingSystem, $Out> {
  _ProcessingSystemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ProcessingSystem> $mapper =
      ProcessingSystemMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  ProcessingSystem $make(CopyWithData data) => ProcessingSystem();

  @override
  ProcessingSystemCopyWith<$R2, ProcessingSystem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ProcessingSystemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

