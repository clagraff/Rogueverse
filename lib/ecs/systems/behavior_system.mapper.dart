// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'behavior_system.dart';

class BehaviorSystemMapper extends SubClassMapperBase<BehaviorSystem> {
  BehaviorSystemMapper._();

  static BehaviorSystemMapper? _instance;
  static BehaviorSystemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = BehaviorSystemMapper._());
      BudgetedSystemMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'BehaviorSystem';

  static Queue<(Entity, Behavior)> _$queue(BehaviorSystem v) => v.queue;
  static const Field<BehaviorSystem, Queue<(Entity, Behavior)>> _f$queue =
      Field('queue', _$queue, mode: FieldMode.member);

  @override
  final MappableFields<BehaviorSystem> fields = const {#queue: _f$queue};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'BehaviorSystem';
  @override
  late final ClassMapperBase superMapper =
      BudgetedSystemMapper.ensureInitialized();

  static BehaviorSystem _instantiate(DecodingData data) {
    return BehaviorSystem();
  }

  @override
  final Function instantiate = _instantiate;

  static BehaviorSystem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<BehaviorSystem>(map);
  }

  static BehaviorSystem fromJson(String json) {
    return ensureInitialized().decodeJson<BehaviorSystem>(json);
  }
}

mixin BehaviorSystemMappable {
  String toJson() {
    return BehaviorSystemMapper.ensureInitialized().encodeJson<BehaviorSystem>(
      this as BehaviorSystem,
    );
  }

  Map<String, dynamic> toMap() {
    return BehaviorSystemMapper.ensureInitialized().encodeMap<BehaviorSystem>(
      this as BehaviorSystem,
    );
  }

  BehaviorSystemCopyWith<BehaviorSystem, BehaviorSystem, BehaviorSystem>
  get copyWith => _BehaviorSystemCopyWithImpl<BehaviorSystem, BehaviorSystem>(
    this as BehaviorSystem,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return BehaviorSystemMapper.ensureInitialized().stringifyValue(
      this as BehaviorSystem,
    );
  }

  @override
  bool operator ==(Object other) {
    return BehaviorSystemMapper.ensureInitialized().equalsValue(
      this as BehaviorSystem,
      other,
    );
  }

  @override
  int get hashCode {
    return BehaviorSystemMapper.ensureInitialized().hashValue(
      this as BehaviorSystem,
    );
  }
}

extension BehaviorSystemValueCopy<$R, $Out>
    on ObjectCopyWith<$R, BehaviorSystem, $Out> {
  BehaviorSystemCopyWith<$R, BehaviorSystem, $Out> get $asBehaviorSystem =>
      $base.as((v, t, t2) => _BehaviorSystemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class BehaviorSystemCopyWith<$R, $In extends BehaviorSystem, $Out>
    implements BudgetedSystemCopyWith<$R, $In, $Out> {
  @override
  $R call();
  BehaviorSystemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _BehaviorSystemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, BehaviorSystem, $Out>
    implements BehaviorSystemCopyWith<$R, BehaviorSystem, $Out> {
  _BehaviorSystemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<BehaviorSystem> $mapper =
      BehaviorSystemMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  BehaviorSystem $make(CopyWithData data) => BehaviorSystem();

  @override
  BehaviorSystemCopyWith<$R2, BehaviorSystem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _BehaviorSystemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

