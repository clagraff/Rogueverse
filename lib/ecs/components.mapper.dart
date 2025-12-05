// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'components.dart';

class ComponentMapper extends ClassMapperBase<Component> {
  ComponentMapper._();

  static ComponentMapper? _instance;
  static ComponentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ComponentMapper._());
      LifetimeMapper.ensureInitialized();
      BeforeTickMapper.ensureInitialized();
      AfterTickMapper.ensureInitialized();
      CellMapper.ensureInitialized();
      NameMapper.ensureInitialized();
      LocalPositionMapper.ensureInitialized();
      MoveByIntentMapper.ensureInitialized();
      DidMoveMapper.ensureInitialized();
      BlocksMovementMapper.ensureInitialized();
      BlockedMoveMapper.ensureInitialized();
      PlayerControlledMapper.ensureInitialized();
      AiControlledMapper.ensureInitialized();
      BehaviorMapper.ensureInitialized();
      RenderableMapper.ensureInitialized();
      HealthMapper.ensureInitialized();
      AttackIntentMapper.ensureInitialized();
      DidAttackMapper.ensureInitialized();
      WasAttackedMapper.ensureInitialized();
      DeadMapper.ensureInitialized();
      InventoryMapper.ensureInitialized();
      InventoryMaxCountMapper.ensureInitialized();
      LootMapper.ensureInitialized();
      LootTableMapper.ensureInitialized();
      InventoryFullFailureMapper.ensureInitialized();
      PickupableMapper.ensureInitialized();
      PickupIntentMapper.ensureInitialized();
      PickedUpMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Component';

  @override
  final MappableFields<Component> fields = const {};

  static Component _instantiate(DecodingData data) {
    throw MapperException.missingSubclass(
      'Component',
      '__type',
      '${data.value['__type']}',
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Component fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Component>(map);
  }

  static Component fromJson(String json) {
    return ensureInitialized().decodeJson<Component>(json);
  }
}

mixin ComponentMappable {
  String toJson();
  Map<String, dynamic> toMap();
  ComponentCopyWith<Component, Component, Component> get copyWith;
}

abstract class ComponentCopyWith<$R, $In extends Component, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  ComponentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class LifetimeMapper extends SubClassMapperBase<Lifetime> {
  LifetimeMapper._();

  static LifetimeMapper? _instance;
  static LifetimeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = LifetimeMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
      BeforeTickMapper.ensureInitialized();
      AfterTickMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Lifetime';

  static int _$lifetime(Lifetime v) => v.lifetime;
  static const Field<Lifetime, int> _f$lifetime = Field('lifetime', _$lifetime);

  @override
  final MappableFields<Lifetime> fields = const {#lifetime: _f$lifetime};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'Lifetime';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static Lifetime _instantiate(DecodingData data) {
    return Lifetime(data.dec(_f$lifetime));
  }

  @override
  final Function instantiate = _instantiate;

  static Lifetime fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Lifetime>(map);
  }

  static Lifetime fromJson(String json) {
    return ensureInitialized().decodeJson<Lifetime>(json);
  }
}

mixin LifetimeMappable {
  String toJson() {
    return LifetimeMapper.ensureInitialized().encodeJson<Lifetime>(
      this as Lifetime,
    );
  }

  Map<String, dynamic> toMap() {
    return LifetimeMapper.ensureInitialized().encodeMap<Lifetime>(
      this as Lifetime,
    );
  }

  LifetimeCopyWith<Lifetime, Lifetime, Lifetime> get copyWith =>
      _LifetimeCopyWithImpl<Lifetime, Lifetime>(
        this as Lifetime,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return LifetimeMapper.ensureInitialized().stringifyValue(this as Lifetime);
  }

  @override
  bool operator ==(Object other) {
    return LifetimeMapper.ensureInitialized().equalsValue(
      this as Lifetime,
      other,
    );
  }

  @override
  int get hashCode {
    return LifetimeMapper.ensureInitialized().hashValue(this as Lifetime);
  }
}

