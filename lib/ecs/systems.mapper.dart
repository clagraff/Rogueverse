// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'systems.dart';

class SystemMapper extends ClassMapperBase<System> {
  SystemMapper._();

  static SystemMapper? _instance;
  static SystemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SystemMapper._());
      BudgetedSystemMapper.ensureInitialized();
      HierarchySystemMapper.ensureInitialized();
      CollisionSystemMapper.ensureInitialized();
      MovementSystemMapper.ensureInitialized();
      InventorySystemMapper.ensureInitialized();
      CombatSystemMapper.ensureInitialized();
      ControlSystemMapper.ensureInitialized();
      OpenableSystemMapper.ensureInitialized();
      PortalSystemMapper.ensureInitialized();
      SaveSystemMapper.ensureInitialized();
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
      BehaviorSystemMapper.ensureInitialized();
      VisionSystemMapper.ensureInitialized();
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
    throw MapperException.missingSubclass(
      'BudgetedSystem',
      '__type',
      '${data.value['__type']}',
    );
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

class HierarchySystemMapper extends SubClassMapperBase<HierarchySystem> {
  HierarchySystemMapper._();

  static HierarchySystemMapper? _instance;
  static HierarchySystemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = HierarchySystemMapper._());
      SystemMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'HierarchySystem';

  @override
  final MappableFields<HierarchySystem> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'HierarchySystem';
  @override
  late final ClassMapperBase superMapper = SystemMapper.ensureInitialized();

  static HierarchySystem _instantiate(DecodingData data) {
    return HierarchySystem();
  }

  @override
  final Function instantiate = _instantiate;

  static HierarchySystem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<HierarchySystem>(map);
  }

  static HierarchySystem fromJson(String json) {
    return ensureInitialized().decodeJson<HierarchySystem>(json);
  }
}

mixin HierarchySystemMappable {
  String toJson() {
    return HierarchySystemMapper.ensureInitialized()
        .encodeJson<HierarchySystem>(this as HierarchySystem);
  }

  Map<String, dynamic> toMap() {
    return HierarchySystemMapper.ensureInitialized().encodeMap<HierarchySystem>(
      this as HierarchySystem,
    );
  }

  HierarchySystemCopyWith<HierarchySystem, HierarchySystem, HierarchySystem>
  get copyWith =>
      _HierarchySystemCopyWithImpl<HierarchySystem, HierarchySystem>(
        this as HierarchySystem,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return HierarchySystemMapper.ensureInitialized().stringifyValue(
      this as HierarchySystem,
    );
  }

  @override
  bool operator ==(Object other) {
    return HierarchySystemMapper.ensureInitialized().equalsValue(
      this as HierarchySystem,
      other,
    );
  }

  @override
  int get hashCode {
    return HierarchySystemMapper.ensureInitialized().hashValue(
      this as HierarchySystem,
    );
  }
}

