// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'inventory_system.dart';

class InventorySystemMapper extends SubClassMapperBase<InventorySystem> {
  InventorySystemMapper._();

  static InventorySystemMapper? _instance;
  static InventorySystemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = InventorySystemMapper._());
      SystemMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'InventorySystem';

  static Query _$canPickup(InventorySystem v) => v.canPickup;
  static const Field<InventorySystem, Query> _f$canPickup = Field(
    'canPickup',
    _$canPickup,
    mode: FieldMode.member,
  );
  static Query _$canBePickedUp(InventorySystem v) => v.canBePickedUp;
  static const Field<InventorySystem, Query> _f$canBePickedUp = Field(
    'canBePickedUp',
    _$canBePickedUp,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<InventorySystem> fields = const {
    #canPickup: _f$canPickup,
    #canBePickedUp: _f$canBePickedUp,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'InventorySystem';
  @override
  late final ClassMapperBase superMapper = SystemMapper.ensureInitialized();

  static InventorySystem _instantiate(DecodingData data) {
    return InventorySystem();
  }

  @override
  final Function instantiate = _instantiate;

  static InventorySystem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<InventorySystem>(map);
  }

  static InventorySystem fromJson(String json) {
    return ensureInitialized().decodeJson<InventorySystem>(json);
  }
}

mixin InventorySystemMappable {
  String toJson() {
    return InventorySystemMapper.ensureInitialized()
        .encodeJson<InventorySystem>(this as InventorySystem);
  }

  Map<String, dynamic> toMap() {
    return InventorySystemMapper.ensureInitialized().encodeMap<InventorySystem>(
      this as InventorySystem,
    );
  }

  InventorySystemCopyWith<InventorySystem, InventorySystem, InventorySystem>
  get copyWith =>
      _InventorySystemCopyWithImpl<InventorySystem, InventorySystem>(
        this as InventorySystem,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return InventorySystemMapper.ensureInitialized().stringifyValue(
      this as InventorySystem,
    );
  }

  @override
  bool operator ==(Object other) {
    return InventorySystemMapper.ensureInitialized().equalsValue(
      this as InventorySystem,
      other,
    );
  }

  @override
  int get hashCode {
    return InventorySystemMapper.ensureInitialized().hashValue(
      this as InventorySystem,
    );
  }
}

extension InventorySystemValueCopy<$R, $Out>
    on ObjectCopyWith<$R, InventorySystem, $Out> {
  InventorySystemCopyWith<$R, InventorySystem, $Out> get $asInventorySystem =>
      $base.as((v, t, t2) => _InventorySystemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class InventorySystemCopyWith<$R, $In extends InventorySystem, $Out>
    implements SystemCopyWith<$R, $In, $Out> {
  @override
  $R call();
  InventorySystemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _InventorySystemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, InventorySystem, $Out>
    implements InventorySystemCopyWith<$R, InventorySystem, $Out> {
  _InventorySystemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<InventorySystem> $mapper =
      InventorySystemMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  InventorySystem $make(CopyWithData data) => InventorySystem();

  @override
  InventorySystemCopyWith<$R2, InventorySystem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _InventorySystemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

