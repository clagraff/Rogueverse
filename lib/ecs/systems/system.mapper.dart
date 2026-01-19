// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'system.dart';

class SystemMapper extends ClassMapperBase<System> {
  SystemMapper._();

  static SystemMapper? _instance;
  static SystemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SystemMapper._());
      BudgetedSystemMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'System';

  @override
  final MappableFields<System> fields = const {};

  static System _instantiate(DecodingData data) {
    throw MapperException.missingSubclass(
      'System',
      '__type',
      '${data.value['__type']}',
    );
  }

  @override
  final Function instantiate = _instantiate;

  static System fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<System>(map);
  }

  static System fromJson(String json) {
    return ensureInitialized().decodeJson<System>(json);
  }
}

mixin SystemMappable {
  String toJson();
  Map<String, dynamic> toMap();
  SystemCopyWith<System, System, System> get copyWith;
}

abstract class SystemCopyWith<$R, $In extends System, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  SystemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class BudgetedSystemMapper extends SubClassMapperBase<BudgetedSystem> {
  BudgetedSystemMapper._();

  static BudgetedSystemMapper? _instance;
  static BudgetedSystemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = BudgetedSystemMapper._());
      SystemMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'BudgetedSystem';

  @override
  final MappableFields<BudgetedSystem> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'BudgetedSystem';
  @override
  late final ClassMapperBase superMapper = SystemMapper.ensureInitialized();

  static BudgetedSystem _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('BudgetedSystem');
  }

  @override
  final Function instantiate = _instantiate;

  static BudgetedSystem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<BudgetedSystem>(map);
  }

  static BudgetedSystem fromJson(String json) {
    return ensureInitialized().decodeJson<BudgetedSystem>(json);
  }
}

mixin BudgetedSystemMappable {
  String toJson();
  Map<String, dynamic> toMap();
  BudgetedSystemCopyWith<BudgetedSystem, BudgetedSystem, BudgetedSystem>
  get copyWith;
}

abstract class BudgetedSystemCopyWith<$R, $In extends BudgetedSystem, $Out>
    implements SystemCopyWith<$R, $In, $Out> {
  @override
  $R call();
  BudgetedSystemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