extension HierarchySystemValueCopy<$R, $Out>
    on ObjectCopyWith<$R, HierarchySystem, $Out> {
  HierarchySystemCopyWith<$R, HierarchySystem, $Out> get $asHierarchySystem =>
      $base.as((v, t, t2) => _HierarchySystemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class HierarchySystemCopyWith<$R, $In extends HierarchySystem, $Out>
    implements SystemCopyWith<$R, $In, $Out> {
  @override
  $R call();
  HierarchySystemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _HierarchySystemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, HierarchySystem, $Out>
    implements HierarchySystemCopyWith<$R, HierarchySystem, $Out> {
  _HierarchySystemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<HierarchySystem> $mapper =
      HierarchySystemMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  HierarchySystem $make(CopyWithData data) => HierarchySystem();

  @override
  HierarchySystemCopyWith<$R2, HierarchySystem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _HierarchySystemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

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

class CombatSystemMapper extends SubClassMapperBase<CombatSystem> {
  CombatSystemMapper._();

  static CombatSystemMapper? _instance;
  static CombatSystemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CombatSystemMapper._());
      SystemMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'CombatSystem';

  @override
  final MappableFields<CombatSystem> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'CombatSystem';
  @override
  late final ClassMapperBase superMapper = SystemMapper.ensureInitialized();

  static CombatSystem _instantiate(DecodingData data) {
    return CombatSystem();
  }

  @override
  final Function instantiate = _instantiate;

  static CombatSystem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CombatSystem>(map);
  }

  static CombatSystem fromJson(String json) {
    return ensureInitialized().decodeJson<CombatSystem>(json);
  }
}

mixin CombatSystemMappable {
  String toJson() {
    return CombatSystemMapper.ensureInitialized().encodeJson<CombatSystem>(
      this as CombatSystem,
    );
  }

  Map<String, dynamic> toMap() {
    return CombatSystemMapper.ensureInitialized().encodeMap<CombatSystem>(
      this as CombatSystem,
    );
  }

  CombatSystemCopyWith<CombatSystem, CombatSystem, CombatSystem> get copyWith =>
      _CombatSystemCopyWithImpl<CombatSystem, CombatSystem>(
        this as CombatSystem,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CombatSystemMapper.ensureInitialized().stringifyValue(
      this as CombatSystem,
    );
  }

  @override
  bool operator ==(Object other) {
    return CombatSystemMapper.ensureInitialized().equalsValue(
      this as CombatSystem,
      other,
    );
  }

  @override
  int get hashCode {
    return CombatSystemMapper.ensureInitialized().hashValue(
      this as CombatSystem,
    );
  }
}

extension CombatSystemValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CombatSystem, $Out> {
  CombatSystemCopyWith<$R, CombatSystem, $Out> get $asCombatSystem =>
      $base.as((v, t, t2) => _CombatSystemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CombatSystemCopyWith<$R, $In extends CombatSystem, $Out>
    implements SystemCopyWith<$R, $In, $Out> {
  @override
  $R call();
  CombatSystemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CombatSystemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CombatSystem, $Out>
    implements CombatSystemCopyWith<$R, CombatSystem, $Out> {
  _CombatSystemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CombatSystem> $mapper =
      CombatSystemMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  CombatSystem $make(CopyWithData data) => CombatSystem();

  @override
  CombatSystemCopyWith<$R2, CombatSystem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CombatSystemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

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

class VisionSystemMapper extends SubClassMapperBase<VisionSystem> {
  VisionSystemMapper._();

  static VisionSystemMapper? _instance;
  static VisionSystemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = VisionSystemMapper._());
      BudgetedSystemMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'VisionSystem';

  static Queue<Entity> _$queue(VisionSystem v) => v.queue;
  static const Field<VisionSystem, Queue<Entity>> _f$queue = Field(
    'queue',
    _$queue,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<VisionSystem> fields = const {#queue: _f$queue};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'VisionSystem';
  @override
  late final ClassMapperBase superMapper =
      BudgetedSystemMapper.ensureInitialized();

  static VisionSystem _instantiate(DecodingData data) {
    return VisionSystem();
  }

  @override
  final Function instantiate = _instantiate;

  static VisionSystem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<VisionSystem>(map);
  }

  static VisionSystem fromJson(String json) {
    return ensureInitialized().decodeJson<VisionSystem>(json);
  }
}

mixin VisionSystemMappable {
  String toJson() {
    return VisionSystemMapper.ensureInitialized().encodeJson<VisionSystem>(
      this as VisionSystem,
    );
  }

  Map<String, dynamic> toMap() {
    return VisionSystemMapper.ensureInitialized().encodeMap<VisionSystem>(
      this as VisionSystem,
    );
  }

  VisionSystemCopyWith<VisionSystem, VisionSystem, VisionSystem> get copyWith =>
      _VisionSystemCopyWithImpl<VisionSystem, VisionSystem>(
        this as VisionSystem,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return VisionSystemMapper.ensureInitialized().stringifyValue(
      this as VisionSystem,
    );
  }

  @override
  bool operator ==(Object other) {
    return VisionSystemMapper.ensureInitialized().equalsValue(
      this as VisionSystem,
      other,
    );
  }

  @override
  int get hashCode {
    return VisionSystemMapper.ensureInitialized().hashValue(
      this as VisionSystem,
    );
  }
}

extension VisionSystemValueCopy<$R, $Out>
    on ObjectCopyWith<$R, VisionSystem, $Out> {
  VisionSystemCopyWith<$R, VisionSystem, $Out> get $asVisionSystem =>
      $base.as((v, t, t2) => _VisionSystemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class VisionSystemCopyWith<$R, $In extends VisionSystem, $Out>
    implements BudgetedSystemCopyWith<$R, $In, $Out> {
  @override
  $R call();
  VisionSystemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _VisionSystemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, VisionSystem, $Out>
    implements VisionSystemCopyWith<$R, VisionSystem, $Out> {
  _VisionSystemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<VisionSystem> $mapper =
      VisionSystemMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  VisionSystem $make(CopyWithData data) => VisionSystem();

  @override
  VisionSystemCopyWith<$R2, VisionSystem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _VisionSystemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ControlSystemMapper extends SubClassMapperBase<ControlSystem> {
  ControlSystemMapper._();

  static ControlSystemMapper? _instance;
  static ControlSystemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ControlSystemMapper._());
      SystemMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'ControlSystem';

  @override
  final MappableFields<ControlSystem> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'ControlSystem';
  @override
  late final ClassMapperBase superMapper = SystemMapper.ensureInitialized();

  static ControlSystem _instantiate(DecodingData data) {
    return ControlSystem();
  }

  @override
  final Function instantiate = _instantiate;

  static ControlSystem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ControlSystem>(map);
  }

  static ControlSystem fromJson(String json) {
    return ensureInitialized().decodeJson<ControlSystem>(json);
  }
}

mixin ControlSystemMappable {
  String toJson() {
    return ControlSystemMapper.ensureInitialized().encodeJson<ControlSystem>(
      this as ControlSystem,
    );
  }

  Map<String, dynamic> toMap() {
    return ControlSystemMapper.ensureInitialized().encodeMap<ControlSystem>(
      this as ControlSystem,
    );
  }

  ControlSystemCopyWith<ControlSystem, ControlSystem, ControlSystem>
  get copyWith => _ControlSystemCopyWithImpl<ControlSystem, ControlSystem>(
    this as ControlSystem,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return ControlSystemMapper.ensureInitialized().stringifyValue(
      this as ControlSystem,
    );
  }

  @override
  bool operator ==(Object other) {
    return ControlSystemMapper.ensureInitialized().equalsValue(
      this as ControlSystem,
      other,
    );
  }

  @override
  int get hashCode {
    return ControlSystemMapper.ensureInitialized().hashValue(
      this as ControlSystem,
    );
  }
}

extension ControlSystemValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ControlSystem, $Out> {
  ControlSystemCopyWith<$R, ControlSystem, $Out> get $asControlSystem =>
      $base.as((v, t, t2) => _ControlSystemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ControlSystemCopyWith<$R, $In extends ControlSystem, $Out>
    implements SystemCopyWith<$R, $In, $Out> {
  @override
  $R call();
  ControlSystemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ControlSystemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ControlSystem, $Out>
    implements ControlSystemCopyWith<$R, ControlSystem, $Out> {
  _ControlSystemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ControlSystem> $mapper =
      ControlSystemMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  ControlSystem $make(CopyWithData data) => ControlSystem();

  @override
  ControlSystemCopyWith<$R2, ControlSystem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ControlSystemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

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

class PortalSystemMapper extends SubClassMapperBase<PortalSystem> {
  PortalSystemMapper._();

  static PortalSystemMapper? _instance;
  static PortalSystemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PortalSystemMapper._());
      SystemMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'PortalSystem';

  @override
  final MappableFields<PortalSystem> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'PortalSystem';
  @override
  late final ClassMapperBase superMapper = SystemMapper.ensureInitialized();

  static PortalSystem _instantiate(DecodingData data) {
    return PortalSystem();
  }

  @override
  final Function instantiate = _instantiate;

  static PortalSystem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PortalSystem>(map);
  }

  static PortalSystem fromJson(String json) {
    return ensureInitialized().decodeJson<PortalSystem>(json);
  }
}

mixin PortalSystemMappable {
  String toJson() {
    return PortalSystemMapper.ensureInitialized().encodeJson<PortalSystem>(
      this as PortalSystem,
    );
  }

  Map<String, dynamic> toMap() {
    return PortalSystemMapper.ensureInitialized().encodeMap<PortalSystem>(
      this as PortalSystem,
    );
  }

  PortalSystemCopyWith<PortalSystem, PortalSystem, PortalSystem> get copyWith =>
      _PortalSystemCopyWithImpl<PortalSystem, PortalSystem>(
        this as PortalSystem,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PortalSystemMapper.ensureInitialized().stringifyValue(
      this as PortalSystem,
    );
  }

  @override
  bool operator ==(Object other) {
    return PortalSystemMapper.ensureInitialized().equalsValue(
      this as PortalSystem,
      other,
    );
  }

  @override
  int get hashCode {
    return PortalSystemMapper.ensureInitialized().hashValue(
      this as PortalSystem,
    );
  }
}

extension PortalSystemValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PortalSystem, $Out> {
  PortalSystemCopyWith<$R, PortalSystem, $Out> get $asPortalSystem =>
      $base.as((v, t, t2) => _PortalSystemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PortalSystemCopyWith<$R, $In extends PortalSystem, $Out>
    implements SystemCopyWith<$R, $In, $Out> {
  @override
  $R call();
  PortalSystemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PortalSystemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PortalSystem, $Out>
    implements PortalSystemCopyWith<$R, PortalSystem, $Out> {
  _PortalSystemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PortalSystem> $mapper =
      PortalSystemMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  PortalSystem $make(CopyWithData data) => PortalSystem();

  @override
  PortalSystemCopyWith<$R2, PortalSystem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PortalSystemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

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

