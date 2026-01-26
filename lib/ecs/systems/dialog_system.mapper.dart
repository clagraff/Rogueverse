// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'dialog_system.dart';

class DialogSystemMapper extends SubClassMapperBase<DialogSystem> {
  DialogSystemMapper._();

  static DialogSystemMapper? _instance;
  static DialogSystemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DialogSystemMapper._());
      SystemMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'DialogSystem';

  @override
  final MappableFields<DialogSystem> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'DialogSystem';
  @override
  late final ClassMapperBase superMapper = SystemMapper.ensureInitialized();

  static DialogSystem _instantiate(DecodingData data) {
    return DialogSystem();
  }

  @override
  final Function instantiate = _instantiate;

  static DialogSystem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DialogSystem>(map);
  }

  static DialogSystem fromJson(String json) {
    return ensureInitialized().decodeJson<DialogSystem>(json);
  }
}

mixin DialogSystemMappable {
  String toJson() {
    return DialogSystemMapper.ensureInitialized().encodeJson<DialogSystem>(
      this as DialogSystem,
    );
  }

  Map<String, dynamic> toMap() {
    return DialogSystemMapper.ensureInitialized().encodeMap<DialogSystem>(
      this as DialogSystem,
    );
  }

  DialogSystemCopyWith<DialogSystem, DialogSystem, DialogSystem> get copyWith =>
      _DialogSystemCopyWithImpl<DialogSystem, DialogSystem>(
        this as DialogSystem,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DialogSystemMapper.ensureInitialized().stringifyValue(
      this as DialogSystem,
    );
  }

  @override
  bool operator ==(Object other) {
    return DialogSystemMapper.ensureInitialized().equalsValue(
      this as DialogSystem,
      other,
    );
  }

  @override
  int get hashCode {
    return DialogSystemMapper.ensureInitialized().hashValue(
      this as DialogSystem,
    );
  }
}

extension DialogSystemValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DialogSystem, $Out> {
  DialogSystemCopyWith<$R, DialogSystem, $Out> get $asDialogSystem =>
      $base.as((v, t, t2) => _DialogSystemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DialogSystemCopyWith<$R, $In extends DialogSystem, $Out>
    implements SystemCopyWith<$R, $In, $Out> {
  @override
  $R call();
  DialogSystemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DialogSystemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DialogSystem, $Out>
    implements DialogSystemCopyWith<$R, DialogSystem, $Out> {
  _DialogSystemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DialogSystem> $mapper =
      DialogSystemMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  DialogSystem $make(CopyWithData data) => DialogSystem();

  @override
  DialogSystemCopyWith<$R2, DialogSystem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DialogSystemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