extension LifetimeValueCopy<$R, $Out> on ObjectCopyWith<$R, Lifetime, $Out> {
  LifetimeCopyWith<$R, Lifetime, $Out> get $asLifetime =>
      $base.as((v, t, t2) => _LifetimeCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class LifetimeCopyWith<$R, $In extends Lifetime, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call();
  LifetimeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _LifetimeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Lifetime, $Out>
    implements LifetimeCopyWith<$R, Lifetime, $Out> {
  _LifetimeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Lifetime> $mapper =
      LifetimeMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  Lifetime $make(CopyWithData data) =>
      Lifetime(data.get(#lifetime, or: $value.lifetime));

  @override
  LifetimeCopyWith<$R2, Lifetime, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _LifetimeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class BeforeTickMapper extends SubClassMapperBase<BeforeTick> {
  BeforeTickMapper._();

  static BeforeTickMapper? _instance;
  static BeforeTickMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = BeforeTickMapper._());
      LifetimeMapper.ensureInitialized().addSubMapper(_instance!);
      DidMoveMapper.ensureInitialized();
      BlockedMoveMapper.ensureInitialized();
      DidAttackMapper.ensureInitialized();
      WasAttackedMapper.ensureInitialized();
      InventoryFullFailureMapper.ensureInitialized();
      PickedUpMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'BeforeTick';

  static int _$lifetime(BeforeTick v) => v.lifetime;
  static const Field<BeforeTick, int> _f$lifetime = Field(
    'lifetime',
    _$lifetime,
    opt: true,
    def: 0,
  );

  @override
  final MappableFields<BeforeTick> fields = const {#lifetime: _f$lifetime};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'BeforeTick';
  @override
  late final ClassMapperBase superMapper = LifetimeMapper.ensureInitialized();

  static BeforeTick _instantiate(DecodingData data) {
    return BeforeTick(data.dec(_f$lifetime));
  }

  @override
  final Function instantiate = _instantiate;

  static BeforeTick fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<BeforeTick>(map);
  }

  static BeforeTick fromJson(String json) {
    return ensureInitialized().decodeJson<BeforeTick>(json);
  }
}

mixin BeforeTickMappable {
  String toJson() {
    return BeforeTickMapper.ensureInitialized().encodeJson<BeforeTick>(
      this as BeforeTick,
    );
  }

  Map<String, dynamic> toMap() {
    return BeforeTickMapper.ensureInitialized().encodeMap<BeforeTick>(
      this as BeforeTick,
    );
  }

  BeforeTickCopyWith<BeforeTick, BeforeTick, BeforeTick> get copyWith =>
      _BeforeTickCopyWithImpl<BeforeTick, BeforeTick>(
        this as BeforeTick,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return BeforeTickMapper.ensureInitialized().stringifyValue(
      this as BeforeTick,
    );
  }

  @override
  bool operator ==(Object other) {
    return BeforeTickMapper.ensureInitialized().equalsValue(
      this as BeforeTick,
      other,
    );
  }

  @override
  int get hashCode {
    return BeforeTickMapper.ensureInitialized().hashValue(this as BeforeTick);
  }
}

extension BeforeTickValueCopy<$R, $Out>
    on ObjectCopyWith<$R, BeforeTick, $Out> {
  BeforeTickCopyWith<$R, BeforeTick, $Out> get $asBeforeTick =>
      $base.as((v, t, t2) => _BeforeTickCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class BeforeTickCopyWith<$R, $In extends BeforeTick, $Out>
    implements
        LifetimeCopyWith<$R, $In, $Out>,
        ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call();
  BeforeTickCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _BeforeTickCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, BeforeTick, $Out>
    implements BeforeTickCopyWith<$R, BeforeTick, $Out> {
  _BeforeTickCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<BeforeTick> $mapper =
      BeforeTickMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  BeforeTick $make(CopyWithData data) =>
      BeforeTick(data.get(#lifetime, or: $value.lifetime));

  @override
  BeforeTickCopyWith<$R2, BeforeTick, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _BeforeTickCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class AfterTickMapper extends SubClassMapperBase<AfterTick> {
  AfterTickMapper._();

  static AfterTickMapper? _instance;
  static AfterTickMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AfterTickMapper._());
      LifetimeMapper.ensureInitialized().addSubMapper(_instance!);
      MoveByIntentMapper.ensureInitialized();
      PickupIntentMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AfterTick';

  static int _$lifetime(AfterTick v) => v.lifetime;
  static const Field<AfterTick, int> _f$lifetime = Field(
    'lifetime',
    _$lifetime,
    opt: true,
    def: 0,
  );

  @override
  final MappableFields<AfterTick> fields = const {#lifetime: _f$lifetime};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'AfterTick';
  @override
  late final ClassMapperBase superMapper = LifetimeMapper.ensureInitialized();

  static AfterTick _instantiate(DecodingData data) {
    return AfterTick(data.dec(_f$lifetime));
  }

  @override
  final Function instantiate = _instantiate;

  static AfterTick fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AfterTick>(map);
  }

  static AfterTick fromJson(String json) {
    return ensureInitialized().decodeJson<AfterTick>(json);
  }
}

mixin AfterTickMappable {
  String toJson() {
    return AfterTickMapper.ensureInitialized().encodeJson<AfterTick>(
      this as AfterTick,
    );
  }

  Map<String, dynamic> toMap() {
    return AfterTickMapper.ensureInitialized().encodeMap<AfterTick>(
      this as AfterTick,
    );
  }

  AfterTickCopyWith<AfterTick, AfterTick, AfterTick> get copyWith =>
      _AfterTickCopyWithImpl<AfterTick, AfterTick>(
        this as AfterTick,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AfterTickMapper.ensureInitialized().stringifyValue(
      this as AfterTick,
    );
  }

  @override
  bool operator ==(Object other) {
    return AfterTickMapper.ensureInitialized().equalsValue(
      this as AfterTick,
      other,
    );
  }

  @override
  int get hashCode {
    return AfterTickMapper.ensureInitialized().hashValue(this as AfterTick);
  }
}

extension AfterTickValueCopy<$R, $Out> on ObjectCopyWith<$R, AfterTick, $Out> {
  AfterTickCopyWith<$R, AfterTick, $Out> get $asAfterTick =>
      $base.as((v, t, t2) => _AfterTickCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AfterTickCopyWith<$R, $In extends AfterTick, $Out>
    implements
        LifetimeCopyWith<$R, $In, $Out>,
        ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call();
  AfterTickCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AfterTickCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AfterTick, $Out>
    implements AfterTickCopyWith<$R, AfterTick, $Out> {
  _AfterTickCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AfterTick> $mapper =
      AfterTickMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  AfterTick $make(CopyWithData data) =>
      AfterTick(data.get(#lifetime, or: $value.lifetime));

  @override
  AfterTickCopyWith<$R2, AfterTick, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _AfterTickCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CellMapper extends SubClassMapperBase<Cell> {
  CellMapper._();

  static CellMapper? _instance;
  static CellMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CellMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'Cell';

  static List<int> _$entityIds(Cell v) => v.entityIds;
  static const Field<Cell, List<int>> _f$entityIds = Field(
    'entityIds',
    _$entityIds,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<Cell> fields = const {#entityIds: _f$entityIds};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'Cell';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static Cell _instantiate(DecodingData data) {
    return Cell();
  }

  @override
  final Function instantiate = _instantiate;

  static Cell fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Cell>(map);
  }

  static Cell fromJson(String json) {
    return ensureInitialized().decodeJson<Cell>(json);
  }
}

mixin CellMappable {
  String toJson() {
    return CellMapper.ensureInitialized().encodeJson<Cell>(this as Cell);
  }

  Map<String, dynamic> toMap() {
    return CellMapper.ensureInitialized().encodeMap<Cell>(this as Cell);
  }

  CellCopyWith<Cell, Cell, Cell> get copyWith =>
      _CellCopyWithImpl<Cell, Cell>(this as Cell, $identity, $identity);
  @override
  String toString() {
    return CellMapper.ensureInitialized().stringifyValue(this as Cell);
  }

  @override
  bool operator ==(Object other) {
    return CellMapper.ensureInitialized().equalsValue(this as Cell, other);
  }

  @override
  int get hashCode {
    return CellMapper.ensureInitialized().hashValue(this as Cell);
  }
}

extension CellValueCopy<$R, $Out> on ObjectCopyWith<$R, Cell, $Out> {
  CellCopyWith<$R, Cell, $Out> get $asCell =>
      $base.as((v, t, t2) => _CellCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CellCopyWith<$R, $In extends Cell, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call();
  CellCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CellCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Cell, $Out>
    implements CellCopyWith<$R, Cell, $Out> {
  _CellCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Cell> $mapper = CellMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  Cell $make(CopyWithData data) => Cell();

  @override
  CellCopyWith<$R2, Cell, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _CellCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class NameMapper extends SubClassMapperBase<Name> {
  NameMapper._();

  static NameMapper? _instance;
  static NameMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = NameMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'Name';

  static String _$name(Name v) => v.name;
  static const Field<Name, String> _f$name = Field('name', _$name);

  @override
  final MappableFields<Name> fields = const {#name: _f$name};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'Name';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static Name _instantiate(DecodingData data) {
    return Name(name: data.dec(_f$name));
  }

  @override
  final Function instantiate = _instantiate;

  static Name fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Name>(map);
  }

  static Name fromJson(String json) {
    return ensureInitialized().decodeJson<Name>(json);
  }
}

mixin NameMappable {
  String toJson() {
    return NameMapper.ensureInitialized().encodeJson<Name>(this as Name);
  }

  Map<String, dynamic> toMap() {
    return NameMapper.ensureInitialized().encodeMap<Name>(this as Name);
  }

  NameCopyWith<Name, Name, Name> get copyWith =>
      _NameCopyWithImpl<Name, Name>(this as Name, $identity, $identity);
  @override
  String toString() {
    return NameMapper.ensureInitialized().stringifyValue(this as Name);
  }

  @override
  bool operator ==(Object other) {
    return NameMapper.ensureInitialized().equalsValue(this as Name, other);
  }

  @override
  int get hashCode {
    return NameMapper.ensureInitialized().hashValue(this as Name);
  }
}

extension NameValueCopy<$R, $Out> on ObjectCopyWith<$R, Name, $Out> {
  NameCopyWith<$R, Name, $Out> get $asName =>
      $base.as((v, t, t2) => _NameCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class NameCopyWith<$R, $In extends Name, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call({String? name});
  NameCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _NameCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Name, $Out>
    implements NameCopyWith<$R, Name, $Out> {
  _NameCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Name> $mapper = NameMapper.ensureInitialized();
  @override
  $R call({String? name}) =>
      $apply(FieldCopyWithData({if (name != null) #name: name}));
  @override
  Name $make(CopyWithData data) => Name(name: data.get(#name, or: $value.name));

  @override
  NameCopyWith<$R2, Name, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _NameCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class LocalPositionMapper extends SubClassMapperBase<LocalPosition> {
  LocalPositionMapper._();

  static LocalPositionMapper? _instance;
  static LocalPositionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = LocalPositionMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'LocalPosition';

  static int _$x(LocalPosition v) => v.x;
  static const Field<LocalPosition, int> _f$x = Field('x', _$x);
  static int _$y(LocalPosition v) => v.y;
  static const Field<LocalPosition, int> _f$y = Field('y', _$y);

  @override
  final MappableFields<LocalPosition> fields = const {#x: _f$x, #y: _f$y};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'LocalPosition';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static LocalPosition _instantiate(DecodingData data) {
    return LocalPosition(x: data.dec(_f$x), y: data.dec(_f$y));
  }

  @override
  final Function instantiate = _instantiate;

  static LocalPosition fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<LocalPosition>(map);
  }

  static LocalPosition fromJson(String json) {
    return ensureInitialized().decodeJson<LocalPosition>(json);
  }
}

mixin LocalPositionMappable {
  String toJson() {
    return LocalPositionMapper.ensureInitialized().encodeJson<LocalPosition>(
      this as LocalPosition,
    );
  }

  Map<String, dynamic> toMap() {
    return LocalPositionMapper.ensureInitialized().encodeMap<LocalPosition>(
      this as LocalPosition,
    );
  }

  LocalPositionCopyWith<LocalPosition, LocalPosition, LocalPosition>
  get copyWith => _LocalPositionCopyWithImpl<LocalPosition, LocalPosition>(
    this as LocalPosition,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return LocalPositionMapper.ensureInitialized().stringifyValue(
      this as LocalPosition,
    );
  }

  @override
  bool operator ==(Object other) {
    return LocalPositionMapper.ensureInitialized().equalsValue(
      this as LocalPosition,
      other,
    );
  }

  @override
  int get hashCode {
    return LocalPositionMapper.ensureInitialized().hashValue(
      this as LocalPosition,
    );
  }
}

extension LocalPositionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, LocalPosition, $Out> {
  LocalPositionCopyWith<$R, LocalPosition, $Out> get $asLocalPosition =>
      $base.as((v, t, t2) => _LocalPositionCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class LocalPositionCopyWith<$R, $In extends LocalPosition, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call({int? x, int? y});
  LocalPositionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _LocalPositionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, LocalPosition, $Out>
    implements LocalPositionCopyWith<$R, LocalPosition, $Out> {
  _LocalPositionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<LocalPosition> $mapper =
      LocalPositionMapper.ensureInitialized();
  @override
  $R call({int? x, int? y}) =>
      $apply(FieldCopyWithData({if (x != null) #x: x, if (y != null) #y: y}));
  @override
  LocalPosition $make(CopyWithData data) => LocalPosition(
    x: data.get(#x, or: $value.x),
    y: data.get(#y, or: $value.y),
  );

  @override
  LocalPositionCopyWith<$R2, LocalPosition, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _LocalPositionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class MoveByIntentMapper extends SubClassMapperBase<MoveByIntent> {
  MoveByIntentMapper._();

  static MoveByIntentMapper? _instance;
  static MoveByIntentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MoveByIntentMapper._());
      AfterTickMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'MoveByIntent';

  static int _$dx(MoveByIntent v) => v.dx;
  static const Field<MoveByIntent, int> _f$dx = Field('dx', _$dx);
  static int _$dy(MoveByIntent v) => v.dy;
  static const Field<MoveByIntent, int> _f$dy = Field('dy', _$dy);
  static int _$lifetime(MoveByIntent v) => v.lifetime;
  static const Field<MoveByIntent, int> _f$lifetime = Field(
    'lifetime',
    _$lifetime,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<MoveByIntent> fields = const {
    #dx: _f$dx,
    #dy: _f$dy,
    #lifetime: _f$lifetime,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'MoveByIntent';
  @override
  late final ClassMapperBase superMapper = AfterTickMapper.ensureInitialized();

  static MoveByIntent _instantiate(DecodingData data) {
    return MoveByIntent(dx: data.dec(_f$dx), dy: data.dec(_f$dy));
  }

  @override
  final Function instantiate = _instantiate;

  static MoveByIntent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MoveByIntent>(map);
  }

  static MoveByIntent fromJson(String json) {
    return ensureInitialized().decodeJson<MoveByIntent>(json);
  }
}

mixin MoveByIntentMappable {
  String toJson() {
    return MoveByIntentMapper.ensureInitialized().encodeJson<MoveByIntent>(
      this as MoveByIntent,
    );
  }

  Map<String, dynamic> toMap() {
    return MoveByIntentMapper.ensureInitialized().encodeMap<MoveByIntent>(
      this as MoveByIntent,
    );
  }

  MoveByIntentCopyWith<MoveByIntent, MoveByIntent, MoveByIntent> get copyWith =>
      _MoveByIntentCopyWithImpl<MoveByIntent, MoveByIntent>(
        this as MoveByIntent,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MoveByIntentMapper.ensureInitialized().stringifyValue(
      this as MoveByIntent,
    );
  }

  @override
  bool operator ==(Object other) {
    return MoveByIntentMapper.ensureInitialized().equalsValue(
      this as MoveByIntent,
      other,
    );
  }

  @override
  int get hashCode {
    return MoveByIntentMapper.ensureInitialized().hashValue(
      this as MoveByIntent,
    );
  }
}

extension MoveByIntentValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MoveByIntent, $Out> {
  MoveByIntentCopyWith<$R, MoveByIntent, $Out> get $asMoveByIntent =>
      $base.as((v, t, t2) => _MoveByIntentCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MoveByIntentCopyWith<$R, $In extends MoveByIntent, $Out>
    implements
        AfterTickCopyWith<$R, $In, $Out>,
        ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call({int? dx, int? dy});
  MoveByIntentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MoveByIntentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MoveByIntent, $Out>
    implements MoveByIntentCopyWith<$R, MoveByIntent, $Out> {
  _MoveByIntentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MoveByIntent> $mapper =
      MoveByIntentMapper.ensureInitialized();
  @override
  $R call({int? dx, int? dy}) => $apply(
    FieldCopyWithData({if (dx != null) #dx: dx, if (dy != null) #dy: dy}),
  );
  @override
  MoveByIntent $make(CopyWithData data) => MoveByIntent(
    dx: data.get(#dx, or: $value.dx),
    dy: data.get(#dy, or: $value.dy),
  );

  @override
  MoveByIntentCopyWith<$R2, MoveByIntent, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MoveByIntentCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DidMoveMapper extends SubClassMapperBase<DidMove> {
  DidMoveMapper._();

  static DidMoveMapper? _instance;
  static DidMoveMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DidMoveMapper._());
      BeforeTickMapper.ensureInitialized().addSubMapper(_instance!);
      LocalPositionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DidMove';

  static LocalPosition _$from(DidMove v) => v.from;
  static const Field<DidMove, LocalPosition> _f$from = Field('from', _$from);
  static LocalPosition _$to(DidMove v) => v.to;
  static const Field<DidMove, LocalPosition> _f$to = Field('to', _$to);
  static int _$lifetime(DidMove v) => v.lifetime;
  static const Field<DidMove, int> _f$lifetime = Field(
    'lifetime',
    _$lifetime,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<DidMove> fields = const {
    #from: _f$from,
    #to: _f$to,
    #lifetime: _f$lifetime,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'DidMove';
  @override
  late final ClassMapperBase superMapper = BeforeTickMapper.ensureInitialized();

  static DidMove _instantiate(DecodingData data) {
    return DidMove(from: data.dec(_f$from), to: data.dec(_f$to));
  }

  @override
  final Function instantiate = _instantiate;

  static DidMove fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DidMove>(map);
  }

  static DidMove fromJson(String json) {
    return ensureInitialized().decodeJson<DidMove>(json);
  }
}

mixin DidMoveMappable {
  String toJson() {
    return DidMoveMapper.ensureInitialized().encodeJson<DidMove>(
      this as DidMove,
    );
  }

  Map<String, dynamic> toMap() {
    return DidMoveMapper.ensureInitialized().encodeMap<DidMove>(
      this as DidMove,
    );
  }

  DidMoveCopyWith<DidMove, DidMove, DidMove> get copyWith =>
      _DidMoveCopyWithImpl<DidMove, DidMove>(
        this as DidMove,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DidMoveMapper.ensureInitialized().stringifyValue(this as DidMove);
  }

  @override
  bool operator ==(Object other) {
    return DidMoveMapper.ensureInitialized().equalsValue(
      this as DidMove,
      other,
    );
  }

  @override
  int get hashCode {
    return DidMoveMapper.ensureInitialized().hashValue(this as DidMove);
  }
}

extension DidMoveValueCopy<$R, $Out> on ObjectCopyWith<$R, DidMove, $Out> {
  DidMoveCopyWith<$R, DidMove, $Out> get $asDidMove =>
      $base.as((v, t, t2) => _DidMoveCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DidMoveCopyWith<$R, $In extends DidMove, $Out>
    implements
        BeforeTickCopyWith<$R, $In, $Out>,
        ComponentCopyWith<$R, $In, $Out> {
  LocalPositionCopyWith<$R, LocalPosition, LocalPosition> get from;
  LocalPositionCopyWith<$R, LocalPosition, LocalPosition> get to;
  @override
  $R call({LocalPosition? from, LocalPosition? to});
  DidMoveCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DidMoveCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DidMove, $Out>
    implements DidMoveCopyWith<$R, DidMove, $Out> {
  _DidMoveCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DidMove> $mapper =
      DidMoveMapper.ensureInitialized();
  @override
  LocalPositionCopyWith<$R, LocalPosition, LocalPosition> get from =>
      $value.from.copyWith.$chain((v) => call(from: v));
  @override
  LocalPositionCopyWith<$R, LocalPosition, LocalPosition> get to =>
      $value.to.copyWith.$chain((v) => call(to: v));
  @override
  $R call({LocalPosition? from, LocalPosition? to}) => $apply(
    FieldCopyWithData({if (from != null) #from: from, if (to != null) #to: to}),
  );
  @override
  DidMove $make(CopyWithData data) => DidMove(
    from: data.get(#from, or: $value.from),
    to: data.get(#to, or: $value.to),
  );

  @override
  DidMoveCopyWith<$R2, DidMove, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _DidMoveCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class BlocksMovementMapper extends SubClassMapperBase<BlocksMovement> {
  BlocksMovementMapper._();

  static BlocksMovementMapper? _instance;
  static BlocksMovementMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = BlocksMovementMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'BlocksMovement';

  @override
  final MappableFields<BlocksMovement> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'BlocksMovement';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static BlocksMovement _instantiate(DecodingData data) {
    return BlocksMovement();
  }

  @override
  final Function instantiate = _instantiate;

  static BlocksMovement fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<BlocksMovement>(map);
  }

  static BlocksMovement fromJson(String json) {
    return ensureInitialized().decodeJson<BlocksMovement>(json);
  }
}

mixin BlocksMovementMappable {
  String toJson() {
    return BlocksMovementMapper.ensureInitialized().encodeJson<BlocksMovement>(
      this as BlocksMovement,
    );
  }

  Map<String, dynamic> toMap() {
    return BlocksMovementMapper.ensureInitialized().encodeMap<BlocksMovement>(
      this as BlocksMovement,
    );
  }

  BlocksMovementCopyWith<BlocksMovement, BlocksMovement, BlocksMovement>
  get copyWith => _BlocksMovementCopyWithImpl<BlocksMovement, BlocksMovement>(
    this as BlocksMovement,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return BlocksMovementMapper.ensureInitialized().stringifyValue(
      this as BlocksMovement,
    );
  }

  @override
  bool operator ==(Object other) {
    return BlocksMovementMapper.ensureInitialized().equalsValue(
      this as BlocksMovement,
      other,
    );
  }

  @override
  int get hashCode {
    return BlocksMovementMapper.ensureInitialized().hashValue(
      this as BlocksMovement,
    );
  }
}

extension BlocksMovementValueCopy<$R, $Out>
    on ObjectCopyWith<$R, BlocksMovement, $Out> {
  BlocksMovementCopyWith<$R, BlocksMovement, $Out> get $asBlocksMovement =>
      $base.as((v, t, t2) => _BlocksMovementCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class BlocksMovementCopyWith<$R, $In extends BlocksMovement, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call();
  BlocksMovementCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _BlocksMovementCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, BlocksMovement, $Out>
    implements BlocksMovementCopyWith<$R, BlocksMovement, $Out> {
  _BlocksMovementCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<BlocksMovement> $mapper =
      BlocksMovementMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  BlocksMovement $make(CopyWithData data) => BlocksMovement();

  @override
  BlocksMovementCopyWith<$R2, BlocksMovement, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _BlocksMovementCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class BlockedMoveMapper extends SubClassMapperBase<BlockedMove> {
  BlockedMoveMapper._();

  static BlockedMoveMapper? _instance;
  static BlockedMoveMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = BlockedMoveMapper._());
      BeforeTickMapper.ensureInitialized().addSubMapper(_instance!);
      LocalPositionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'BlockedMove';

  static LocalPosition _$attempted(BlockedMove v) => v.attempted;
  static const Field<BlockedMove, LocalPosition> _f$attempted = Field(
    'attempted',
    _$attempted,
  );
  static int _$lifetime(BlockedMove v) => v.lifetime;
  static const Field<BlockedMove, int> _f$lifetime = Field(
    'lifetime',
    _$lifetime,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<BlockedMove> fields = const {
    #attempted: _f$attempted,
    #lifetime: _f$lifetime,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'BlockedMove';
  @override
  late final ClassMapperBase superMapper = BeforeTickMapper.ensureInitialized();

  static BlockedMove _instantiate(DecodingData data) {
    return BlockedMove(data.dec(_f$attempted));
  }

  @override
  final Function instantiate = _instantiate;

  static BlockedMove fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<BlockedMove>(map);
  }

  static BlockedMove fromJson(String json) {
    return ensureInitialized().decodeJson<BlockedMove>(json);
  }
}

mixin BlockedMoveMappable {
  String toJson() {
    return BlockedMoveMapper.ensureInitialized().encodeJson<BlockedMove>(
      this as BlockedMove,
    );
  }

  Map<String, dynamic> toMap() {
    return BlockedMoveMapper.ensureInitialized().encodeMap<BlockedMove>(
      this as BlockedMove,
    );
  }

  BlockedMoveCopyWith<BlockedMove, BlockedMove, BlockedMove> get copyWith =>
      _BlockedMoveCopyWithImpl<BlockedMove, BlockedMove>(
        this as BlockedMove,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return BlockedMoveMapper.ensureInitialized().stringifyValue(
      this as BlockedMove,
    );
  }

  @override
  bool operator ==(Object other) {
    return BlockedMoveMapper.ensureInitialized().equalsValue(
      this as BlockedMove,
      other,
    );
  }

  @override
  int get hashCode {
    return BlockedMoveMapper.ensureInitialized().hashValue(this as BlockedMove);
  }
}

extension BlockedMoveValueCopy<$R, $Out>
    on ObjectCopyWith<$R, BlockedMove, $Out> {
  BlockedMoveCopyWith<$R, BlockedMove, $Out> get $asBlockedMove =>
      $base.as((v, t, t2) => _BlockedMoveCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class BlockedMoveCopyWith<$R, $In extends BlockedMove, $Out>
    implements
        BeforeTickCopyWith<$R, $In, $Out>,
        ComponentCopyWith<$R, $In, $Out> {
  LocalPositionCopyWith<$R, LocalPosition, LocalPosition> get attempted;
  @override
  $R call({LocalPosition? attempted});
  BlockedMoveCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _BlockedMoveCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, BlockedMove, $Out>
    implements BlockedMoveCopyWith<$R, BlockedMove, $Out> {
  _BlockedMoveCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<BlockedMove> $mapper =
      BlockedMoveMapper.ensureInitialized();
  @override
  LocalPositionCopyWith<$R, LocalPosition, LocalPosition> get attempted =>
      $value.attempted.copyWith.$chain((v) => call(attempted: v));
  @override
  $R call({LocalPosition? attempted}) =>
      $apply(FieldCopyWithData({if (attempted != null) #attempted: attempted}));
  @override
  BlockedMove $make(CopyWithData data) =>
      BlockedMove(data.get(#attempted, or: $value.attempted));

  @override
  BlockedMoveCopyWith<$R2, BlockedMove, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _BlockedMoveCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class PlayerControlledMapper extends SubClassMapperBase<PlayerControlled> {
  PlayerControlledMapper._();

  static PlayerControlledMapper? _instance;
  static PlayerControlledMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PlayerControlledMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'PlayerControlled';

  @override
  final MappableFields<PlayerControlled> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'PlayerControlled';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static PlayerControlled _instantiate(DecodingData data) {
    return PlayerControlled();
  }

  @override
  final Function instantiate = _instantiate;

  static PlayerControlled fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PlayerControlled>(map);
  }

  static PlayerControlled fromJson(String json) {
    return ensureInitialized().decodeJson<PlayerControlled>(json);
  }
}

mixin PlayerControlledMappable {
  String toJson() {
    return PlayerControlledMapper.ensureInitialized()
        .encodeJson<PlayerControlled>(this as PlayerControlled);
  }

  Map<String, dynamic> toMap() {
    return PlayerControlledMapper.ensureInitialized()
        .encodeMap<PlayerControlled>(this as PlayerControlled);
  }

  PlayerControlledCopyWith<PlayerControlled, PlayerControlled, PlayerControlled>
  get copyWith =>
      _PlayerControlledCopyWithImpl<PlayerControlled, PlayerControlled>(
        this as PlayerControlled,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PlayerControlledMapper.ensureInitialized().stringifyValue(
      this as PlayerControlled,
    );
  }

  @override
  bool operator ==(Object other) {
    return PlayerControlledMapper.ensureInitialized().equalsValue(
      this as PlayerControlled,
      other,
    );
  }

  @override
  int get hashCode {
    return PlayerControlledMapper.ensureInitialized().hashValue(
      this as PlayerControlled,
    );
  }
}

extension PlayerControlledValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PlayerControlled, $Out> {
  PlayerControlledCopyWith<$R, PlayerControlled, $Out>
  get $asPlayerControlled =>
      $base.as((v, t, t2) => _PlayerControlledCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PlayerControlledCopyWith<$R, $In extends PlayerControlled, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call();
  PlayerControlledCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _PlayerControlledCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PlayerControlled, $Out>
    implements PlayerControlledCopyWith<$R, PlayerControlled, $Out> {
  _PlayerControlledCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PlayerControlled> $mapper =
      PlayerControlledMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  PlayerControlled $make(CopyWithData data) => PlayerControlled();

  @override
  PlayerControlledCopyWith<$R2, PlayerControlled, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PlayerControlledCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class AiControlledMapper extends SubClassMapperBase<AiControlled> {
  AiControlledMapper._();

  static AiControlledMapper? _instance;
  static AiControlledMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AiControlledMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'AiControlled';

  @override
  final MappableFields<AiControlled> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'AiControlled';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static AiControlled _instantiate(DecodingData data) {
    return AiControlled();
  }

  @override
  final Function instantiate = _instantiate;

  static AiControlled fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AiControlled>(map);
  }

  static AiControlled fromJson(String json) {
    return ensureInitialized().decodeJson<AiControlled>(json);
  }
}

mixin AiControlledMappable {
  String toJson() {
    return AiControlledMapper.ensureInitialized().encodeJson<AiControlled>(
      this as AiControlled,
    );
  }

  Map<String, dynamic> toMap() {
    return AiControlledMapper.ensureInitialized().encodeMap<AiControlled>(
      this as AiControlled,
    );
  }

  AiControlledCopyWith<AiControlled, AiControlled, AiControlled> get copyWith =>
      _AiControlledCopyWithImpl<AiControlled, AiControlled>(
        this as AiControlled,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AiControlledMapper.ensureInitialized().stringifyValue(
      this as AiControlled,
    );
  }

  @override
  bool operator ==(Object other) {
    return AiControlledMapper.ensureInitialized().equalsValue(
      this as AiControlled,
      other,
    );
  }

  @override
  int get hashCode {
    return AiControlledMapper.ensureInitialized().hashValue(
      this as AiControlled,
    );
  }
}

extension AiControlledValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AiControlled, $Out> {
  AiControlledCopyWith<$R, AiControlled, $Out> get $asAiControlled =>
      $base.as((v, t, t2) => _AiControlledCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AiControlledCopyWith<$R, $In extends AiControlled, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call();
  AiControlledCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AiControlledCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AiControlled, $Out>
    implements AiControlledCopyWith<$R, AiControlled, $Out> {
  _AiControlledCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AiControlled> $mapper =
      AiControlledMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  AiControlled $make(CopyWithData data) => AiControlled();

  @override
  AiControlledCopyWith<$R2, AiControlled, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _AiControlledCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class BehaviorMapper extends SubClassMapperBase<Behavior> {
  BehaviorMapper._();

  static BehaviorMapper? _instance;
  static BehaviorMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = BehaviorMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
      NodeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Behavior';

  static Node _$behavior(Behavior v) => v.behavior;
  static const Field<Behavior, Node> _f$behavior = Field(
    'behavior',
    _$behavior,
  );

  @override
  final MappableFields<Behavior> fields = const {#behavior: _f$behavior};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'Behavior';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static Behavior _instantiate(DecodingData data) {
    return Behavior(data.dec(_f$behavior));
  }

  @override
  final Function instantiate = _instantiate;

  static Behavior fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Behavior>(map);
  }

  static Behavior fromJson(String json) {
    return ensureInitialized().decodeJson<Behavior>(json);
  }
}

mixin BehaviorMappable {
  String toJson() {
    return BehaviorMapper.ensureInitialized().encodeJson<Behavior>(
      this as Behavior,
    );
  }

  Map<String, dynamic> toMap() {
    return BehaviorMapper.ensureInitialized().encodeMap<Behavior>(
      this as Behavior,
    );
  }

  BehaviorCopyWith<Behavior, Behavior, Behavior> get copyWith =>
      _BehaviorCopyWithImpl<Behavior, Behavior>(
        this as Behavior,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return BehaviorMapper.ensureInitialized().stringifyValue(this as Behavior);
  }

  @override
  bool operator ==(Object other) {
    return BehaviorMapper.ensureInitialized().equalsValue(
      this as Behavior,
      other,
    );
  }

  @override
  int get hashCode {
    return BehaviorMapper.ensureInitialized().hashValue(this as Behavior);
  }
}

extension BehaviorValueCopy<$R, $Out> on ObjectCopyWith<$R, Behavior, $Out> {
  BehaviorCopyWith<$R, Behavior, $Out> get $asBehavior =>
      $base.as((v, t, t2) => _BehaviorCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class BehaviorCopyWith<$R, $In extends Behavior, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call({Node? behavior});
  BehaviorCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _BehaviorCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Behavior, $Out>
    implements BehaviorCopyWith<$R, Behavior, $Out> {
  _BehaviorCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Behavior> $mapper =
      BehaviorMapper.ensureInitialized();
  @override
  $R call({Node? behavior}) =>
      $apply(FieldCopyWithData({if (behavior != null) #behavior: behavior}));
  @override
  Behavior $make(CopyWithData data) =>
      Behavior(data.get(#behavior, or: $value.behavior));

  @override
  BehaviorCopyWith<$R2, Behavior, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _BehaviorCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class RenderableMapper extends SubClassMapperBase<Renderable> {
  RenderableMapper._();

  static RenderableMapper? _instance;
  static RenderableMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RenderableMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'Renderable';

  static String _$svgAssetPath(Renderable v) => v.svgAssetPath;
  static const Field<Renderable, String> _f$svgAssetPath = Field(
    'svgAssetPath',
    _$svgAssetPath,
  );

  @override
  final MappableFields<Renderable> fields = const {
    #svgAssetPath: _f$svgAssetPath,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'Renderable';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static Renderable _instantiate(DecodingData data) {
    return Renderable(data.dec(_f$svgAssetPath));
  }

  @override
  final Function instantiate = _instantiate;

  static Renderable fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Renderable>(map);
  }

  static Renderable fromJson(String json) {
    return ensureInitialized().decodeJson<Renderable>(json);
  }
}

mixin RenderableMappable {
  String toJson() {
    return RenderableMapper.ensureInitialized().encodeJson<Renderable>(
      this as Renderable,
    );
  }

  Map<String, dynamic> toMap() {
    return RenderableMapper.ensureInitialized().encodeMap<Renderable>(
      this as Renderable,
    );
  }

  RenderableCopyWith<Renderable, Renderable, Renderable> get copyWith =>
      _RenderableCopyWithImpl<Renderable, Renderable>(
        this as Renderable,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return RenderableMapper.ensureInitialized().stringifyValue(
      this as Renderable,
    );
  }

  @override
  bool operator ==(Object other) {
    return RenderableMapper.ensureInitialized().equalsValue(
      this as Renderable,
      other,
    );
  }

  @override
  int get hashCode {
    return RenderableMapper.ensureInitialized().hashValue(this as Renderable);
  }
}

extension RenderableValueCopy<$R, $Out>
    on ObjectCopyWith<$R, Renderable, $Out> {
  RenderableCopyWith<$R, Renderable, $Out> get $asRenderable =>
      $base.as((v, t, t2) => _RenderableCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class RenderableCopyWith<$R, $In extends Renderable, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call({String? svgAssetPath});
  RenderableCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _RenderableCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Renderable, $Out>
    implements RenderableCopyWith<$R, Renderable, $Out> {
  _RenderableCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Renderable> $mapper =
      RenderableMapper.ensureInitialized();
  @override
  $R call({String? svgAssetPath}) => $apply(
    FieldCopyWithData({if (svgAssetPath != null) #svgAssetPath: svgAssetPath}),
  );
  @override
  Renderable $make(CopyWithData data) =>
      Renderable(data.get(#svgAssetPath, or: $value.svgAssetPath));

  @override
  RenderableCopyWith<$R2, Renderable, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _RenderableCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class HealthMapper extends SubClassMapperBase<Health> {
  HealthMapper._();

  static HealthMapper? _instance;
  static HealthMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = HealthMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'Health';

  static int _$current(Health v) => v.current;
  static const Field<Health, int> _f$current = Field('current', _$current);
  static int _$max(Health v) => v.max;
  static const Field<Health, int> _f$max = Field('max', _$max);

  @override
  final MappableFields<Health> fields = const {
    #current: _f$current,
    #max: _f$max,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'Health';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static Health _instantiate(DecodingData data) {
    return Health(data.dec(_f$current), data.dec(_f$max));
  }

  @override
  final Function instantiate = _instantiate;

  static Health fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Health>(map);
  }

  static Health fromJson(String json) {
    return ensureInitialized().decodeJson<Health>(json);
  }
}

mixin HealthMappable {
  String toJson() {
    return HealthMapper.ensureInitialized().encodeJson<Health>(this as Health);
  }

  Map<String, dynamic> toMap() {
    return HealthMapper.ensureInitialized().encodeMap<Health>(this as Health);
  }

  HealthCopyWith<Health, Health, Health> get copyWith =>
      _HealthCopyWithImpl<Health, Health>(this as Health, $identity, $identity);
  @override
  String toString() {
    return HealthMapper.ensureInitialized().stringifyValue(this as Health);
  }

  @override
  bool operator ==(Object other) {
    return HealthMapper.ensureInitialized().equalsValue(this as Health, other);
  }

  @override
  int get hashCode {
    return HealthMapper.ensureInitialized().hashValue(this as Health);
  }
}

extension HealthValueCopy<$R, $Out> on ObjectCopyWith<$R, Health, $Out> {
  HealthCopyWith<$R, Health, $Out> get $asHealth =>
      $base.as((v, t, t2) => _HealthCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class HealthCopyWith<$R, $In extends Health, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call({int? current, int? max});
  HealthCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _HealthCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Health, $Out>
    implements HealthCopyWith<$R, Health, $Out> {
  _HealthCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Health> $mapper = HealthMapper.ensureInitialized();
  @override
  $R call({int? current, int? max}) => $apply(
    FieldCopyWithData({
      if (current != null) #current: current,
      if (max != null) #max: max,
    }),
  );
  @override
  Health $make(CopyWithData data) => Health(
    data.get(#current, or: $value.current),
    data.get(#max, or: $value.max),
  );

  @override
  HealthCopyWith<$R2, Health, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _HealthCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class AttackIntentMapper extends SubClassMapperBase<AttackIntent> {
  AttackIntentMapper._();

  static AttackIntentMapper? _instance;
  static AttackIntentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AttackIntentMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'AttackIntent';

  static int _$targetId(AttackIntent v) => v.targetId;
  static const Field<AttackIntent, int> _f$targetId = Field(
    'targetId',
    _$targetId,
  );

  @override
  final MappableFields<AttackIntent> fields = const {#targetId: _f$targetId};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'AttackIntent';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static AttackIntent _instantiate(DecodingData data) {
    return AttackIntent(data.dec(_f$targetId));
  }

  @override
  final Function instantiate = _instantiate;

  static AttackIntent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AttackIntent>(map);
  }

  static AttackIntent fromJson(String json) {
    return ensureInitialized().decodeJson<AttackIntent>(json);
  }
}

mixin AttackIntentMappable {
  String toJson() {
    return AttackIntentMapper.ensureInitialized().encodeJson<AttackIntent>(
      this as AttackIntent,
    );
  }

  Map<String, dynamic> toMap() {
    return AttackIntentMapper.ensureInitialized().encodeMap<AttackIntent>(
      this as AttackIntent,
    );
  }

  AttackIntentCopyWith<AttackIntent, AttackIntent, AttackIntent> get copyWith =>
      _AttackIntentCopyWithImpl<AttackIntent, AttackIntent>(
        this as AttackIntent,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AttackIntentMapper.ensureInitialized().stringifyValue(
      this as AttackIntent,
    );
  }

  @override
  bool operator ==(Object other) {
    return AttackIntentMapper.ensureInitialized().equalsValue(
      this as AttackIntent,
      other,
    );
  }

  @override
  int get hashCode {
    return AttackIntentMapper.ensureInitialized().hashValue(
      this as AttackIntent,
    );
  }
}

extension AttackIntentValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AttackIntent, $Out> {
  AttackIntentCopyWith<$R, AttackIntent, $Out> get $asAttackIntent =>
      $base.as((v, t, t2) => _AttackIntentCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AttackIntentCopyWith<$R, $In extends AttackIntent, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call({int? targetId});
  AttackIntentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AttackIntentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AttackIntent, $Out>
    implements AttackIntentCopyWith<$R, AttackIntent, $Out> {
  _AttackIntentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AttackIntent> $mapper =
      AttackIntentMapper.ensureInitialized();
  @override
  $R call({int? targetId}) =>
      $apply(FieldCopyWithData({if (targetId != null) #targetId: targetId}));
  @override
  AttackIntent $make(CopyWithData data) =>
      AttackIntent(data.get(#targetId, or: $value.targetId));

  @override
  AttackIntentCopyWith<$R2, AttackIntent, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _AttackIntentCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DidAttackMapper extends SubClassMapperBase<DidAttack> {
  DidAttackMapper._();

  static DidAttackMapper? _instance;
  static DidAttackMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DidAttackMapper._());
      BeforeTickMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'DidAttack';

  static int _$targetId(DidAttack v) => v.targetId;
  static const Field<DidAttack, int> _f$targetId = Field(
    'targetId',
    _$targetId,
  );
  static int _$damage(DidAttack v) => v.damage;
  static const Field<DidAttack, int> _f$damage = Field('damage', _$damage);
  static int _$lifetime(DidAttack v) => v.lifetime;
  static const Field<DidAttack, int> _f$lifetime = Field(
    'lifetime',
    _$lifetime,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<DidAttack> fields = const {
    #targetId: _f$targetId,
    #damage: _f$damage,
    #lifetime: _f$lifetime,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'DidAttack';
  @override
  late final ClassMapperBase superMapper = BeforeTickMapper.ensureInitialized();

  static DidAttack _instantiate(DecodingData data) {
    return DidAttack(
      targetId: data.dec(_f$targetId),
      damage: data.dec(_f$damage),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static DidAttack fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DidAttack>(map);
  }

  static DidAttack fromJson(String json) {
    return ensureInitialized().decodeJson<DidAttack>(json);
  }
}

mixin DidAttackMappable {
  String toJson() {
    return DidAttackMapper.ensureInitialized().encodeJson<DidAttack>(
      this as DidAttack,
    );
  }

  Map<String, dynamic> toMap() {
    return DidAttackMapper.ensureInitialized().encodeMap<DidAttack>(
      this as DidAttack,
    );
  }

  DidAttackCopyWith<DidAttack, DidAttack, DidAttack> get copyWith =>
      _DidAttackCopyWithImpl<DidAttack, DidAttack>(
        this as DidAttack,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DidAttackMapper.ensureInitialized().stringifyValue(
      this as DidAttack,
    );
  }

  @override
  bool operator ==(Object other) {
    return DidAttackMapper.ensureInitialized().equalsValue(
      this as DidAttack,
      other,
    );
  }

  @override
  int get hashCode {
    return DidAttackMapper.ensureInitialized().hashValue(this as DidAttack);
  }
}

extension DidAttackValueCopy<$R, $Out> on ObjectCopyWith<$R, DidAttack, $Out> {
  DidAttackCopyWith<$R, DidAttack, $Out> get $asDidAttack =>
      $base.as((v, t, t2) => _DidAttackCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DidAttackCopyWith<$R, $In extends DidAttack, $Out>
    implements
        BeforeTickCopyWith<$R, $In, $Out>,
        ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call({int? targetId, int? damage});
  DidAttackCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DidAttackCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DidAttack, $Out>
    implements DidAttackCopyWith<$R, DidAttack, $Out> {
  _DidAttackCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DidAttack> $mapper =
      DidAttackMapper.ensureInitialized();
  @override
  $R call({int? targetId, int? damage}) => $apply(
    FieldCopyWithData({
      if (targetId != null) #targetId: targetId,
      if (damage != null) #damage: damage,
    }),
  );
  @override
  DidAttack $make(CopyWithData data) => DidAttack(
    targetId: data.get(#targetId, or: $value.targetId),
    damage: data.get(#damage, or: $value.damage),
  );

  @override
  DidAttackCopyWith<$R2, DidAttack, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DidAttackCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class WasAttackedMapper extends SubClassMapperBase<WasAttacked> {
  WasAttackedMapper._();

  static WasAttackedMapper? _instance;
  static WasAttackedMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = WasAttackedMapper._());
      BeforeTickMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'WasAttacked';

  static int _$sourceId(WasAttacked v) => v.sourceId;
  static const Field<WasAttacked, int> _f$sourceId = Field(
    'sourceId',
    _$sourceId,
  );
  static int _$damage(WasAttacked v) => v.damage;
  static const Field<WasAttacked, int> _f$damage = Field('damage', _$damage);
  static int _$lifetime(WasAttacked v) => v.lifetime;
  static const Field<WasAttacked, int> _f$lifetime = Field(
    'lifetime',
    _$lifetime,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<WasAttacked> fields = const {
    #sourceId: _f$sourceId,
    #damage: _f$damage,
    #lifetime: _f$lifetime,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'WasAttacked';
  @override
  late final ClassMapperBase superMapper = BeforeTickMapper.ensureInitialized();

  static WasAttacked _instantiate(DecodingData data) {
    return WasAttacked(
      sourceId: data.dec(_f$sourceId),
      damage: data.dec(_f$damage),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static WasAttacked fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<WasAttacked>(map);
  }

  static WasAttacked fromJson(String json) {
    return ensureInitialized().decodeJson<WasAttacked>(json);
  }
}

mixin WasAttackedMappable {
  String toJson() {
    return WasAttackedMapper.ensureInitialized().encodeJson<WasAttacked>(
      this as WasAttacked,
    );
  }

  Map<String, dynamic> toMap() {
    return WasAttackedMapper.ensureInitialized().encodeMap<WasAttacked>(
      this as WasAttacked,
    );
  }

  WasAttackedCopyWith<WasAttacked, WasAttacked, WasAttacked> get copyWith =>
      _WasAttackedCopyWithImpl<WasAttacked, WasAttacked>(
        this as WasAttacked,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return WasAttackedMapper.ensureInitialized().stringifyValue(
      this as WasAttacked,
    );
  }

  @override
  bool operator ==(Object other) {
    return WasAttackedMapper.ensureInitialized().equalsValue(
      this as WasAttacked,
      other,
    );
  }

  @override
  int get hashCode {
    return WasAttackedMapper.ensureInitialized().hashValue(this as WasAttacked);
  }
}

extension WasAttackedValueCopy<$R, $Out>
    on ObjectCopyWith<$R, WasAttacked, $Out> {
  WasAttackedCopyWith<$R, WasAttacked, $Out> get $asWasAttacked =>
      $base.as((v, t, t2) => _WasAttackedCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class WasAttackedCopyWith<$R, $In extends WasAttacked, $Out>
    implements
        BeforeTickCopyWith<$R, $In, $Out>,
        ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call({int? sourceId, int? damage});
  WasAttackedCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _WasAttackedCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, WasAttacked, $Out>
    implements WasAttackedCopyWith<$R, WasAttacked, $Out> {
  _WasAttackedCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<WasAttacked> $mapper =
      WasAttackedMapper.ensureInitialized();
  @override
  $R call({int? sourceId, int? damage}) => $apply(
    FieldCopyWithData({
      if (sourceId != null) #sourceId: sourceId,
      if (damage != null) #damage: damage,
    }),
  );
  @override
  WasAttacked $make(CopyWithData data) => WasAttacked(
    sourceId: data.get(#sourceId, or: $value.sourceId),
    damage: data.get(#damage, or: $value.damage),
  );

  @override
  WasAttackedCopyWith<$R2, WasAttacked, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _WasAttackedCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DeadMapper extends SubClassMapperBase<Dead> {
  DeadMapper._();

  static DeadMapper? _instance;
  static DeadMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DeadMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'Dead';

  @override
  final MappableFields<Dead> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'Dead';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static Dead _instantiate(DecodingData data) {
    return Dead();
  }

  @override
  final Function instantiate = _instantiate;

  static Dead fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Dead>(map);
  }

  static Dead fromJson(String json) {
    return ensureInitialized().decodeJson<Dead>(json);
  }
}

mixin DeadMappable {
  String toJson() {
    return DeadMapper.ensureInitialized().encodeJson<Dead>(this as Dead);
  }

  Map<String, dynamic> toMap() {
    return DeadMapper.ensureInitialized().encodeMap<Dead>(this as Dead);
  }

  DeadCopyWith<Dead, Dead, Dead> get copyWith =>
      _DeadCopyWithImpl<Dead, Dead>(this as Dead, $identity, $identity);
  @override
  String toString() {
    return DeadMapper.ensureInitialized().stringifyValue(this as Dead);
  }

  @override
  bool operator ==(Object other) {
    return DeadMapper.ensureInitialized().equalsValue(this as Dead, other);
  }

  @override
  int get hashCode {
    return DeadMapper.ensureInitialized().hashValue(this as Dead);
  }
}

extension DeadValueCopy<$R, $Out> on ObjectCopyWith<$R, Dead, $Out> {
  DeadCopyWith<$R, Dead, $Out> get $asDead =>
      $base.as((v, t, t2) => _DeadCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DeadCopyWith<$R, $In extends Dead, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call();
  DeadCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DeadCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Dead, $Out>
    implements DeadCopyWith<$R, Dead, $Out> {
  _DeadCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Dead> $mapper = DeadMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  Dead $make(CopyWithData data) => Dead();

  @override
  DeadCopyWith<$R2, Dead, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _DeadCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class InventoryMapper extends SubClassMapperBase<Inventory> {
  InventoryMapper._();

  static InventoryMapper? _instance;
  static InventoryMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = InventoryMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'Inventory';

  static List<int> _$items(Inventory v) => v.items;
  static const Field<Inventory, List<int>> _f$items = Field('items', _$items);

  @override
  final MappableFields<Inventory> fields = const {#items: _f$items};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'Inventory';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static Inventory _instantiate(DecodingData data) {
    return Inventory(data.dec(_f$items));
  }

  @override
  final Function instantiate = _instantiate;

  static Inventory fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Inventory>(map);
  }

  static Inventory fromJson(String json) {
    return ensureInitialized().decodeJson<Inventory>(json);
  }
}

mixin InventoryMappable {
  String toJson() {
    return InventoryMapper.ensureInitialized().encodeJson<Inventory>(
      this as Inventory,
    );
  }

  Map<String, dynamic> toMap() {
    return InventoryMapper.ensureInitialized().encodeMap<Inventory>(
      this as Inventory,
    );
  }

  InventoryCopyWith<Inventory, Inventory, Inventory> get copyWith =>
      _InventoryCopyWithImpl<Inventory, Inventory>(
        this as Inventory,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return InventoryMapper.ensureInitialized().stringifyValue(
      this as Inventory,
    );
  }

  @override
  bool operator ==(Object other) {
    return InventoryMapper.ensureInitialized().equalsValue(
      this as Inventory,
      other,
    );
  }

  @override
  int get hashCode {
    return InventoryMapper.ensureInitialized().hashValue(this as Inventory);
  }
}

extension InventoryValueCopy<$R, $Out> on ObjectCopyWith<$R, Inventory, $Out> {
  InventoryCopyWith<$R, Inventory, $Out> get $asInventory =>
      $base.as((v, t, t2) => _InventoryCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class InventoryCopyWith<$R, $In extends Inventory, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, int, ObjectCopyWith<$R, int, int>> get items;
  @override
  $R call({List<int>? items});
  InventoryCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _InventoryCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Inventory, $Out>
    implements InventoryCopyWith<$R, Inventory, $Out> {
  _InventoryCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Inventory> $mapper =
      InventoryMapper.ensureInitialized();
  @override
  ListCopyWith<$R, int, ObjectCopyWith<$R, int, int>> get items => ListCopyWith(
    $value.items,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(items: v),
  );
  @override
  $R call({List<int>? items}) =>
      $apply(FieldCopyWithData({if (items != null) #items: items}));
  @override
  Inventory $make(CopyWithData data) =>
      Inventory(data.get(#items, or: $value.items));

  @override
  InventoryCopyWith<$R2, Inventory, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _InventoryCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class InventoryMaxCountMapper extends SubClassMapperBase<InventoryMaxCount> {
  InventoryMaxCountMapper._();

  static InventoryMaxCountMapper? _instance;
  static InventoryMaxCountMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = InventoryMaxCountMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'InventoryMaxCount';

  static int _$maxAmount(InventoryMaxCount v) => v.maxAmount;
  static const Field<InventoryMaxCount, int> _f$maxAmount = Field(
    'maxAmount',
    _$maxAmount,
  );

  @override
  final MappableFields<InventoryMaxCount> fields = const {
    #maxAmount: _f$maxAmount,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'InventoryMaxCount';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static InventoryMaxCount _instantiate(DecodingData data) {
    return InventoryMaxCount(data.dec(_f$maxAmount));
  }

  @override
  final Function instantiate = _instantiate;

  static InventoryMaxCount fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<InventoryMaxCount>(map);
  }

  static InventoryMaxCount fromJson(String json) {
    return ensureInitialized().decodeJson<InventoryMaxCount>(json);
  }
}

mixin InventoryMaxCountMappable {
  String toJson() {
    return InventoryMaxCountMapper.ensureInitialized()
        .encodeJson<InventoryMaxCount>(this as InventoryMaxCount);
  }

  Map<String, dynamic> toMap() {
    return InventoryMaxCountMapper.ensureInitialized()
        .encodeMap<InventoryMaxCount>(this as InventoryMaxCount);
  }

  InventoryMaxCountCopyWith<
    InventoryMaxCount,
    InventoryMaxCount,
    InventoryMaxCount
  >
  get copyWith =>
      _InventoryMaxCountCopyWithImpl<InventoryMaxCount, InventoryMaxCount>(
        this as InventoryMaxCount,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return InventoryMaxCountMapper.ensureInitialized().stringifyValue(
      this as InventoryMaxCount,
    );
  }

  @override
  bool operator ==(Object other) {
    return InventoryMaxCountMapper.ensureInitialized().equalsValue(
      this as InventoryMaxCount,
      other,
    );
  }

  @override
  int get hashCode {
    return InventoryMaxCountMapper.ensureInitialized().hashValue(
      this as InventoryMaxCount,
    );
  }
}

extension InventoryMaxCountValueCopy<$R, $Out>
    on ObjectCopyWith<$R, InventoryMaxCount, $Out> {
  InventoryMaxCountCopyWith<$R, InventoryMaxCount, $Out>
  get $asInventoryMaxCount => $base.as(
    (v, t, t2) => _InventoryMaxCountCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class InventoryMaxCountCopyWith<
  $R,
  $In extends InventoryMaxCount,
  $Out
>
    implements ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call({int? maxAmount});
  InventoryMaxCountCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _InventoryMaxCountCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, InventoryMaxCount, $Out>
    implements InventoryMaxCountCopyWith<$R, InventoryMaxCount, $Out> {
  _InventoryMaxCountCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<InventoryMaxCount> $mapper =
      InventoryMaxCountMapper.ensureInitialized();
  @override
  $R call({int? maxAmount}) =>
      $apply(FieldCopyWithData({if (maxAmount != null) #maxAmount: maxAmount}));
  @override
  InventoryMaxCount $make(CopyWithData data) =>
      InventoryMaxCount(data.get(#maxAmount, or: $value.maxAmount));

  @override
  InventoryMaxCountCopyWith<$R2, InventoryMaxCount, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _InventoryMaxCountCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class LootMapper extends SubClassMapperBase<Loot> {
  LootMapper._();

  static LootMapper? _instance;
  static LootMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = LootMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
      ComponentMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Loot';

  static List<Component> _$components(Loot v) => v.components;
  static const Field<Loot, List<Component>> _f$components = Field(
    'components',
    _$components,
  );
  static double _$probability(Loot v) => v.probability;
  static const Field<Loot, double> _f$probability = Field(
    'probability',
    _$probability,
    opt: true,
    def: 1.0,
  );
  static int _$quantity(Loot v) => v.quantity;
  static const Field<Loot, int> _f$quantity = Field(
    'quantity',
    _$quantity,
    opt: true,
    def: 1,
  );

  @override
  final MappableFields<Loot> fields = const {
    #components: _f$components,
    #probability: _f$probability,
    #quantity: _f$quantity,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'Loot';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static Loot _instantiate(DecodingData data) {
    return Loot(
      components: data.dec(_f$components),
      probability: data.dec(_f$probability),
      quantity: data.dec(_f$quantity),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Loot fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Loot>(map);
  }

  static Loot fromJson(String json) {
    return ensureInitialized().decodeJson<Loot>(json);
  }
}

mixin LootMappable {
  String toJson() {
    return LootMapper.ensureInitialized().encodeJson<Loot>(this as Loot);
  }

  Map<String, dynamic> toMap() {
    return LootMapper.ensureInitialized().encodeMap<Loot>(this as Loot);
  }

  LootCopyWith<Loot, Loot, Loot> get copyWith =>
      _LootCopyWithImpl<Loot, Loot>(this as Loot, $identity, $identity);
  @override
  String toString() {
    return LootMapper.ensureInitialized().stringifyValue(this as Loot);
  }

  @override
  bool operator ==(Object other) {
    return LootMapper.ensureInitialized().equalsValue(this as Loot, other);
  }

  @override
  int get hashCode {
    return LootMapper.ensureInitialized().hashValue(this as Loot);
  }
}

extension LootValueCopy<$R, $Out> on ObjectCopyWith<$R, Loot, $Out> {
  LootCopyWith<$R, Loot, $Out> get $asLoot =>
      $base.as((v, t, t2) => _LootCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class LootCopyWith<$R, $In extends Loot, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Component, ComponentCopyWith<$R, Component, Component>>
  get components;
  @override
  $R call({List<Component>? components, double? probability, int? quantity});
  LootCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _LootCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Loot, $Out>
    implements LootCopyWith<$R, Loot, $Out> {
  _LootCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Loot> $mapper = LootMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Component, ComponentCopyWith<$R, Component, Component>>
  get components => ListCopyWith(
    $value.components,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(components: v),
  );
  @override
  $R call({List<Component>? components, double? probability, int? quantity}) =>
      $apply(
        FieldCopyWithData({
          if (components != null) #components: components,
          if (probability != null) #probability: probability,
          if (quantity != null) #quantity: quantity,
        }),
      );
  @override
  Loot $make(CopyWithData data) => Loot(
    components: data.get(#components, or: $value.components),
    probability: data.get(#probability, or: $value.probability),
    quantity: data.get(#quantity, or: $value.quantity),
  );

  @override
  LootCopyWith<$R2, Loot, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _LootCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class LootTableMapper extends SubClassMapperBase<LootTable> {
  LootTableMapper._();

  static LootTableMapper? _instance;
  static LootTableMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = LootTableMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
      LootMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'LootTable';

  static List<Loot> _$lootables(LootTable v) => v.lootables;
  static const Field<LootTable, List<Loot>> _f$lootables = Field(
    'lootables',
    _$lootables,
  );

  @override
  final MappableFields<LootTable> fields = const {#lootables: _f$lootables};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'LootTable';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static LootTable _instantiate(DecodingData data) {
    return LootTable(data.dec(_f$lootables));
  }

  @override
  final Function instantiate = _instantiate;

  static LootTable fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<LootTable>(map);
  }

  static LootTable fromJson(String json) {
    return ensureInitialized().decodeJson<LootTable>(json);
  }
}

mixin LootTableMappable {
  String toJson() {
    return LootTableMapper.ensureInitialized().encodeJson<LootTable>(
      this as LootTable,
    );
  }

  Map<String, dynamic> toMap() {
    return LootTableMapper.ensureInitialized().encodeMap<LootTable>(
      this as LootTable,
    );
  }

  LootTableCopyWith<LootTable, LootTable, LootTable> get copyWith =>
      _LootTableCopyWithImpl<LootTable, LootTable>(
        this as LootTable,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return LootTableMapper.ensureInitialized().stringifyValue(
      this as LootTable,
    );
  }

  @override
  bool operator ==(Object other) {
    return LootTableMapper.ensureInitialized().equalsValue(
      this as LootTable,
      other,
    );
  }

  @override
  int get hashCode {
    return LootTableMapper.ensureInitialized().hashValue(this as LootTable);
  }
}

extension LootTableValueCopy<$R, $Out> on ObjectCopyWith<$R, LootTable, $Out> {
  LootTableCopyWith<$R, LootTable, $Out> get $asLootTable =>
      $base.as((v, t, t2) => _LootTableCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class LootTableCopyWith<$R, $In extends LootTable, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Loot, LootCopyWith<$R, Loot, Loot>> get lootables;
  @override
  $R call({List<Loot>? lootables});
  LootTableCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _LootTableCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, LootTable, $Out>
    implements LootTableCopyWith<$R, LootTable, $Out> {
  _LootTableCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<LootTable> $mapper =
      LootTableMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Loot, LootCopyWith<$R, Loot, Loot>> get lootables =>
      ListCopyWith(
        $value.lootables,
        (v, t) => v.copyWith.$chain(t),
        (v) => call(lootables: v),
      );
  @override
  $R call({List<Loot>? lootables}) =>
      $apply(FieldCopyWithData({if (lootables != null) #lootables: lootables}));
  @override
  LootTable $make(CopyWithData data) =>
      LootTable(data.get(#lootables, or: $value.lootables));

  @override
  LootTableCopyWith<$R2, LootTable, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _LootTableCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class InventoryFullFailureMapper
    extends SubClassMapperBase<InventoryFullFailure> {
  InventoryFullFailureMapper._();

  static InventoryFullFailureMapper? _instance;
  static InventoryFullFailureMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = InventoryFullFailureMapper._());
      BeforeTickMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'InventoryFullFailure';

  static int _$targetEntityId(InventoryFullFailure v) => v.targetEntityId;
  static const Field<InventoryFullFailure, int> _f$targetEntityId = Field(
    'targetEntityId',
    _$targetEntityId,
  );
  static int _$lifetime(InventoryFullFailure v) => v.lifetime;
  static const Field<InventoryFullFailure, int> _f$lifetime = Field(
    'lifetime',
    _$lifetime,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<InventoryFullFailure> fields = const {
    #targetEntityId: _f$targetEntityId,
    #lifetime: _f$lifetime,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'InventoryFullFailure';
  @override
  late final ClassMapperBase superMapper = BeforeTickMapper.ensureInitialized();

  static InventoryFullFailure _instantiate(DecodingData data) {
    return InventoryFullFailure(data.dec(_f$targetEntityId));
  }

  @override
  final Function instantiate = _instantiate;

  static InventoryFullFailure fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<InventoryFullFailure>(map);
  }

  static InventoryFullFailure fromJson(String json) {
    return ensureInitialized().decodeJson<InventoryFullFailure>(json);
  }
}

mixin InventoryFullFailureMappable {
  String toJson() {
    return InventoryFullFailureMapper.ensureInitialized()
        .encodeJson<InventoryFullFailure>(this as InventoryFullFailure);
  }

  Map<String, dynamic> toMap() {
    return InventoryFullFailureMapper.ensureInitialized()
        .encodeMap<InventoryFullFailure>(this as InventoryFullFailure);
  }

  InventoryFullFailureCopyWith<
    InventoryFullFailure,
    InventoryFullFailure,
    InventoryFullFailure
  >
  get copyWith =>
      _InventoryFullFailureCopyWithImpl<
        InventoryFullFailure,
        InventoryFullFailure
      >(this as InventoryFullFailure, $identity, $identity);
  @override
  String toString() {
    return InventoryFullFailureMapper.ensureInitialized().stringifyValue(
      this as InventoryFullFailure,
    );
  }

  @override
  bool operator ==(Object other) {
    return InventoryFullFailureMapper.ensureInitialized().equalsValue(
      this as InventoryFullFailure,
      other,
    );
  }

  @override
  int get hashCode {
    return InventoryFullFailureMapper.ensureInitialized().hashValue(
      this as InventoryFullFailure,
    );
  }
}

extension InventoryFullFailureValueCopy<$R, $Out>
    on ObjectCopyWith<$R, InventoryFullFailure, $Out> {
  InventoryFullFailureCopyWith<$R, InventoryFullFailure, $Out>
  get $asInventoryFullFailure => $base.as(
    (v, t, t2) => _InventoryFullFailureCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class InventoryFullFailureCopyWith<
  $R,
  $In extends InventoryFullFailure,
  $Out
>
    implements
        BeforeTickCopyWith<$R, $In, $Out>,
        ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call({int? targetEntityId});
  InventoryFullFailureCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _InventoryFullFailureCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, InventoryFullFailure, $Out>
    implements InventoryFullFailureCopyWith<$R, InventoryFullFailure, $Out> {
  _InventoryFullFailureCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<InventoryFullFailure> $mapper =
      InventoryFullFailureMapper.ensureInitialized();
  @override
  $R call({int? targetEntityId}) => $apply(
    FieldCopyWithData({
      if (targetEntityId != null) #targetEntityId: targetEntityId,
    }),
  );
  @override
  InventoryFullFailure $make(CopyWithData data) => InventoryFullFailure(
    data.get(#targetEntityId, or: $value.targetEntityId),
  );

  @override
  InventoryFullFailureCopyWith<$R2, InventoryFullFailure, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _InventoryFullFailureCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class PickupableMapper extends SubClassMapperBase<Pickupable> {
  PickupableMapper._();

  static PickupableMapper? _instance;
  static PickupableMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PickupableMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'Pickupable';

  @override
  final MappableFields<Pickupable> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'Pickupable';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static Pickupable _instantiate(DecodingData data) {
    return Pickupable();
  }

  @override
  final Function instantiate = _instantiate;

  static Pickupable fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Pickupable>(map);
  }

  static Pickupable fromJson(String json) {
    return ensureInitialized().decodeJson<Pickupable>(json);
  }
}

mixin PickupableMappable {
  String toJson() {
    return PickupableMapper.ensureInitialized().encodeJson<Pickupable>(
      this as Pickupable,
    );
  }

  Map<String, dynamic> toMap() {
    return PickupableMapper.ensureInitialized().encodeMap<Pickupable>(
      this as Pickupable,
    );
  }

  PickupableCopyWith<Pickupable, Pickupable, Pickupable> get copyWith =>
      _PickupableCopyWithImpl<Pickupable, Pickupable>(
        this as Pickupable,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PickupableMapper.ensureInitialized().stringifyValue(
      this as Pickupable,
    );
  }

  @override
  bool operator ==(Object other) {
    return PickupableMapper.ensureInitialized().equalsValue(
      this as Pickupable,
      other,
    );
  }

  @override
  int get hashCode {
    return PickupableMapper.ensureInitialized().hashValue(this as Pickupable);
  }
}

extension PickupableValueCopy<$R, $Out>
    on ObjectCopyWith<$R, Pickupable, $Out> {
  PickupableCopyWith<$R, Pickupable, $Out> get $asPickupable =>
      $base.as((v, t, t2) => _PickupableCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PickupableCopyWith<$R, $In extends Pickupable, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call();
  PickupableCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PickupableCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Pickupable, $Out>
    implements PickupableCopyWith<$R, Pickupable, $Out> {
  _PickupableCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Pickupable> $mapper =
      PickupableMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  Pickupable $make(CopyWithData data) => Pickupable();

  @override
  PickupableCopyWith<$R2, Pickupable, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PickupableCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class PickupIntentMapper extends SubClassMapperBase<PickupIntent> {
  PickupIntentMapper._();

  static PickupIntentMapper? _instance;
  static PickupIntentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PickupIntentMapper._());
      AfterTickMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'PickupIntent';

  static int _$targetEntityId(PickupIntent v) => v.targetEntityId;
  static const Field<PickupIntent, int> _f$targetEntityId = Field(
    'targetEntityId',
    _$targetEntityId,
  );
  static int _$lifetime(PickupIntent v) => v.lifetime;
  static const Field<PickupIntent, int> _f$lifetime = Field(
    'lifetime',
    _$lifetime,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<PickupIntent> fields = const {
    #targetEntityId: _f$targetEntityId,
    #lifetime: _f$lifetime,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'PickupIntent';
  @override
  late final ClassMapperBase superMapper = AfterTickMapper.ensureInitialized();

  static PickupIntent _instantiate(DecodingData data) {
    return PickupIntent(data.dec(_f$targetEntityId));
  }

  @override
  final Function instantiate = _instantiate;

  static PickupIntent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PickupIntent>(map);
  }

  static PickupIntent fromJson(String json) {
    return ensureInitialized().decodeJson<PickupIntent>(json);
  }
}

mixin PickupIntentMappable {
  String toJson() {
    return PickupIntentMapper.ensureInitialized().encodeJson<PickupIntent>(
      this as PickupIntent,
    );
  }

  Map<String, dynamic> toMap() {
    return PickupIntentMapper.ensureInitialized().encodeMap<PickupIntent>(
      this as PickupIntent,
    );
  }

  PickupIntentCopyWith<PickupIntent, PickupIntent, PickupIntent> get copyWith =>
      _PickupIntentCopyWithImpl<PickupIntent, PickupIntent>(
        this as PickupIntent,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PickupIntentMapper.ensureInitialized().stringifyValue(
      this as PickupIntent,
    );
  }

  @override
  bool operator ==(Object other) {
    return PickupIntentMapper.ensureInitialized().equalsValue(
      this as PickupIntent,
      other,
    );
  }

  @override
  int get hashCode {
    return PickupIntentMapper.ensureInitialized().hashValue(
      this as PickupIntent,
    );
  }
}

extension PickupIntentValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PickupIntent, $Out> {
  PickupIntentCopyWith<$R, PickupIntent, $Out> get $asPickupIntent =>
      $base.as((v, t, t2) => _PickupIntentCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PickupIntentCopyWith<$R, $In extends PickupIntent, $Out>
    implements
        AfterTickCopyWith<$R, $In, $Out>,
        ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call({int? targetEntityId});
  PickupIntentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PickupIntentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PickupIntent, $Out>
    implements PickupIntentCopyWith<$R, PickupIntent, $Out> {
  _PickupIntentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PickupIntent> $mapper =
      PickupIntentMapper.ensureInitialized();
  @override
  $R call({int? targetEntityId}) => $apply(
    FieldCopyWithData({
      if (targetEntityId != null) #targetEntityId: targetEntityId,
    }),
  );
  @override
  PickupIntent $make(CopyWithData data) =>
      PickupIntent(data.get(#targetEntityId, or: $value.targetEntityId));

  @override
  PickupIntentCopyWith<$R2, PickupIntent, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PickupIntentCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class PickedUpMapper extends SubClassMapperBase<PickedUp> {
  PickedUpMapper._();

  static PickedUpMapper? _instance;
  static PickedUpMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PickedUpMapper._());
      BeforeTickMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'PickedUp';

  static int _$targetEntityId(PickedUp v) => v.targetEntityId;
  static const Field<PickedUp, int> _f$targetEntityId = Field(
    'targetEntityId',
    _$targetEntityId,
  );
  static int _$lifetime(PickedUp v) => v.lifetime;
  static const Field<PickedUp, int> _f$lifetime = Field(
    'lifetime',
    _$lifetime,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<PickedUp> fields = const {
    #targetEntityId: _f$targetEntityId,
    #lifetime: _f$lifetime,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'PickedUp';
  @override
  late final ClassMapperBase superMapper = BeforeTickMapper.ensureInitialized();

  static PickedUp _instantiate(DecodingData data) {
    return PickedUp(data.dec(_f$targetEntityId));
  }

  @override
  final Function instantiate = _instantiate;

  static PickedUp fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PickedUp>(map);
  }

  static PickedUp fromJson(String json) {
    return ensureInitialized().decodeJson<PickedUp>(json);
  }
}

mixin PickedUpMappable {
  String toJson() {
    return PickedUpMapper.ensureInitialized().encodeJson<PickedUp>(
      this as PickedUp,
    );
  }

  Map<String, dynamic> toMap() {
    return PickedUpMapper.ensureInitialized().encodeMap<PickedUp>(
      this as PickedUp,
    );
  }

  PickedUpCopyWith<PickedUp, PickedUp, PickedUp> get copyWith =>
      _PickedUpCopyWithImpl<PickedUp, PickedUp>(
        this as PickedUp,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PickedUpMapper.ensureInitialized().stringifyValue(this as PickedUp);
  }

  @override
  bool operator ==(Object other) {
    return PickedUpMapper.ensureInitialized().equalsValue(
      this as PickedUp,
      other,
    );
  }

  @override
  int get hashCode {
    return PickedUpMapper.ensureInitialized().hashValue(this as PickedUp);
  }
}

extension PickedUpValueCopy<$R, $Out> on ObjectCopyWith<$R, PickedUp, $Out> {
  PickedUpCopyWith<$R, PickedUp, $Out> get $asPickedUp =>
      $base.as((v, t, t2) => _PickedUpCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PickedUpCopyWith<$R, $In extends PickedUp, $Out>
    implements
        BeforeTickCopyWith<$R, $In, $Out>,
        ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call({int? targetEntityId});
  PickedUpCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PickedUpCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PickedUp, $Out>
    implements PickedUpCopyWith<$R, PickedUp, $Out> {
  _PickedUpCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PickedUp> $mapper =
      PickedUpMapper.ensureInitialized();
  @override
  $R call({int? targetEntityId}) => $apply(
    FieldCopyWithData({
      if (targetEntityId != null) #targetEntityId: targetEntityId,
    }),
  );
  @override
  PickedUp $make(CopyWithData data) =>
      PickedUp(data.get(#targetEntityId, or: $value.targetEntityId));

  @override
  PickedUpCopyWith<$R2, PickedUp, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PickedUpCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

