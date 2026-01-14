// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'components.dart';

class CompassDirectionMapper extends EnumMapper<CompassDirection> {
  CompassDirectionMapper._();

  static CompassDirectionMapper? _instance;
  static CompassDirectionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CompassDirectionMapper._());
    }
    return _instance!;
  }

  static CompassDirection fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  CompassDirection decode(dynamic value) {
    switch (value) {
      case r'north':
        return CompassDirection.north;
      case r'south':
        return CompassDirection.south;
      case r'east':
        return CompassDirection.east;
      case r'west':
        return CompassDirection.west;
      case r'northeast':
        return CompassDirection.northeast;
      case r'northwest':
        return CompassDirection.northwest;
      case r'southeast':
        return CompassDirection.southeast;
      case r'southwest':
        return CompassDirection.southwest;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(CompassDirection self) {
    switch (self) {
      case CompassDirection.north:
        return r'north';
      case CompassDirection.south:
        return r'south';
      case CompassDirection.east:
        return r'east';
      case CompassDirection.west:
        return r'west';
      case CompassDirection.northeast:
        return r'northeast';
      case CompassDirection.northwest:
        return r'northwest';
      case CompassDirection.southeast:
        return r'southeast';
      case CompassDirection.southwest:
        return r'southwest';
    }
  }
}

extension CompassDirectionMapperExtension on CompassDirection {
  String toValue() {
    CompassDirectionMapper.ensureInitialized();
    return MapperContainer.globals.toValue<CompassDirection>(this) as String;
  }
}

class PortalFailureReasonMapper extends EnumMapper<PortalFailureReason> {
  PortalFailureReasonMapper._();

  static PortalFailureReasonMapper? _instance;
  static PortalFailureReasonMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PortalFailureReasonMapper._());
    }
    return _instance!;
  }

  static PortalFailureReason fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  PortalFailureReason decode(dynamic value) {
    switch (value) {
      case r'portalNotFound':
        return PortalFailureReason.portalNotFound;
      case r'notSameParent':
        return PortalFailureReason.notSameParent;
      case r'outOfRange':
        return PortalFailureReason.outOfRange;
      case r'destinationBlocked':
        return PortalFailureReason.destinationBlocked;
      case r'destinationParentNotFound':
        return PortalFailureReason.destinationParentNotFound;
      case r'anchorNotFound':
        return PortalFailureReason.anchorNotFound;
      case r'noValidAnchors':
        return PortalFailureReason.noValidAnchors;
      case r'missingComponents':
        return PortalFailureReason.missingComponents;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(PortalFailureReason self) {
    switch (self) {
      case PortalFailureReason.portalNotFound:
        return r'portalNotFound';
      case PortalFailureReason.notSameParent:
        return r'notSameParent';
      case PortalFailureReason.outOfRange:
        return r'outOfRange';
      case PortalFailureReason.destinationBlocked:
        return r'destinationBlocked';
      case PortalFailureReason.destinationParentNotFound:
        return r'destinationParentNotFound';
      case PortalFailureReason.anchorNotFound:
        return r'anchorNotFound';
      case PortalFailureReason.noValidAnchors:
        return r'noValidAnchors';
      case PortalFailureReason.missingComponents:
        return r'missingComponents';
    }
  }
}

extension PortalFailureReasonMapperExtension on PortalFailureReason {
  String toValue() {
    PortalFailureReasonMapper.ensureInitialized();
    return MapperContainer.globals.toValue<PortalFailureReason>(this) as String;
  }
}

class ComponentMapper extends ClassMapperBase<Component> {
  ComponentMapper._();

  static ComponentMapper? _instance;
  static ComponentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ComponentMapper._());
      DirectionMapper.ensureInitialized();
      LifetimeMapper.ensureInitialized();
      BeforeTickMapper.ensureInitialized();
      AfterTickMapper.ensureInitialized();
      IntentComponentMapper.ensureInitialized();
      CellMapper.ensureInitialized();
      NameMapper.ensureInitialized();
      LocalPositionMapper.ensureInitialized();
      DidMoveMapper.ensureInitialized();
      BlocksMovementMapper.ensureInitialized();
      BlockedMoveMapper.ensureInitialized();
      AiControlledMapper.ensureInitialized();
      PlayerMapper.ensureInitialized();
      BehaviorMapper.ensureInitialized();
      RenderableMapper.ensureInitialized();
      HealthMapper.ensureInitialized();
      DidAttackMapper.ensureInitialized();
      WasAttackedMapper.ensureInitialized();
      DeadMapper.ensureInitialized();
      InventoryMapper.ensureInitialized();
      InventoryMaxCountMapper.ensureInitialized();
      InventoryFullFailureMapper.ensureInitialized();
      PickupableMapper.ensureInitialized();
      PickedUpMapper.ensureInitialized();
      BlocksSightMapper.ensureInitialized();
      VisionRadiusMapper.ensureInitialized();
      VisibleEntitiesMapper.ensureInitialized();
      VisionMemoryMapper.ensureInitialized();
      HasParentMapper.ensureInitialized();
      PortalToPositionMapper.ensureInitialized();
      PortalToAnchorMapper.ensureInitialized();
      PortalAnchorMapper.ensureInitialized();
      DidPortalMapper.ensureInitialized();
      FailedToPortalMapper.ensureInitialized();
      ControllableMapper.ensureInitialized();
      ControllingMapper.ensureInitialized();
      EnablesControlMapper.ensureInitialized();
      DockedMapper.ensureInitialized();
      OpenableMapper.ensureInitialized();
      DidOpenMapper.ensureInitialized();
      DidCloseMapper.ensureInitialized();
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

class DirectionMapper extends SubClassMapperBase<Direction> {
  DirectionMapper._();

  static DirectionMapper? _instance;
  static DirectionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DirectionMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
      CompassDirectionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Direction';

  static CompassDirection _$facing(Direction v) => v.facing;
  static const Field<Direction, CompassDirection> _f$facing = Field(
    'facing',
    _$facing,
  );

  @override
  final MappableFields<Direction> fields = const {#facing: _f$facing};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'Direction';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static Direction _instantiate(DecodingData data) {
    return Direction(data.dec(_f$facing));
  }

  @override
  final Function instantiate = _instantiate;

  static Direction fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Direction>(map);
  }

  static Direction fromJson(String json) {
    return ensureInitialized().decodeJson<Direction>(json);
  }
}

mixin DirectionMappable {
  String toJson() {
    return DirectionMapper.ensureInitialized().encodeJson<Direction>(
      this as Direction,
    );
  }

  Map<String, dynamic> toMap() {
    return DirectionMapper.ensureInitialized().encodeMap<Direction>(
      this as Direction,
    );
  }

  DirectionCopyWith<Direction, Direction, Direction> get copyWith =>
      _DirectionCopyWithImpl<Direction, Direction>(
        this as Direction,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DirectionMapper.ensureInitialized().stringifyValue(
      this as Direction,
    );
  }

  @override
  bool operator ==(Object other) {
    return DirectionMapper.ensureInitialized().equalsValue(
      this as Direction,
      other,
    );
  }

  @override
  int get hashCode {
    return DirectionMapper.ensureInitialized().hashValue(this as Direction);
  }
}

extension DirectionValueCopy<$R, $Out> on ObjectCopyWith<$R, Direction, $Out> {
  DirectionCopyWith<$R, Direction, $Out> get $asDirection =>
      $base.as((v, t, t2) => _DirectionCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DirectionCopyWith<$R, $In extends Direction, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call({CompassDirection? facing});
  DirectionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DirectionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Direction, $Out>
    implements DirectionCopyWith<$R, Direction, $Out> {
  _DirectionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Direction> $mapper =
      DirectionMapper.ensureInitialized();
  @override
  $R call({CompassDirection? facing}) =>
      $apply(FieldCopyWithData({if (facing != null) #facing: facing}));
  @override
  Direction $make(CopyWithData data) =>
      Direction(data.get(#facing, or: $value.facing));

  @override
  DirectionCopyWith<$R2, Direction, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DirectionCopyWithImpl<$R2, $Out2>($value, $cast, t);
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
      DidPortalMapper.ensureInitialized();
      FailedToPortalMapper.ensureInitialized();
      DidOpenMapper.ensureInitialized();
      DidCloseMapper.ensureInitialized();
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
      IntentComponentMapper.ensureInitialized();
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

class IntentComponentMapper extends SubClassMapperBase<IntentComponent> {
  IntentComponentMapper._();

  static IntentComponentMapper? _instance;
  static IntentComponentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = IntentComponentMapper._());
      AfterTickMapper.ensureInitialized().addSubMapper(_instance!);
      WaitIntentMapper.ensureInitialized();
      MoveByIntentMapper.ensureInitialized();
      AttackIntentMapper.ensureInitialized();
      PickupIntentMapper.ensureInitialized();
      UsePortalIntentMapper.ensureInitialized();
      WantsControlIntentMapper.ensureInitialized();
      ReleasesControlIntentMapper.ensureInitialized();
      DockIntentMapper.ensureInitialized();
      UndockIntentMapper.ensureInitialized();
      OpenIntentMapper.ensureInitialized();
      CloseIntentMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'IntentComponent';

  static int _$lifetime(IntentComponent v) => v.lifetime;
  static const Field<IntentComponent, int> _f$lifetime = Field(
    'lifetime',
    _$lifetime,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<IntentComponent> fields = const {#lifetime: _f$lifetime};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'IntentComponent';
  @override
  late final ClassMapperBase superMapper = AfterTickMapper.ensureInitialized();

  static IntentComponent _instantiate(DecodingData data) {
    throw MapperException.missingSubclass(
      'IntentComponent',
      '__type',
      '${data.value['__type']}',
    );
  }

  @override
  final Function instantiate = _instantiate;

  static IntentComponent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<IntentComponent>(map);
  }

  static IntentComponent fromJson(String json) {
    return ensureInitialized().decodeJson<IntentComponent>(json);
  }
}

mixin IntentComponentMappable {
  String toJson();
  Map<String, dynamic> toMap();
  IntentComponentCopyWith<IntentComponent, IntentComponent, IntentComponent>
  get copyWith;
}

abstract class IntentComponentCopyWith<$R, $In extends IntentComponent, $Out>
    implements
        AfterTickCopyWith<$R, $In, $Out>,
        ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call();
  IntentComponentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class WaitIntentMapper extends SubClassMapperBase<WaitIntent> {
  WaitIntentMapper._();

  static WaitIntentMapper? _instance;
  static WaitIntentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = WaitIntentMapper._());
      IntentComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'WaitIntent';

  static int _$lifetime(WaitIntent v) => v.lifetime;
  static const Field<WaitIntent, int> _f$lifetime = Field(
    'lifetime',
    _$lifetime,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<WaitIntent> fields = const {#lifetime: _f$lifetime};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'WaitIntent';
  @override
  late final ClassMapperBase superMapper =
      IntentComponentMapper.ensureInitialized();

  static WaitIntent _instantiate(DecodingData data) {
    return WaitIntent();
  }

  @override
  final Function instantiate = _instantiate;

  static WaitIntent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<WaitIntent>(map);
  }

  static WaitIntent fromJson(String json) {
    return ensureInitialized().decodeJson<WaitIntent>(json);
  }
}

mixin WaitIntentMappable {
  String toJson() {
    return WaitIntentMapper.ensureInitialized().encodeJson<WaitIntent>(
      this as WaitIntent,
    );
  }

  Map<String, dynamic> toMap() {
    return WaitIntentMapper.ensureInitialized().encodeMap<WaitIntent>(
      this as WaitIntent,
    );
  }

  WaitIntentCopyWith<WaitIntent, WaitIntent, WaitIntent> get copyWith =>
      _WaitIntentCopyWithImpl<WaitIntent, WaitIntent>(
        this as WaitIntent,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return WaitIntentMapper.ensureInitialized().stringifyValue(
      this as WaitIntent,
    );
  }

  @override
  bool operator ==(Object other) {
    return WaitIntentMapper.ensureInitialized().equalsValue(
      this as WaitIntent,
      other,
    );
  }

  @override
  int get hashCode {
    return WaitIntentMapper.ensureInitialized().hashValue(this as WaitIntent);
  }
}

extension WaitIntentValueCopy<$R, $Out>
    on ObjectCopyWith<$R, WaitIntent, $Out> {
  WaitIntentCopyWith<$R, WaitIntent, $Out> get $asWaitIntent =>
      $base.as((v, t, t2) => _WaitIntentCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class WaitIntentCopyWith<$R, $In extends WaitIntent, $Out>
    implements IntentComponentCopyWith<$R, $In, $Out> {
  @override
  $R call();
  WaitIntentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _WaitIntentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, WaitIntent, $Out>
    implements WaitIntentCopyWith<$R, WaitIntent, $Out> {
  _WaitIntentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<WaitIntent> $mapper =
      WaitIntentMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  WaitIntent $make(CopyWithData data) => WaitIntent();

  @override
  WaitIntentCopyWith<$R2, WaitIntent, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _WaitIntentCopyWithImpl<$R2, $Out2>($value, $cast, t);
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
      IntentComponentMapper.ensureInitialized().addSubMapper(_instance!);
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
  late final ClassMapperBase superMapper =
      IntentComponentMapper.ensureInitialized();

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
    implements IntentComponentCopyWith<$R, $In, $Out> {
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

class PlayerMapper extends SubClassMapperBase<Player> {
  PlayerMapper._();

  static PlayerMapper? _instance;
  static PlayerMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PlayerMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'Player';

  @override
  final MappableFields<Player> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'Player';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static Player _instantiate(DecodingData data) {
    return Player();
  }

  @override
  final Function instantiate = _instantiate;

  static Player fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Player>(map);
  }

  static Player fromJson(String json) {
    return ensureInitialized().decodeJson<Player>(json);
  }
}

mixin PlayerMappable {
  String toJson() {
    return PlayerMapper.ensureInitialized().encodeJson<Player>(this as Player);
  }

  Map<String, dynamic> toMap() {
    return PlayerMapper.ensureInitialized().encodeMap<Player>(this as Player);
  }

  PlayerCopyWith<Player, Player, Player> get copyWith =>
      _PlayerCopyWithImpl<Player, Player>(this as Player, $identity, $identity);
  @override
  String toString() {
    return PlayerMapper.ensureInitialized().stringifyValue(this as Player);
  }

  @override
  bool operator ==(Object other) {
    return PlayerMapper.ensureInitialized().equalsValue(this as Player, other);
  }

  @override
  int get hashCode {
    return PlayerMapper.ensureInitialized().hashValue(this as Player);
  }
}

extension PlayerValueCopy<$R, $Out> on ObjectCopyWith<$R, Player, $Out> {
  PlayerCopyWith<$R, Player, $Out> get $asPlayer =>
      $base.as((v, t, t2) => _PlayerCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PlayerCopyWith<$R, $In extends Player, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call();
  PlayerCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PlayerCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Player, $Out>
    implements PlayerCopyWith<$R, Player, $Out> {
  _PlayerCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Player> $mapper = PlayerMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  Player $make(CopyWithData data) => Player();

  @override
  PlayerCopyWith<$R2, Player, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _PlayerCopyWithImpl<$R2, $Out2>($value, $cast, t);
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

class RenderableAssetMapper extends ClassMapperBase<RenderableAsset> {
  RenderableAssetMapper._();

  static RenderableAssetMapper? _instance;
  static RenderableAssetMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RenderableAssetMapper._());
      ImageAssetMapper.ensureInitialized();
      TextAssetMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'RenderableAsset';

  @override
  final MappableFields<RenderableAsset> fields = const {};

  static RenderableAsset _instantiate(DecodingData data) {
    throw MapperException.missingSubclass(
      'RenderableAsset',
      '__type',
      '${data.value['__type']}',
    );
  }

  @override
  final Function instantiate = _instantiate;

  static RenderableAsset fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<RenderableAsset>(map);
  }

  static RenderableAsset fromJson(String json) {
    return ensureInitialized().decodeJson<RenderableAsset>(json);
  }
}

mixin RenderableAssetMappable {
  String toJson();
  Map<String, dynamic> toMap();
  RenderableAssetCopyWith<RenderableAsset, RenderableAsset, RenderableAsset>
  get copyWith;
}

abstract class RenderableAssetCopyWith<$R, $In extends RenderableAsset, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  RenderableAssetCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class ImageAssetMapper extends SubClassMapperBase<ImageAsset> {
  ImageAssetMapper._();

  static ImageAssetMapper? _instance;
  static ImageAssetMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ImageAssetMapper._());
      RenderableAssetMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'ImageAsset';

  static String _$svgAssetPath(ImageAsset v) => v.svgAssetPath;
  static const Field<ImageAsset, String> _f$svgAssetPath = Field(
    'svgAssetPath',
    _$svgAssetPath,
  );
  static bool _$flipHorizontal(ImageAsset v) => v.flipHorizontal;
  static const Field<ImageAsset, bool> _f$flipHorizontal = Field(
    'flipHorizontal',
    _$flipHorizontal,
    opt: true,
    def: false,
  );
  static bool _$flipVertical(ImageAsset v) => v.flipVertical;
  static const Field<ImageAsset, bool> _f$flipVertical = Field(
    'flipVertical',
    _$flipVertical,
    opt: true,
    def: false,
  );
  static double _$rotationDegrees(ImageAsset v) => v.rotationDegrees;
  static const Field<ImageAsset, double> _f$rotationDegrees = Field(
    'rotationDegrees',
    _$rotationDegrees,
    opt: true,
    def: 0,
  );

  @override
  final MappableFields<ImageAsset> fields = const {
    #svgAssetPath: _f$svgAssetPath,
    #flipHorizontal: _f$flipHorizontal,
    #flipVertical: _f$flipVertical,
    #rotationDegrees: _f$rotationDegrees,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'ImageAsset';
  @override
  late final ClassMapperBase superMapper =
      RenderableAssetMapper.ensureInitialized();

  static ImageAsset _instantiate(DecodingData data) {
    return ImageAsset(
      data.dec(_f$svgAssetPath),
      flipHorizontal: data.dec(_f$flipHorizontal),
      flipVertical: data.dec(_f$flipVertical),
      rotationDegrees: data.dec(_f$rotationDegrees),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ImageAsset fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ImageAsset>(map);
  }

  static ImageAsset fromJson(String json) {
    return ensureInitialized().decodeJson<ImageAsset>(json);
  }
}

mixin ImageAssetMappable {
  String toJson() {
    return ImageAssetMapper.ensureInitialized().encodeJson<ImageAsset>(
      this as ImageAsset,
    );
  }

  Map<String, dynamic> toMap() {
    return ImageAssetMapper.ensureInitialized().encodeMap<ImageAsset>(
      this as ImageAsset,
    );
  }

  ImageAssetCopyWith<ImageAsset, ImageAsset, ImageAsset> get copyWith =>
      _ImageAssetCopyWithImpl<ImageAsset, ImageAsset>(
        this as ImageAsset,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ImageAssetMapper.ensureInitialized().stringifyValue(
      this as ImageAsset,
    );
  }

  @override
  bool operator ==(Object other) {
    return ImageAssetMapper.ensureInitialized().equalsValue(
      this as ImageAsset,
      other,
    );
  }

  @override
  int get hashCode {
    return ImageAssetMapper.ensureInitialized().hashValue(this as ImageAsset);
  }
}

extension ImageAssetValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ImageAsset, $Out> {
  ImageAssetCopyWith<$R, ImageAsset, $Out> get $asImageAsset =>
      $base.as((v, t, t2) => _ImageAssetCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ImageAssetCopyWith<$R, $In extends ImageAsset, $Out>
    implements RenderableAssetCopyWith<$R, $In, $Out> {
  @override
  $R call({
    String? svgAssetPath,
    bool? flipHorizontal,
    bool? flipVertical,
    double? rotationDegrees,
  });
  ImageAssetCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ImageAssetCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ImageAsset, $Out>
    implements ImageAssetCopyWith<$R, ImageAsset, $Out> {
  _ImageAssetCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ImageAsset> $mapper =
      ImageAssetMapper.ensureInitialized();
  @override
  $R call({
    String? svgAssetPath,
    bool? flipHorizontal,
    bool? flipVertical,
    double? rotationDegrees,
  }) => $apply(
    FieldCopyWithData({
      if (svgAssetPath != null) #svgAssetPath: svgAssetPath,
      if (flipHorizontal != null) #flipHorizontal: flipHorizontal,
      if (flipVertical != null) #flipVertical: flipVertical,
      if (rotationDegrees != null) #rotationDegrees: rotationDegrees,
    }),
  );
  @override
  ImageAsset $make(CopyWithData data) => ImageAsset(
    data.get(#svgAssetPath, or: $value.svgAssetPath),
    flipHorizontal: data.get(#flipHorizontal, or: $value.flipHorizontal),
    flipVertical: data.get(#flipVertical, or: $value.flipVertical),
    rotationDegrees: data.get(#rotationDegrees, or: $value.rotationDegrees),
  );

  @override
  ImageAssetCopyWith<$R2, ImageAsset, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ImageAssetCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class TextAssetMapper extends SubClassMapperBase<TextAsset> {
  TextAssetMapper._();

  static TextAssetMapper? _instance;
  static TextAssetMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TextAssetMapper._());
      RenderableAssetMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'TextAsset';

  static String _$text(TextAsset v) => v.text;
  static const Field<TextAsset, String> _f$text = Field('text', _$text);
  static double _$fontSize(TextAsset v) => v.fontSize;
  static const Field<TextAsset, double> _f$fontSize = Field(
    'fontSize',
    _$fontSize,
    opt: true,
    def: 16,
  );
  static int _$color(TextAsset v) => v.color;
  static const Field<TextAsset, int> _f$color = Field(
    'color',
    _$color,
    opt: true,
    def: 0xFFFFFFFF,
  );

  @override
  final MappableFields<TextAsset> fields = const {
    #text: _f$text,
    #fontSize: _f$fontSize,
    #color: _f$color,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'TextAsset';
  @override
  late final ClassMapperBase superMapper =
      RenderableAssetMapper.ensureInitialized();

  static TextAsset _instantiate(DecodingData data) {
    return TextAsset(
      text: data.dec(_f$text),
      fontSize: data.dec(_f$fontSize),
      color: data.dec(_f$color),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TextAsset fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TextAsset>(map);
  }

  static TextAsset fromJson(String json) {
    return ensureInitialized().decodeJson<TextAsset>(json);
  }
}

mixin TextAssetMappable {
  String toJson() {
    return TextAssetMapper.ensureInitialized().encodeJson<TextAsset>(
      this as TextAsset,
    );
  }

  Map<String, dynamic> toMap() {
    return TextAssetMapper.ensureInitialized().encodeMap<TextAsset>(
      this as TextAsset,
    );
  }

  TextAssetCopyWith<TextAsset, TextAsset, TextAsset> get copyWith =>
      _TextAssetCopyWithImpl<TextAsset, TextAsset>(
        this as TextAsset,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return TextAssetMapper.ensureInitialized().stringifyValue(
      this as TextAsset,
    );
  }

  @override
  bool operator ==(Object other) {
    return TextAssetMapper.ensureInitialized().equalsValue(
      this as TextAsset,
      other,
    );
  }

  @override
  int get hashCode {
    return TextAssetMapper.ensureInitialized().hashValue(this as TextAsset);
  }
}

extension TextAssetValueCopy<$R, $Out> on ObjectCopyWith<$R, TextAsset, $Out> {
  TextAssetCopyWith<$R, TextAsset, $Out> get $asTextAsset =>
      $base.as((v, t, t2) => _TextAssetCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TextAssetCopyWith<$R, $In extends TextAsset, $Out>
    implements RenderableAssetCopyWith<$R, $In, $Out> {
  @override
  $R call({String? text, double? fontSize, int? color});
  TextAssetCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _TextAssetCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TextAsset, $Out>
    implements TextAssetCopyWith<$R, TextAsset, $Out> {
  _TextAssetCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TextAsset> $mapper =
      TextAssetMapper.ensureInitialized();
  @override
  $R call({String? text, double? fontSize, int? color}) => $apply(
    FieldCopyWithData({
      if (text != null) #text: text,
      if (fontSize != null) #fontSize: fontSize,
      if (color != null) #color: color,
    }),
  );
  @override
  TextAsset $make(CopyWithData data) => TextAsset(
    text: data.get(#text, or: $value.text),
    fontSize: data.get(#fontSize, or: $value.fontSize),
    color: data.get(#color, or: $value.color),
  );

  @override
  TextAssetCopyWith<$R2, TextAsset, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TextAssetCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class RenderableMapper extends SubClassMapperBase<Renderable> {
  RenderableMapper._();

  static RenderableMapper? _instance;
  static RenderableMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RenderableMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
      RenderableAssetMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Renderable';

  static RenderableAsset _$asset(Renderable v) => v.asset;
  static const Field<Renderable, RenderableAsset> _f$asset = Field(
    'asset',
    _$asset,
  );

  @override
  final MappableFields<Renderable> fields = const {#asset: _f$asset};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'Renderable';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static Renderable _instantiate(DecodingData data) {
    return Renderable(data.dec(_f$asset));
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
  RenderableAssetCopyWith<$R, RenderableAsset, RenderableAsset> get asset;
  @override
  $R call({RenderableAsset? asset});
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
  RenderableAssetCopyWith<$R, RenderableAsset, RenderableAsset> get asset =>
      $value.asset.copyWith.$chain((v) => call(asset: v));
  @override
  $R call({RenderableAsset? asset}) =>
      $apply(FieldCopyWithData({if (asset != null) #asset: asset}));
  @override
  Renderable $make(CopyWithData data) =>
      Renderable(data.get(#asset, or: $value.asset));

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
      IntentComponentMapper.ensureInitialized().addSubMapper(_instance!);
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
  static int _$lifetime(AttackIntent v) => v.lifetime;
  static const Field<AttackIntent, int> _f$lifetime = Field(
    'lifetime',
    _$lifetime,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<AttackIntent> fields = const {
    #targetId: _f$targetId,
    #lifetime: _f$lifetime,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'AttackIntent';
  @override
  late final ClassMapperBase superMapper =
      IntentComponentMapper.ensureInitialized();

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
    implements IntentComponentCopyWith<$R, $In, $Out> {
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
      IntentComponentMapper.ensureInitialized().addSubMapper(_instance!);
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
  late final ClassMapperBase superMapper =
      IntentComponentMapper.ensureInitialized();

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
    implements IntentComponentCopyWith<$R, $In, $Out> {
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

class BlocksSightMapper extends SubClassMapperBase<BlocksSight> {
  BlocksSightMapper._();

  static BlocksSightMapper? _instance;
  static BlocksSightMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = BlocksSightMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'BlocksSight';

  @override
  final MappableFields<BlocksSight> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'BlocksSight';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static BlocksSight _instantiate(DecodingData data) {
    return BlocksSight();
  }

  @override
  final Function instantiate = _instantiate;

  static BlocksSight fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<BlocksSight>(map);
  }

  static BlocksSight fromJson(String json) {
    return ensureInitialized().decodeJson<BlocksSight>(json);
  }
}

mixin BlocksSightMappable {
  String toJson() {
    return BlocksSightMapper.ensureInitialized().encodeJson<BlocksSight>(
      this as BlocksSight,
    );
  }

  Map<String, dynamic> toMap() {
    return BlocksSightMapper.ensureInitialized().encodeMap<BlocksSight>(
      this as BlocksSight,
    );
  }

  BlocksSightCopyWith<BlocksSight, BlocksSight, BlocksSight> get copyWith =>
      _BlocksSightCopyWithImpl<BlocksSight, BlocksSight>(
        this as BlocksSight,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return BlocksSightMapper.ensureInitialized().stringifyValue(
      this as BlocksSight,
    );
  }

  @override
  bool operator ==(Object other) {
    return BlocksSightMapper.ensureInitialized().equalsValue(
      this as BlocksSight,
      other,
    );
  }

  @override
  int get hashCode {
    return BlocksSightMapper.ensureInitialized().hashValue(this as BlocksSight);
  }
}

extension BlocksSightValueCopy<$R, $Out>
    on ObjectCopyWith<$R, BlocksSight, $Out> {
  BlocksSightCopyWith<$R, BlocksSight, $Out> get $asBlocksSight =>
      $base.as((v, t, t2) => _BlocksSightCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class BlocksSightCopyWith<$R, $In extends BlocksSight, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call();
  BlocksSightCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _BlocksSightCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, BlocksSight, $Out>
    implements BlocksSightCopyWith<$R, BlocksSight, $Out> {
  _BlocksSightCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<BlocksSight> $mapper =
      BlocksSightMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  BlocksSight $make(CopyWithData data) => BlocksSight();

  @override
  BlocksSightCopyWith<$R2, BlocksSight, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _BlocksSightCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class VisionRadiusMapper extends SubClassMapperBase<VisionRadius> {
  VisionRadiusMapper._();

  static VisionRadiusMapper? _instance;
  static VisionRadiusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = VisionRadiusMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'VisionRadius';

  static int _$radius(VisionRadius v) => v.radius;
  static const Field<VisionRadius, int> _f$radius = Field('radius', _$radius);
  static int _$fieldOfViewDegrees(VisionRadius v) => v.fieldOfViewDegrees;
  static const Field<VisionRadius, int> _f$fieldOfViewDegrees = Field(
    'fieldOfViewDegrees',
    _$fieldOfViewDegrees,
    opt: true,
    def: 360,
  );

  @override
  final MappableFields<VisionRadius> fields = const {
    #radius: _f$radius,
    #fieldOfViewDegrees: _f$fieldOfViewDegrees,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'VisionRadius';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static VisionRadius _instantiate(DecodingData data) {
    return VisionRadius(
      radius: data.dec(_f$radius),
      fieldOfViewDegrees: data.dec(_f$fieldOfViewDegrees),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static VisionRadius fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<VisionRadius>(map);
  }

  static VisionRadius fromJson(String json) {
    return ensureInitialized().decodeJson<VisionRadius>(json);
  }
}

mixin VisionRadiusMappable {
  String toJson() {
    return VisionRadiusMapper.ensureInitialized().encodeJson<VisionRadius>(
      this as VisionRadius,
    );
  }

  Map<String, dynamic> toMap() {
    return VisionRadiusMapper.ensureInitialized().encodeMap<VisionRadius>(
      this as VisionRadius,
    );
  }

  VisionRadiusCopyWith<VisionRadius, VisionRadius, VisionRadius> get copyWith =>
      _VisionRadiusCopyWithImpl<VisionRadius, VisionRadius>(
        this as VisionRadius,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return VisionRadiusMapper.ensureInitialized().stringifyValue(
      this as VisionRadius,
    );
  }

  @override
  bool operator ==(Object other) {
    return VisionRadiusMapper.ensureInitialized().equalsValue(
      this as VisionRadius,
      other,
    );
  }

  @override
  int get hashCode {
    return VisionRadiusMapper.ensureInitialized().hashValue(
      this as VisionRadius,
    );
  }
}

extension VisionRadiusValueCopy<$R, $Out>
    on ObjectCopyWith<$R, VisionRadius, $Out> {
  VisionRadiusCopyWith<$R, VisionRadius, $Out> get $asVisionRadius =>
      $base.as((v, t, t2) => _VisionRadiusCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class VisionRadiusCopyWith<$R, $In extends VisionRadius, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call({int? radius, int? fieldOfViewDegrees});
  VisionRadiusCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _VisionRadiusCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, VisionRadius, $Out>
    implements VisionRadiusCopyWith<$R, VisionRadius, $Out> {
  _VisionRadiusCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<VisionRadius> $mapper =
      VisionRadiusMapper.ensureInitialized();
  @override
  $R call({int? radius, int? fieldOfViewDegrees}) => $apply(
    FieldCopyWithData({
      if (radius != null) #radius: radius,
      if (fieldOfViewDegrees != null) #fieldOfViewDegrees: fieldOfViewDegrees,
    }),
  );
  @override
  VisionRadius $make(CopyWithData data) => VisionRadius(
    radius: data.get(#radius, or: $value.radius),
    fieldOfViewDegrees: data.get(
      #fieldOfViewDegrees,
      or: $value.fieldOfViewDegrees,
    ),
  );

  @override
  VisionRadiusCopyWith<$R2, VisionRadius, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _VisionRadiusCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class VisibleEntitiesMapper extends SubClassMapperBase<VisibleEntities> {
  VisibleEntitiesMapper._();

  static VisibleEntitiesMapper? _instance;
  static VisibleEntitiesMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = VisibleEntitiesMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
      LocalPositionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'VisibleEntities';

  static Set<int> _$entityIds(VisibleEntities v) => v.entityIds;
  static const Field<VisibleEntities, Set<int>> _f$entityIds = Field(
    'entityIds',
    _$entityIds,
    opt: true,
  );
  static Set<LocalPosition> _$visibleTiles(VisibleEntities v) => v.visibleTiles;
  static const Field<VisibleEntities, Set<LocalPosition>> _f$visibleTiles =
      Field('visibleTiles', _$visibleTiles, opt: true);

  @override
  final MappableFields<VisibleEntities> fields = const {
    #entityIds: _f$entityIds,
    #visibleTiles: _f$visibleTiles,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'VisibleEntities';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static VisibleEntities _instantiate(DecodingData data) {
    return VisibleEntities(
      entityIds: data.dec(_f$entityIds),
      visibleTiles: data.dec(_f$visibleTiles),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static VisibleEntities fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<VisibleEntities>(map);
  }

  static VisibleEntities fromJson(String json) {
    return ensureInitialized().decodeJson<VisibleEntities>(json);
  }
}

mixin VisibleEntitiesMappable {
  String toJson() {
    return VisibleEntitiesMapper.ensureInitialized()
        .encodeJson<VisibleEntities>(this as VisibleEntities);
  }

  Map<String, dynamic> toMap() {
    return VisibleEntitiesMapper.ensureInitialized().encodeMap<VisibleEntities>(
      this as VisibleEntities,
    );
  }

  VisibleEntitiesCopyWith<VisibleEntities, VisibleEntities, VisibleEntities>
  get copyWith =>
      _VisibleEntitiesCopyWithImpl<VisibleEntities, VisibleEntities>(
        this as VisibleEntities,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return VisibleEntitiesMapper.ensureInitialized().stringifyValue(
      this as VisibleEntities,
    );
  }

  @override
  bool operator ==(Object other) {
    return VisibleEntitiesMapper.ensureInitialized().equalsValue(
      this as VisibleEntities,
      other,
    );
  }

  @override
  int get hashCode {
    return VisibleEntitiesMapper.ensureInitialized().hashValue(
      this as VisibleEntities,
    );
  }
}

extension VisibleEntitiesValueCopy<$R, $Out>
    on ObjectCopyWith<$R, VisibleEntities, $Out> {
  VisibleEntitiesCopyWith<$R, VisibleEntities, $Out> get $asVisibleEntities =>
      $base.as((v, t, t2) => _VisibleEntitiesCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class VisibleEntitiesCopyWith<$R, $In extends VisibleEntities, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call({Set<int>? entityIds, Set<LocalPosition>? visibleTiles});
  VisibleEntitiesCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _VisibleEntitiesCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, VisibleEntities, $Out>
    implements VisibleEntitiesCopyWith<$R, VisibleEntities, $Out> {
  _VisibleEntitiesCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<VisibleEntities> $mapper =
      VisibleEntitiesMapper.ensureInitialized();
  @override
  $R call({Object? entityIds = $none, Object? visibleTiles = $none}) => $apply(
    FieldCopyWithData({
      if (entityIds != $none) #entityIds: entityIds,
      if (visibleTiles != $none) #visibleTiles: visibleTiles,
    }),
  );
  @override
  VisibleEntities $make(CopyWithData data) => VisibleEntities(
    entityIds: data.get(#entityIds, or: $value.entityIds),
    visibleTiles: data.get(#visibleTiles, or: $value.visibleTiles),
  );

  @override
  VisibleEntitiesCopyWith<$R2, VisibleEntities, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _VisibleEntitiesCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class VisionMemoryMapper extends SubClassMapperBase<VisionMemory> {
  VisionMemoryMapper._();

  static VisionMemoryMapper? _instance;
  static VisionMemoryMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = VisionMemoryMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
      LocalPositionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'VisionMemory';

  static Map<String, LocalPosition> _$lastSeenPositions(VisionMemory v) =>
      v.lastSeenPositions;
  static const Field<VisionMemory, Map<String, LocalPosition>>
  _f$lastSeenPositions = Field(
    'lastSeenPositions',
    _$lastSeenPositions,
    opt: true,
  );

  @override
  final MappableFields<VisionMemory> fields = const {
    #lastSeenPositions: _f$lastSeenPositions,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'VisionMemory';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static VisionMemory _instantiate(DecodingData data) {
    return VisionMemory(lastSeenPositions: data.dec(_f$lastSeenPositions));
  }

  @override
  final Function instantiate = _instantiate;

  static VisionMemory fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<VisionMemory>(map);
  }

  static VisionMemory fromJson(String json) {
    return ensureInitialized().decodeJson<VisionMemory>(json);
  }
}

mixin VisionMemoryMappable {
  String toJson() {
    return VisionMemoryMapper.ensureInitialized().encodeJson<VisionMemory>(
      this as VisionMemory,
    );
  }

  Map<String, dynamic> toMap() {
    return VisionMemoryMapper.ensureInitialized().encodeMap<VisionMemory>(
      this as VisionMemory,
    );
  }

  VisionMemoryCopyWith<VisionMemory, VisionMemory, VisionMemory> get copyWith =>
      _VisionMemoryCopyWithImpl<VisionMemory, VisionMemory>(
        this as VisionMemory,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return VisionMemoryMapper.ensureInitialized().stringifyValue(
      this as VisionMemory,
    );
  }

  @override
  bool operator ==(Object other) {
    return VisionMemoryMapper.ensureInitialized().equalsValue(
      this as VisionMemory,
      other,
    );
  }

  @override
  int get hashCode {
    return VisionMemoryMapper.ensureInitialized().hashValue(
      this as VisionMemory,
    );
  }
}

extension VisionMemoryValueCopy<$R, $Out>
    on ObjectCopyWith<$R, VisionMemory, $Out> {
  VisionMemoryCopyWith<$R, VisionMemory, $Out> get $asVisionMemory =>
      $base.as((v, t, t2) => _VisionMemoryCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class VisionMemoryCopyWith<$R, $In extends VisionMemory, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  MapCopyWith<
    $R,
    String,
    LocalPosition,
    LocalPositionCopyWith<$R, LocalPosition, LocalPosition>
  >
  get lastSeenPositions;
  @override
  $R call({Map<String, LocalPosition>? lastSeenPositions});
  VisionMemoryCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _VisionMemoryCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, VisionMemory, $Out>
    implements VisionMemoryCopyWith<$R, VisionMemory, $Out> {
  _VisionMemoryCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<VisionMemory> $mapper =
      VisionMemoryMapper.ensureInitialized();
  @override
  MapCopyWith<
    $R,
    String,
    LocalPosition,
    LocalPositionCopyWith<$R, LocalPosition, LocalPosition>
  >
  get lastSeenPositions => MapCopyWith(
    $value.lastSeenPositions,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(lastSeenPositions: v),
  );
  @override
  $R call({Object? lastSeenPositions = $none}) => $apply(
    FieldCopyWithData({
      if (lastSeenPositions != $none) #lastSeenPositions: lastSeenPositions,
    }),
  );
  @override
  VisionMemory $make(CopyWithData data) => VisionMemory(
    lastSeenPositions: data.get(
      #lastSeenPositions,
      or: $value.lastSeenPositions,
    ),
  );

  @override
  VisionMemoryCopyWith<$R2, VisionMemory, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _VisionMemoryCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class HasParentMapper extends SubClassMapperBase<HasParent> {
  HasParentMapper._();

  static HasParentMapper? _instance;
  static HasParentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = HasParentMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'HasParent';

  static int _$parentEntityId(HasParent v) => v.parentEntityId;
  static const Field<HasParent, int> _f$parentEntityId = Field(
    'parentEntityId',
    _$parentEntityId,
  );

  @override
  final MappableFields<HasParent> fields = const {
    #parentEntityId: _f$parentEntityId,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'HasParent';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static HasParent _instantiate(DecodingData data) {
    return HasParent(data.dec(_f$parentEntityId));
  }

  @override
  final Function instantiate = _instantiate;

  static HasParent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<HasParent>(map);
  }

  static HasParent fromJson(String json) {
    return ensureInitialized().decodeJson<HasParent>(json);
  }
}

mixin HasParentMappable {
  String toJson() {
    return HasParentMapper.ensureInitialized().encodeJson<HasParent>(
      this as HasParent,
    );
  }

  Map<String, dynamic> toMap() {
    return HasParentMapper.ensureInitialized().encodeMap<HasParent>(
      this as HasParent,
    );
  }

  HasParentCopyWith<HasParent, HasParent, HasParent> get copyWith =>
      _HasParentCopyWithImpl<HasParent, HasParent>(
        this as HasParent,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return HasParentMapper.ensureInitialized().stringifyValue(
      this as HasParent,
    );
  }

  @override
  bool operator ==(Object other) {
    return HasParentMapper.ensureInitialized().equalsValue(
      this as HasParent,
      other,
    );
  }

  @override
  int get hashCode {
    return HasParentMapper.ensureInitialized().hashValue(this as HasParent);
  }
}

extension HasParentValueCopy<$R, $Out> on ObjectCopyWith<$R, HasParent, $Out> {
  HasParentCopyWith<$R, HasParent, $Out> get $asHasParent =>
      $base.as((v, t, t2) => _HasParentCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class HasParentCopyWith<$R, $In extends HasParent, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call({int? parentEntityId});
  HasParentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _HasParentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, HasParent, $Out>
    implements HasParentCopyWith<$R, HasParent, $Out> {
  _HasParentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<HasParent> $mapper =
      HasParentMapper.ensureInitialized();
  @override
  $R call({int? parentEntityId}) => $apply(
    FieldCopyWithData({
      if (parentEntityId != null) #parentEntityId: parentEntityId,
    }),
  );
  @override
  HasParent $make(CopyWithData data) =>
      HasParent(data.get(#parentEntityId, or: $value.parentEntityId));

  @override
  HasParentCopyWith<$R2, HasParent, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _HasParentCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class PortalToPositionMapper extends SubClassMapperBase<PortalToPosition> {
  PortalToPositionMapper._();

  static PortalToPositionMapper? _instance;
  static PortalToPositionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PortalToPositionMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
      LocalPositionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PortalToPosition';

  static int _$destParentId(PortalToPosition v) => v.destParentId;
  static const Field<PortalToPosition, int> _f$destParentId = Field(
    'destParentId',
    _$destParentId,
  );
  static LocalPosition _$destLocation(PortalToPosition v) => v.destLocation;
  static const Field<PortalToPosition, LocalPosition> _f$destLocation = Field(
    'destLocation',
    _$destLocation,
  );
  static int _$interactionRange(PortalToPosition v) => v.interactionRange;
  static const Field<PortalToPosition, int> _f$interactionRange = Field(
    'interactionRange',
    _$interactionRange,
    opt: true,
    def: 0,
  );

  @override
  final MappableFields<PortalToPosition> fields = const {
    #destParentId: _f$destParentId,
    #destLocation: _f$destLocation,
    #interactionRange: _f$interactionRange,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'PortalToPosition';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static PortalToPosition _instantiate(DecodingData data) {
    return PortalToPosition(
      destParentId: data.dec(_f$destParentId),
      destLocation: data.dec(_f$destLocation),
      interactionRange: data.dec(_f$interactionRange),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PortalToPosition fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PortalToPosition>(map);
  }

  static PortalToPosition fromJson(String json) {
    return ensureInitialized().decodeJson<PortalToPosition>(json);
  }
}

mixin PortalToPositionMappable {
  String toJson() {
    return PortalToPositionMapper.ensureInitialized()
        .encodeJson<PortalToPosition>(this as PortalToPosition);
  }

  Map<String, dynamic> toMap() {
    return PortalToPositionMapper.ensureInitialized()
        .encodeMap<PortalToPosition>(this as PortalToPosition);
  }

  PortalToPositionCopyWith<PortalToPosition, PortalToPosition, PortalToPosition>
  get copyWith =>
      _PortalToPositionCopyWithImpl<PortalToPosition, PortalToPosition>(
        this as PortalToPosition,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PortalToPositionMapper.ensureInitialized().stringifyValue(
      this as PortalToPosition,
    );
  }

  @override
  bool operator ==(Object other) {
    return PortalToPositionMapper.ensureInitialized().equalsValue(
      this as PortalToPosition,
      other,
    );
  }

  @override
  int get hashCode {
    return PortalToPositionMapper.ensureInitialized().hashValue(
      this as PortalToPosition,
    );
  }
}

extension PortalToPositionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PortalToPosition, $Out> {
  PortalToPositionCopyWith<$R, PortalToPosition, $Out>
  get $asPortalToPosition =>
      $base.as((v, t, t2) => _PortalToPositionCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PortalToPositionCopyWith<$R, $In extends PortalToPosition, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  LocalPositionCopyWith<$R, LocalPosition, LocalPosition> get destLocation;
  @override
  $R call({
    int? destParentId,
    LocalPosition? destLocation,
    int? interactionRange,
  });
  PortalToPositionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _PortalToPositionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PortalToPosition, $Out>
    implements PortalToPositionCopyWith<$R, PortalToPosition, $Out> {
  _PortalToPositionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PortalToPosition> $mapper =
      PortalToPositionMapper.ensureInitialized();
  @override
  LocalPositionCopyWith<$R, LocalPosition, LocalPosition> get destLocation =>
      $value.destLocation.copyWith.$chain((v) => call(destLocation: v));
  @override
  $R call({
    int? destParentId,
    LocalPosition? destLocation,
    int? interactionRange,
  }) => $apply(
    FieldCopyWithData({
      if (destParentId != null) #destParentId: destParentId,
      if (destLocation != null) #destLocation: destLocation,
      if (interactionRange != null) #interactionRange: interactionRange,
    }),
  );
  @override
  PortalToPosition $make(CopyWithData data) => PortalToPosition(
    destParentId: data.get(#destParentId, or: $value.destParentId),
    destLocation: data.get(#destLocation, or: $value.destLocation),
    interactionRange: data.get(#interactionRange, or: $value.interactionRange),
  );

  @override
  PortalToPositionCopyWith<$R2, PortalToPosition, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PortalToPositionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class PortalToAnchorMapper extends SubClassMapperBase<PortalToAnchor> {
  PortalToAnchorMapper._();

  static PortalToAnchorMapper? _instance;
  static PortalToAnchorMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PortalToAnchorMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'PortalToAnchor';

  static List<int> _$destAnchorEntityIds(PortalToAnchor v) =>
      v.destAnchorEntityIds;
  static const Field<PortalToAnchor, List<int>> _f$destAnchorEntityIds = Field(
    'destAnchorEntityIds',
    _$destAnchorEntityIds,
  );
  static int _$offsetX(PortalToAnchor v) => v.offsetX;
  static const Field<PortalToAnchor, int> _f$offsetX = Field(
    'offsetX',
    _$offsetX,
    opt: true,
    def: 0,
  );
  static int _$offsetY(PortalToAnchor v) => v.offsetY;
  static const Field<PortalToAnchor, int> _f$offsetY = Field(
    'offsetY',
    _$offsetY,
    opt: true,
    def: 0,
  );
  static int _$interactionRange(PortalToAnchor v) => v.interactionRange;
  static const Field<PortalToAnchor, int> _f$interactionRange = Field(
    'interactionRange',
    _$interactionRange,
    opt: true,
    def: 0,
  );

  @override
  final MappableFields<PortalToAnchor> fields = const {
    #destAnchorEntityIds: _f$destAnchorEntityIds,
    #offsetX: _f$offsetX,
    #offsetY: _f$offsetY,
    #interactionRange: _f$interactionRange,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'PortalToAnchor';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static PortalToAnchor _instantiate(DecodingData data) {
    return PortalToAnchor(
      destAnchorEntityIds: data.dec(_f$destAnchorEntityIds),
      offsetX: data.dec(_f$offsetX),
      offsetY: data.dec(_f$offsetY),
      interactionRange: data.dec(_f$interactionRange),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PortalToAnchor fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PortalToAnchor>(map);
  }

  static PortalToAnchor fromJson(String json) {
    return ensureInitialized().decodeJson<PortalToAnchor>(json);
  }
}

mixin PortalToAnchorMappable {
  String toJson() {
    return PortalToAnchorMapper.ensureInitialized().encodeJson<PortalToAnchor>(
      this as PortalToAnchor,
    );
  }

  Map<String, dynamic> toMap() {
    return PortalToAnchorMapper.ensureInitialized().encodeMap<PortalToAnchor>(
      this as PortalToAnchor,
    );
  }

  PortalToAnchorCopyWith<PortalToAnchor, PortalToAnchor, PortalToAnchor>
  get copyWith => _PortalToAnchorCopyWithImpl<PortalToAnchor, PortalToAnchor>(
    this as PortalToAnchor,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return PortalToAnchorMapper.ensureInitialized().stringifyValue(
      this as PortalToAnchor,
    );
  }

  @override
  bool operator ==(Object other) {
    return PortalToAnchorMapper.ensureInitialized().equalsValue(
      this as PortalToAnchor,
      other,
    );
  }

  @override
  int get hashCode {
    return PortalToAnchorMapper.ensureInitialized().hashValue(
      this as PortalToAnchor,
    );
  }
}

extension PortalToAnchorValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PortalToAnchor, $Out> {
  PortalToAnchorCopyWith<$R, PortalToAnchor, $Out> get $asPortalToAnchor =>
      $base.as((v, t, t2) => _PortalToAnchorCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PortalToAnchorCopyWith<$R, $In extends PortalToAnchor, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, int, ObjectCopyWith<$R, int, int>> get destAnchorEntityIds;
  @override
  $R call({
    List<int>? destAnchorEntityIds,
    int? offsetX,
    int? offsetY,
    int? interactionRange,
  });
  PortalToAnchorCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _PortalToAnchorCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PortalToAnchor, $Out>
    implements PortalToAnchorCopyWith<$R, PortalToAnchor, $Out> {
  _PortalToAnchorCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PortalToAnchor> $mapper =
      PortalToAnchorMapper.ensureInitialized();
  @override
  ListCopyWith<$R, int, ObjectCopyWith<$R, int, int>> get destAnchorEntityIds =>
      ListCopyWith(
        $value.destAnchorEntityIds,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(destAnchorEntityIds: v),
      );
  @override
  $R call({
    List<int>? destAnchorEntityIds,
    int? offsetX,
    int? offsetY,
    int? interactionRange,
  }) => $apply(
    FieldCopyWithData({
      if (destAnchorEntityIds != null)
        #destAnchorEntityIds: destAnchorEntityIds,
      if (offsetX != null) #offsetX: offsetX,
      if (offsetY != null) #offsetY: offsetY,
      if (interactionRange != null) #interactionRange: interactionRange,
    }),
  );
  @override
  PortalToAnchor $make(CopyWithData data) => PortalToAnchor(
    destAnchorEntityIds: data.get(
      #destAnchorEntityIds,
      or: $value.destAnchorEntityIds,
    ),
    offsetX: data.get(#offsetX, or: $value.offsetX),
    offsetY: data.get(#offsetY, or: $value.offsetY),
    interactionRange: data.get(#interactionRange, or: $value.interactionRange),
  );

  @override
  PortalToAnchorCopyWith<$R2, PortalToAnchor, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PortalToAnchorCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class PortalAnchorMapper extends SubClassMapperBase<PortalAnchor> {
  PortalAnchorMapper._();

  static PortalAnchorMapper? _instance;
  static PortalAnchorMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PortalAnchorMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'PortalAnchor';

  static String? _$anchorName(PortalAnchor v) => v.anchorName;
  static const Field<PortalAnchor, String> _f$anchorName = Field(
    'anchorName',
    _$anchorName,
    opt: true,
  );

  @override
  final MappableFields<PortalAnchor> fields = const {
    #anchorName: _f$anchorName,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'PortalAnchor';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static PortalAnchor _instantiate(DecodingData data) {
    return PortalAnchor(anchorName: data.dec(_f$anchorName));
  }

  @override
  final Function instantiate = _instantiate;

  static PortalAnchor fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PortalAnchor>(map);
  }

  static PortalAnchor fromJson(String json) {
    return ensureInitialized().decodeJson<PortalAnchor>(json);
  }
}

mixin PortalAnchorMappable {
  String toJson() {
    return PortalAnchorMapper.ensureInitialized().encodeJson<PortalAnchor>(
      this as PortalAnchor,
    );
  }

  Map<String, dynamic> toMap() {
    return PortalAnchorMapper.ensureInitialized().encodeMap<PortalAnchor>(
      this as PortalAnchor,
    );
  }

  PortalAnchorCopyWith<PortalAnchor, PortalAnchor, PortalAnchor> get copyWith =>
      _PortalAnchorCopyWithImpl<PortalAnchor, PortalAnchor>(
        this as PortalAnchor,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PortalAnchorMapper.ensureInitialized().stringifyValue(
      this as PortalAnchor,
    );
  }

  @override
  bool operator ==(Object other) {
    return PortalAnchorMapper.ensureInitialized().equalsValue(
      this as PortalAnchor,
      other,
    );
  }

  @override
  int get hashCode {
    return PortalAnchorMapper.ensureInitialized().hashValue(
      this as PortalAnchor,
    );
  }
}

extension PortalAnchorValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PortalAnchor, $Out> {
  PortalAnchorCopyWith<$R, PortalAnchor, $Out> get $asPortalAnchor =>
      $base.as((v, t, t2) => _PortalAnchorCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PortalAnchorCopyWith<$R, $In extends PortalAnchor, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call({String? anchorName});
  PortalAnchorCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PortalAnchorCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PortalAnchor, $Out>
    implements PortalAnchorCopyWith<$R, PortalAnchor, $Out> {
  _PortalAnchorCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PortalAnchor> $mapper =
      PortalAnchorMapper.ensureInitialized();
  @override
  $R call({Object? anchorName = $none}) => $apply(
    FieldCopyWithData({if (anchorName != $none) #anchorName: anchorName}),
  );
  @override
  PortalAnchor $make(CopyWithData data) =>
      PortalAnchor(anchorName: data.get(#anchorName, or: $value.anchorName));

  @override
  PortalAnchorCopyWith<$R2, PortalAnchor, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PortalAnchorCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class UsePortalIntentMapper extends SubClassMapperBase<UsePortalIntent> {
  UsePortalIntentMapper._();

  static UsePortalIntentMapper? _instance;
  static UsePortalIntentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UsePortalIntentMapper._());
      IntentComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'UsePortalIntent';

  static int _$portalEntityId(UsePortalIntent v) => v.portalEntityId;
  static const Field<UsePortalIntent, int> _f$portalEntityId = Field(
    'portalEntityId',
    _$portalEntityId,
  );
  static int? _$specificAnchorId(UsePortalIntent v) => v.specificAnchorId;
  static const Field<UsePortalIntent, int> _f$specificAnchorId = Field(
    'specificAnchorId',
    _$specificAnchorId,
    opt: true,
  );
  static int _$lifetime(UsePortalIntent v) => v.lifetime;
  static const Field<UsePortalIntent, int> _f$lifetime = Field(
    'lifetime',
    _$lifetime,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<UsePortalIntent> fields = const {
    #portalEntityId: _f$portalEntityId,
    #specificAnchorId: _f$specificAnchorId,
    #lifetime: _f$lifetime,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'UsePortalIntent';
  @override
  late final ClassMapperBase superMapper =
      IntentComponentMapper.ensureInitialized();

  static UsePortalIntent _instantiate(DecodingData data) {
    return UsePortalIntent(
      portalEntityId: data.dec(_f$portalEntityId),
      specificAnchorId: data.dec(_f$specificAnchorId),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static UsePortalIntent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<UsePortalIntent>(map);
  }

  static UsePortalIntent fromJson(String json) {
    return ensureInitialized().decodeJson<UsePortalIntent>(json);
  }
}

mixin UsePortalIntentMappable {
  String toJson() {
    return UsePortalIntentMapper.ensureInitialized()
        .encodeJson<UsePortalIntent>(this as UsePortalIntent);
  }

  Map<String, dynamic> toMap() {
    return UsePortalIntentMapper.ensureInitialized().encodeMap<UsePortalIntent>(
      this as UsePortalIntent,
    );
  }

  UsePortalIntentCopyWith<UsePortalIntent, UsePortalIntent, UsePortalIntent>
  get copyWith =>
      _UsePortalIntentCopyWithImpl<UsePortalIntent, UsePortalIntent>(
        this as UsePortalIntent,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return UsePortalIntentMapper.ensureInitialized().stringifyValue(
      this as UsePortalIntent,
    );
  }

  @override
  bool operator ==(Object other) {
    return UsePortalIntentMapper.ensureInitialized().equalsValue(
      this as UsePortalIntent,
      other,
    );
  }

  @override
  int get hashCode {
    return UsePortalIntentMapper.ensureInitialized().hashValue(
      this as UsePortalIntent,
    );
  }
}

extension UsePortalIntentValueCopy<$R, $Out>
    on ObjectCopyWith<$R, UsePortalIntent, $Out> {
  UsePortalIntentCopyWith<$R, UsePortalIntent, $Out> get $asUsePortalIntent =>
      $base.as((v, t, t2) => _UsePortalIntentCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class UsePortalIntentCopyWith<$R, $In extends UsePortalIntent, $Out>
    implements IntentComponentCopyWith<$R, $In, $Out> {
  @override
  $R call({int? portalEntityId, int? specificAnchorId});
  UsePortalIntentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _UsePortalIntentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, UsePortalIntent, $Out>
    implements UsePortalIntentCopyWith<$R, UsePortalIntent, $Out> {
  _UsePortalIntentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<UsePortalIntent> $mapper =
      UsePortalIntentMapper.ensureInitialized();
  @override
  $R call({int? portalEntityId, Object? specificAnchorId = $none}) => $apply(
    FieldCopyWithData({
      if (portalEntityId != null) #portalEntityId: portalEntityId,
      if (specificAnchorId != $none) #specificAnchorId: specificAnchorId,
    }),
  );
  @override
  UsePortalIntent $make(CopyWithData data) => UsePortalIntent(
    portalEntityId: data.get(#portalEntityId, or: $value.portalEntityId),
    specificAnchorId: data.get(#specificAnchorId, or: $value.specificAnchorId),
  );

  @override
  UsePortalIntentCopyWith<$R2, UsePortalIntent, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _UsePortalIntentCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DidPortalMapper extends SubClassMapperBase<DidPortal> {
  DidPortalMapper._();

  static DidPortalMapper? _instance;
  static DidPortalMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DidPortalMapper._());
      BeforeTickMapper.ensureInitialized().addSubMapper(_instance!);
      LocalPositionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DidPortal';

  static int _$portalEntityId(DidPortal v) => v.portalEntityId;
  static const Field<DidPortal, int> _f$portalEntityId = Field(
    'portalEntityId',
    _$portalEntityId,
  );
  static int _$fromParentId(DidPortal v) => v.fromParentId;
  static const Field<DidPortal, int> _f$fromParentId = Field(
    'fromParentId',
    _$fromParentId,
  );
  static int _$toParentId(DidPortal v) => v.toParentId;
  static const Field<DidPortal, int> _f$toParentId = Field(
    'toParentId',
    _$toParentId,
  );
  static LocalPosition _$fromPosition(DidPortal v) => v.fromPosition;
  static const Field<DidPortal, LocalPosition> _f$fromPosition = Field(
    'fromPosition',
    _$fromPosition,
  );
  static LocalPosition _$toPosition(DidPortal v) => v.toPosition;
  static const Field<DidPortal, LocalPosition> _f$toPosition = Field(
    'toPosition',
    _$toPosition,
  );
  static int? _$usedAnchorId(DidPortal v) => v.usedAnchorId;
  static const Field<DidPortal, int> _f$usedAnchorId = Field(
    'usedAnchorId',
    _$usedAnchorId,
    opt: true,
  );
  static int _$lifetime(DidPortal v) => v.lifetime;
  static const Field<DidPortal, int> _f$lifetime = Field(
    'lifetime',
    _$lifetime,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<DidPortal> fields = const {
    #portalEntityId: _f$portalEntityId,
    #fromParentId: _f$fromParentId,
    #toParentId: _f$toParentId,
    #fromPosition: _f$fromPosition,
    #toPosition: _f$toPosition,
    #usedAnchorId: _f$usedAnchorId,
    #lifetime: _f$lifetime,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'DidPortal';
  @override
  late final ClassMapperBase superMapper = BeforeTickMapper.ensureInitialized();

  static DidPortal _instantiate(DecodingData data) {
    return DidPortal(
      portalEntityId: data.dec(_f$portalEntityId),
      fromParentId: data.dec(_f$fromParentId),
      toParentId: data.dec(_f$toParentId),
      fromPosition: data.dec(_f$fromPosition),
      toPosition: data.dec(_f$toPosition),
      usedAnchorId: data.dec(_f$usedAnchorId),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static DidPortal fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DidPortal>(map);
  }

  static DidPortal fromJson(String json) {
    return ensureInitialized().decodeJson<DidPortal>(json);
  }
}

mixin DidPortalMappable {
  String toJson() {
    return DidPortalMapper.ensureInitialized().encodeJson<DidPortal>(
      this as DidPortal,
    );
  }

  Map<String, dynamic> toMap() {
    return DidPortalMapper.ensureInitialized().encodeMap<DidPortal>(
      this as DidPortal,
    );
  }

  DidPortalCopyWith<DidPortal, DidPortal, DidPortal> get copyWith =>
      _DidPortalCopyWithImpl<DidPortal, DidPortal>(
        this as DidPortal,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DidPortalMapper.ensureInitialized().stringifyValue(
      this as DidPortal,
    );
  }

  @override
  bool operator ==(Object other) {
    return DidPortalMapper.ensureInitialized().equalsValue(
      this as DidPortal,
      other,
    );
  }

  @override
  int get hashCode {
    return DidPortalMapper.ensureInitialized().hashValue(this as DidPortal);
  }
}

extension DidPortalValueCopy<$R, $Out> on ObjectCopyWith<$R, DidPortal, $Out> {
  DidPortalCopyWith<$R, DidPortal, $Out> get $asDidPortal =>
      $base.as((v, t, t2) => _DidPortalCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DidPortalCopyWith<$R, $In extends DidPortal, $Out>
    implements
        BeforeTickCopyWith<$R, $In, $Out>,
        ComponentCopyWith<$R, $In, $Out> {
  LocalPositionCopyWith<$R, LocalPosition, LocalPosition> get fromPosition;
  LocalPositionCopyWith<$R, LocalPosition, LocalPosition> get toPosition;
  @override
  $R call({
    int? portalEntityId,
    int? fromParentId,
    int? toParentId,
    LocalPosition? fromPosition,
    LocalPosition? toPosition,
    int? usedAnchorId,
  });
  DidPortalCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DidPortalCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DidPortal, $Out>
    implements DidPortalCopyWith<$R, DidPortal, $Out> {
  _DidPortalCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DidPortal> $mapper =
      DidPortalMapper.ensureInitialized();
  @override
  LocalPositionCopyWith<$R, LocalPosition, LocalPosition> get fromPosition =>
      $value.fromPosition.copyWith.$chain((v) => call(fromPosition: v));
  @override
  LocalPositionCopyWith<$R, LocalPosition, LocalPosition> get toPosition =>
      $value.toPosition.copyWith.$chain((v) => call(toPosition: v));
  @override
  $R call({
    int? portalEntityId,
    int? fromParentId,
    int? toParentId,
    LocalPosition? fromPosition,
    LocalPosition? toPosition,
    Object? usedAnchorId = $none,
  }) => $apply(
    FieldCopyWithData({
      if (portalEntityId != null) #portalEntityId: portalEntityId,
      if (fromParentId != null) #fromParentId: fromParentId,
      if (toParentId != null) #toParentId: toParentId,
      if (fromPosition != null) #fromPosition: fromPosition,
      if (toPosition != null) #toPosition: toPosition,
      if (usedAnchorId != $none) #usedAnchorId: usedAnchorId,
    }),
  );
  @override
  DidPortal $make(CopyWithData data) => DidPortal(
    portalEntityId: data.get(#portalEntityId, or: $value.portalEntityId),
    fromParentId: data.get(#fromParentId, or: $value.fromParentId),
    toParentId: data.get(#toParentId, or: $value.toParentId),
    fromPosition: data.get(#fromPosition, or: $value.fromPosition),
    toPosition: data.get(#toPosition, or: $value.toPosition),
    usedAnchorId: data.get(#usedAnchorId, or: $value.usedAnchorId),
  );

  @override
  DidPortalCopyWith<$R2, DidPortal, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DidPortalCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class FailedToPortalMapper extends SubClassMapperBase<FailedToPortal> {
  FailedToPortalMapper._();

  static FailedToPortalMapper? _instance;
  static FailedToPortalMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = FailedToPortalMapper._());
      BeforeTickMapper.ensureInitialized().addSubMapper(_instance!);
      PortalFailureReasonMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'FailedToPortal';

  static int _$portalEntityId(FailedToPortal v) => v.portalEntityId;
  static const Field<FailedToPortal, int> _f$portalEntityId = Field(
    'portalEntityId',
    _$portalEntityId,
  );
  static PortalFailureReason _$reason(FailedToPortal v) => v.reason;
  static const Field<FailedToPortal, PortalFailureReason> _f$reason = Field(
    'reason',
    _$reason,
  );
  static int _$lifetime(FailedToPortal v) => v.lifetime;
  static const Field<FailedToPortal, int> _f$lifetime = Field(
    'lifetime',
    _$lifetime,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<FailedToPortal> fields = const {
    #portalEntityId: _f$portalEntityId,
    #reason: _f$reason,
    #lifetime: _f$lifetime,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'FailedToPortal';
  @override
  late final ClassMapperBase superMapper = BeforeTickMapper.ensureInitialized();

  static FailedToPortal _instantiate(DecodingData data) {
    return FailedToPortal(
      portalEntityId: data.dec(_f$portalEntityId),
      reason: data.dec(_f$reason),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static FailedToPortal fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<FailedToPortal>(map);
  }

  static FailedToPortal fromJson(String json) {
    return ensureInitialized().decodeJson<FailedToPortal>(json);
  }
}

mixin FailedToPortalMappable {
  String toJson() {
    return FailedToPortalMapper.ensureInitialized().encodeJson<FailedToPortal>(
      this as FailedToPortal,
    );
  }

  Map<String, dynamic> toMap() {
    return FailedToPortalMapper.ensureInitialized().encodeMap<FailedToPortal>(
      this as FailedToPortal,
    );
  }

  FailedToPortalCopyWith<FailedToPortal, FailedToPortal, FailedToPortal>
  get copyWith => _FailedToPortalCopyWithImpl<FailedToPortal, FailedToPortal>(
    this as FailedToPortal,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return FailedToPortalMapper.ensureInitialized().stringifyValue(
      this as FailedToPortal,
    );
  }

  @override
  bool operator ==(Object other) {
    return FailedToPortalMapper.ensureInitialized().equalsValue(
      this as FailedToPortal,
      other,
    );
  }

  @override
  int get hashCode {
    return FailedToPortalMapper.ensureInitialized().hashValue(
      this as FailedToPortal,
    );
  }
}

extension FailedToPortalValueCopy<$R, $Out>
    on ObjectCopyWith<$R, FailedToPortal, $Out> {
  FailedToPortalCopyWith<$R, FailedToPortal, $Out> get $asFailedToPortal =>
      $base.as((v, t, t2) => _FailedToPortalCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class FailedToPortalCopyWith<$R, $In extends FailedToPortal, $Out>
    implements
        BeforeTickCopyWith<$R, $In, $Out>,
        ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call({int? portalEntityId, PortalFailureReason? reason});
  FailedToPortalCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _FailedToPortalCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, FailedToPortal, $Out>
    implements FailedToPortalCopyWith<$R, FailedToPortal, $Out> {
  _FailedToPortalCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<FailedToPortal> $mapper =
      FailedToPortalMapper.ensureInitialized();
  @override
  $R call({int? portalEntityId, PortalFailureReason? reason}) => $apply(
    FieldCopyWithData({
      if (portalEntityId != null) #portalEntityId: portalEntityId,
      if (reason != null) #reason: reason,
    }),
  );
  @override
  FailedToPortal $make(CopyWithData data) => FailedToPortal(
    portalEntityId: data.get(#portalEntityId, or: $value.portalEntityId),
    reason: data.get(#reason, or: $value.reason),
  );

  @override
  FailedToPortalCopyWith<$R2, FailedToPortal, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _FailedToPortalCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ControllableMapper extends SubClassMapperBase<Controllable> {
  ControllableMapper._();

  static ControllableMapper? _instance;
  static ControllableMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ControllableMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'Controllable';

  @override
  final MappableFields<Controllable> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'Controllable';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static Controllable _instantiate(DecodingData data) {
    return Controllable();
  }

  @override
  final Function instantiate = _instantiate;

  static Controllable fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Controllable>(map);
  }

  static Controllable fromJson(String json) {
    return ensureInitialized().decodeJson<Controllable>(json);
  }
}

mixin ControllableMappable {
  String toJson() {
    return ControllableMapper.ensureInitialized().encodeJson<Controllable>(
      this as Controllable,
    );
  }

  Map<String, dynamic> toMap() {
    return ControllableMapper.ensureInitialized().encodeMap<Controllable>(
      this as Controllable,
    );
  }

  ControllableCopyWith<Controllable, Controllable, Controllable> get copyWith =>
      _ControllableCopyWithImpl<Controllable, Controllable>(
        this as Controllable,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ControllableMapper.ensureInitialized().stringifyValue(
      this as Controllable,
    );
  }

  @override
  bool operator ==(Object other) {
    return ControllableMapper.ensureInitialized().equalsValue(
      this as Controllable,
      other,
    );
  }

  @override
  int get hashCode {
    return ControllableMapper.ensureInitialized().hashValue(
      this as Controllable,
    );
  }
}

extension ControllableValueCopy<$R, $Out>
    on ObjectCopyWith<$R, Controllable, $Out> {
  ControllableCopyWith<$R, Controllable, $Out> get $asControllable =>
      $base.as((v, t, t2) => _ControllableCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ControllableCopyWith<$R, $In extends Controllable, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call();
  ControllableCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ControllableCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Controllable, $Out>
    implements ControllableCopyWith<$R, Controllable, $Out> {
  _ControllableCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Controllable> $mapper =
      ControllableMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  Controllable $make(CopyWithData data) => Controllable();

  @override
  ControllableCopyWith<$R2, Controllable, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ControllableCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ControllingMapper extends SubClassMapperBase<Controlling> {
  ControllingMapper._();

  static ControllingMapper? _instance;
  static ControllingMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ControllingMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'Controlling';

  static int _$controlledEntityId(Controlling v) => v.controlledEntityId;
  static const Field<Controlling, int> _f$controlledEntityId = Field(
    'controlledEntityId',
    _$controlledEntityId,
  );

  @override
  final MappableFields<Controlling> fields = const {
    #controlledEntityId: _f$controlledEntityId,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'Controlling';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static Controlling _instantiate(DecodingData data) {
    return Controlling(controlledEntityId: data.dec(_f$controlledEntityId));
  }

  @override
  final Function instantiate = _instantiate;

  static Controlling fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Controlling>(map);
  }

  static Controlling fromJson(String json) {
    return ensureInitialized().decodeJson<Controlling>(json);
  }
}

mixin ControllingMappable {
  String toJson() {
    return ControllingMapper.ensureInitialized().encodeJson<Controlling>(
      this as Controlling,
    );
  }

  Map<String, dynamic> toMap() {
    return ControllingMapper.ensureInitialized().encodeMap<Controlling>(
      this as Controlling,
    );
  }

  ControllingCopyWith<Controlling, Controlling, Controlling> get copyWith =>
      _ControllingCopyWithImpl<Controlling, Controlling>(
        this as Controlling,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ControllingMapper.ensureInitialized().stringifyValue(
      this as Controlling,
    );
  }

  @override
  bool operator ==(Object other) {
    return ControllingMapper.ensureInitialized().equalsValue(
      this as Controlling,
      other,
    );
  }

  @override
  int get hashCode {
    return ControllingMapper.ensureInitialized().hashValue(this as Controlling);
  }
}

extension ControllingValueCopy<$R, $Out>
    on ObjectCopyWith<$R, Controlling, $Out> {
  ControllingCopyWith<$R, Controlling, $Out> get $asControlling =>
      $base.as((v, t, t2) => _ControllingCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ControllingCopyWith<$R, $In extends Controlling, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call({int? controlledEntityId});
  ControllingCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ControllingCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Controlling, $Out>
    implements ControllingCopyWith<$R, Controlling, $Out> {
  _ControllingCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Controlling> $mapper =
      ControllingMapper.ensureInitialized();
  @override
  $R call({int? controlledEntityId}) => $apply(
    FieldCopyWithData({
      if (controlledEntityId != null) #controlledEntityId: controlledEntityId,
    }),
  );
  @override
  Controlling $make(CopyWithData data) => Controlling(
    controlledEntityId: data.get(
      #controlledEntityId,
      or: $value.controlledEntityId,
    ),
  );

  @override
  ControllingCopyWith<$R2, Controlling, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ControllingCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class EnablesControlMapper extends SubClassMapperBase<EnablesControl> {
  EnablesControlMapper._();

  static EnablesControlMapper? _instance;
  static EnablesControlMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EnablesControlMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'EnablesControl';

  static int _$controlledEntityId(EnablesControl v) => v.controlledEntityId;
  static const Field<EnablesControl, int> _f$controlledEntityId = Field(
    'controlledEntityId',
    _$controlledEntityId,
  );

  @override
  final MappableFields<EnablesControl> fields = const {
    #controlledEntityId: _f$controlledEntityId,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'EnablesControl';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static EnablesControl _instantiate(DecodingData data) {
    return EnablesControl(controlledEntityId: data.dec(_f$controlledEntityId));
  }

  @override
  final Function instantiate = _instantiate;

  static EnablesControl fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EnablesControl>(map);
  }

  static EnablesControl fromJson(String json) {
    return ensureInitialized().decodeJson<EnablesControl>(json);
  }
}

mixin EnablesControlMappable {
  String toJson() {
    return EnablesControlMapper.ensureInitialized().encodeJson<EnablesControl>(
      this as EnablesControl,
    );
  }

  Map<String, dynamic> toMap() {
    return EnablesControlMapper.ensureInitialized().encodeMap<EnablesControl>(
      this as EnablesControl,
    );
  }

  EnablesControlCopyWith<EnablesControl, EnablesControl, EnablesControl>
  get copyWith => _EnablesControlCopyWithImpl<EnablesControl, EnablesControl>(
    this as EnablesControl,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return EnablesControlMapper.ensureInitialized().stringifyValue(
      this as EnablesControl,
    );
  }

  @override
  bool operator ==(Object other) {
    return EnablesControlMapper.ensureInitialized().equalsValue(
      this as EnablesControl,
      other,
    );
  }

  @override
  int get hashCode {
    return EnablesControlMapper.ensureInitialized().hashValue(
      this as EnablesControl,
    );
  }
}

extension EnablesControlValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EnablesControl, $Out> {
  EnablesControlCopyWith<$R, EnablesControl, $Out> get $asEnablesControl =>
      $base.as((v, t, t2) => _EnablesControlCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class EnablesControlCopyWith<$R, $In extends EnablesControl, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call({int? controlledEntityId});
  EnablesControlCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _EnablesControlCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EnablesControl, $Out>
    implements EnablesControlCopyWith<$R, EnablesControl, $Out> {
  _EnablesControlCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EnablesControl> $mapper =
      EnablesControlMapper.ensureInitialized();
  @override
  $R call({int? controlledEntityId}) => $apply(
    FieldCopyWithData({
      if (controlledEntityId != null) #controlledEntityId: controlledEntityId,
    }),
  );
  @override
  EnablesControl $make(CopyWithData data) => EnablesControl(
    controlledEntityId: data.get(
      #controlledEntityId,
      or: $value.controlledEntityId,
    ),
  );

  @override
  EnablesControlCopyWith<$R2, EnablesControl, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _EnablesControlCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DockedMapper extends SubClassMapperBase<Docked> {
  DockedMapper._();

  static DockedMapper? _instance;
  static DockedMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DockedMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'Docked';

  @override
  final MappableFields<Docked> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'Docked';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static Docked _instantiate(DecodingData data) {
    return Docked();
  }

  @override
  final Function instantiate = _instantiate;

  static Docked fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Docked>(map);
  }

  static Docked fromJson(String json) {
    return ensureInitialized().decodeJson<Docked>(json);
  }
}

mixin DockedMappable {
  String toJson() {
    return DockedMapper.ensureInitialized().encodeJson<Docked>(this as Docked);
  }

  Map<String, dynamic> toMap() {
    return DockedMapper.ensureInitialized().encodeMap<Docked>(this as Docked);
  }

  DockedCopyWith<Docked, Docked, Docked> get copyWith =>
      _DockedCopyWithImpl<Docked, Docked>(this as Docked, $identity, $identity);
  @override
  String toString() {
    return DockedMapper.ensureInitialized().stringifyValue(this as Docked);
  }

  @override
  bool operator ==(Object other) {
    return DockedMapper.ensureInitialized().equalsValue(this as Docked, other);
  }

  @override
  int get hashCode {
    return DockedMapper.ensureInitialized().hashValue(this as Docked);
  }
}

extension DockedValueCopy<$R, $Out> on ObjectCopyWith<$R, Docked, $Out> {
  DockedCopyWith<$R, Docked, $Out> get $asDocked =>
      $base.as((v, t, t2) => _DockedCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DockedCopyWith<$R, $In extends Docked, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call();
  DockedCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DockedCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Docked, $Out>
    implements DockedCopyWith<$R, Docked, $Out> {
  _DockedCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Docked> $mapper = DockedMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  Docked $make(CopyWithData data) => Docked();

  @override
  DockedCopyWith<$R2, Docked, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _DockedCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class WantsControlIntentMapper extends SubClassMapperBase<WantsControlIntent> {
  WantsControlIntentMapper._();

  static WantsControlIntentMapper? _instance;
  static WantsControlIntentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = WantsControlIntentMapper._());
      IntentComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'WantsControlIntent';

  static int _$targetEntityId(WantsControlIntent v) => v.targetEntityId;
  static const Field<WantsControlIntent, int> _f$targetEntityId = Field(
    'targetEntityId',
    _$targetEntityId,
  );
  static int _$lifetime(WantsControlIntent v) => v.lifetime;
  static const Field<WantsControlIntent, int> _f$lifetime = Field(
    'lifetime',
    _$lifetime,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<WantsControlIntent> fields = const {
    #targetEntityId: _f$targetEntityId,
    #lifetime: _f$lifetime,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'WantsControlIntent';
  @override
  late final ClassMapperBase superMapper =
      IntentComponentMapper.ensureInitialized();

  static WantsControlIntent _instantiate(DecodingData data) {
    return WantsControlIntent(targetEntityId: data.dec(_f$targetEntityId));
  }

  @override
  final Function instantiate = _instantiate;

  static WantsControlIntent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<WantsControlIntent>(map);
  }

  static WantsControlIntent fromJson(String json) {
    return ensureInitialized().decodeJson<WantsControlIntent>(json);
  }
}

mixin WantsControlIntentMappable {
  String toJson() {
    return WantsControlIntentMapper.ensureInitialized()
        .encodeJson<WantsControlIntent>(this as WantsControlIntent);
  }

  Map<String, dynamic> toMap() {
    return WantsControlIntentMapper.ensureInitialized()
        .encodeMap<WantsControlIntent>(this as WantsControlIntent);
  }

  WantsControlIntentCopyWith<
    WantsControlIntent,
    WantsControlIntent,
    WantsControlIntent
  >
  get copyWith =>
      _WantsControlIntentCopyWithImpl<WantsControlIntent, WantsControlIntent>(
        this as WantsControlIntent,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return WantsControlIntentMapper.ensureInitialized().stringifyValue(
      this as WantsControlIntent,
    );
  }

  @override
  bool operator ==(Object other) {
    return WantsControlIntentMapper.ensureInitialized().equalsValue(
      this as WantsControlIntent,
      other,
    );
  }

  @override
  int get hashCode {
    return WantsControlIntentMapper.ensureInitialized().hashValue(
      this as WantsControlIntent,
    );
  }
}

extension WantsControlIntentValueCopy<$R, $Out>
    on ObjectCopyWith<$R, WantsControlIntent, $Out> {
  WantsControlIntentCopyWith<$R, WantsControlIntent, $Out>
  get $asWantsControlIntent => $base.as(
    (v, t, t2) => _WantsControlIntentCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class WantsControlIntentCopyWith<
  $R,
  $In extends WantsControlIntent,
  $Out
>
    implements IntentComponentCopyWith<$R, $In, $Out> {
  @override
  $R call({int? targetEntityId});
  WantsControlIntentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _WantsControlIntentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, WantsControlIntent, $Out>
    implements WantsControlIntentCopyWith<$R, WantsControlIntent, $Out> {
  _WantsControlIntentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<WantsControlIntent> $mapper =
      WantsControlIntentMapper.ensureInitialized();
  @override
  $R call({int? targetEntityId}) => $apply(
    FieldCopyWithData({
      if (targetEntityId != null) #targetEntityId: targetEntityId,
    }),
  );
  @override
  WantsControlIntent $make(CopyWithData data) => WantsControlIntent(
    targetEntityId: data.get(#targetEntityId, or: $value.targetEntityId),
  );

  @override
  WantsControlIntentCopyWith<$R2, WantsControlIntent, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _WantsControlIntentCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ReleasesControlIntentMapper
    extends SubClassMapperBase<ReleasesControlIntent> {
  ReleasesControlIntentMapper._();

  static ReleasesControlIntentMapper? _instance;
  static ReleasesControlIntentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ReleasesControlIntentMapper._());
      IntentComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'ReleasesControlIntent';

  static int _$lifetime(ReleasesControlIntent v) => v.lifetime;
  static const Field<ReleasesControlIntent, int> _f$lifetime = Field(
    'lifetime',
    _$lifetime,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<ReleasesControlIntent> fields = const {
    #lifetime: _f$lifetime,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'ReleasesControlIntent';
  @override
  late final ClassMapperBase superMapper =
      IntentComponentMapper.ensureInitialized();

  static ReleasesControlIntent _instantiate(DecodingData data) {
    return ReleasesControlIntent();
  }

  @override
  final Function instantiate = _instantiate;

  static ReleasesControlIntent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ReleasesControlIntent>(map);
  }

  static ReleasesControlIntent fromJson(String json) {
    return ensureInitialized().decodeJson<ReleasesControlIntent>(json);
  }
}

mixin ReleasesControlIntentMappable {
  String toJson() {
    return ReleasesControlIntentMapper.ensureInitialized()
        .encodeJson<ReleasesControlIntent>(this as ReleasesControlIntent);
  }

  Map<String, dynamic> toMap() {
    return ReleasesControlIntentMapper.ensureInitialized()
        .encodeMap<ReleasesControlIntent>(this as ReleasesControlIntent);
  }

  ReleasesControlIntentCopyWith<
    ReleasesControlIntent,
    ReleasesControlIntent,
    ReleasesControlIntent
  >
  get copyWith =>
      _ReleasesControlIntentCopyWithImpl<
        ReleasesControlIntent,
        ReleasesControlIntent
      >(this as ReleasesControlIntent, $identity, $identity);
  @override
  String toString() {
    return ReleasesControlIntentMapper.ensureInitialized().stringifyValue(
      this as ReleasesControlIntent,
    );
  }

  @override
  bool operator ==(Object other) {
    return ReleasesControlIntentMapper.ensureInitialized().equalsValue(
      this as ReleasesControlIntent,
      other,
    );
  }

  @override
  int get hashCode {
    return ReleasesControlIntentMapper.ensureInitialized().hashValue(
      this as ReleasesControlIntent,
    );
  }
}

extension ReleasesControlIntentValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ReleasesControlIntent, $Out> {
  ReleasesControlIntentCopyWith<$R, ReleasesControlIntent, $Out>
  get $asReleasesControlIntent => $base.as(
    (v, t, t2) => _ReleasesControlIntentCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class ReleasesControlIntentCopyWith<
  $R,
  $In extends ReleasesControlIntent,
  $Out
>
    implements IntentComponentCopyWith<$R, $In, $Out> {
  @override
  $R call();
  ReleasesControlIntentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ReleasesControlIntentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ReleasesControlIntent, $Out>
    implements ReleasesControlIntentCopyWith<$R, ReleasesControlIntent, $Out> {
  _ReleasesControlIntentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ReleasesControlIntent> $mapper =
      ReleasesControlIntentMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  ReleasesControlIntent $make(CopyWithData data) => ReleasesControlIntent();

  @override
  ReleasesControlIntentCopyWith<$R2, ReleasesControlIntent, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ReleasesControlIntentCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DockIntentMapper extends SubClassMapperBase<DockIntent> {
  DockIntentMapper._();

  static DockIntentMapper? _instance;
  static DockIntentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DockIntentMapper._());
      IntentComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'DockIntent';

  static int _$lifetime(DockIntent v) => v.lifetime;
  static const Field<DockIntent, int> _f$lifetime = Field(
    'lifetime',
    _$lifetime,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<DockIntent> fields = const {#lifetime: _f$lifetime};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'DockIntent';
  @override
  late final ClassMapperBase superMapper =
      IntentComponentMapper.ensureInitialized();

  static DockIntent _instantiate(DecodingData data) {
    return DockIntent();
  }

  @override
  final Function instantiate = _instantiate;

  static DockIntent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DockIntent>(map);
  }

  static DockIntent fromJson(String json) {
    return ensureInitialized().decodeJson<DockIntent>(json);
  }
}

mixin DockIntentMappable {
  String toJson() {
    return DockIntentMapper.ensureInitialized().encodeJson<DockIntent>(
      this as DockIntent,
    );
  }

  Map<String, dynamic> toMap() {
    return DockIntentMapper.ensureInitialized().encodeMap<DockIntent>(
      this as DockIntent,
    );
  }

  DockIntentCopyWith<DockIntent, DockIntent, DockIntent> get copyWith =>
      _DockIntentCopyWithImpl<DockIntent, DockIntent>(
        this as DockIntent,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DockIntentMapper.ensureInitialized().stringifyValue(
      this as DockIntent,
    );
  }

  @override
  bool operator ==(Object other) {
    return DockIntentMapper.ensureInitialized().equalsValue(
      this as DockIntent,
      other,
    );
  }

  @override
  int get hashCode {
    return DockIntentMapper.ensureInitialized().hashValue(this as DockIntent);
  }
}

extension DockIntentValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DockIntent, $Out> {
  DockIntentCopyWith<$R, DockIntent, $Out> get $asDockIntent =>
      $base.as((v, t, t2) => _DockIntentCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DockIntentCopyWith<$R, $In extends DockIntent, $Out>
    implements IntentComponentCopyWith<$R, $In, $Out> {
  @override
  $R call();
  DockIntentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DockIntentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DockIntent, $Out>
    implements DockIntentCopyWith<$R, DockIntent, $Out> {
  _DockIntentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DockIntent> $mapper =
      DockIntentMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  DockIntent $make(CopyWithData data) => DockIntent();

  @override
  DockIntentCopyWith<$R2, DockIntent, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DockIntentCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class UndockIntentMapper extends SubClassMapperBase<UndockIntent> {
  UndockIntentMapper._();

  static UndockIntentMapper? _instance;
  static UndockIntentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UndockIntentMapper._());
      IntentComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'UndockIntent';

  static int _$lifetime(UndockIntent v) => v.lifetime;
  static const Field<UndockIntent, int> _f$lifetime = Field(
    'lifetime',
    _$lifetime,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<UndockIntent> fields = const {#lifetime: _f$lifetime};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'UndockIntent';
  @override
  late final ClassMapperBase superMapper =
      IntentComponentMapper.ensureInitialized();

  static UndockIntent _instantiate(DecodingData data) {
    return UndockIntent();
  }

  @override
  final Function instantiate = _instantiate;

  static UndockIntent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<UndockIntent>(map);
  }

  static UndockIntent fromJson(String json) {
    return ensureInitialized().decodeJson<UndockIntent>(json);
  }
}

mixin UndockIntentMappable {
  String toJson() {
    return UndockIntentMapper.ensureInitialized().encodeJson<UndockIntent>(
      this as UndockIntent,
    );
  }

  Map<String, dynamic> toMap() {
    return UndockIntentMapper.ensureInitialized().encodeMap<UndockIntent>(
      this as UndockIntent,
    );
  }

  UndockIntentCopyWith<UndockIntent, UndockIntent, UndockIntent> get copyWith =>
      _UndockIntentCopyWithImpl<UndockIntent, UndockIntent>(
        this as UndockIntent,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return UndockIntentMapper.ensureInitialized().stringifyValue(
      this as UndockIntent,
    );
  }

  @override
  bool operator ==(Object other) {
    return UndockIntentMapper.ensureInitialized().equalsValue(
      this as UndockIntent,
      other,
    );
  }

  @override
  int get hashCode {
    return UndockIntentMapper.ensureInitialized().hashValue(
      this as UndockIntent,
    );
  }
}

extension UndockIntentValueCopy<$R, $Out>
    on ObjectCopyWith<$R, UndockIntent, $Out> {
  UndockIntentCopyWith<$R, UndockIntent, $Out> get $asUndockIntent =>
      $base.as((v, t, t2) => _UndockIntentCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class UndockIntentCopyWith<$R, $In extends UndockIntent, $Out>
    implements IntentComponentCopyWith<$R, $In, $Out> {
  @override
  $R call();
  UndockIntentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _UndockIntentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, UndockIntent, $Out>
    implements UndockIntentCopyWith<$R, UndockIntent, $Out> {
  _UndockIntentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<UndockIntent> $mapper =
      UndockIntentMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  UndockIntent $make(CopyWithData data) => UndockIntent();

  @override
  UndockIntentCopyWith<$R2, UndockIntent, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _UndockIntentCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class OpenableMapper extends SubClassMapperBase<Openable> {
  OpenableMapper._();

  static OpenableMapper? _instance;
  static OpenableMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OpenableMapper._());
      ComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'Openable';

  static bool _$isOpen(Openable v) => v.isOpen;
  static const Field<Openable, bool> _f$isOpen = Field(
    'isOpen',
    _$isOpen,
    opt: true,
    def: false,
  );
  static String _$openRenderablePath(Openable v) => v.openRenderablePath;
  static const Field<Openable, String> _f$openRenderablePath = Field(
    'openRenderablePath',
    _$openRenderablePath,
  );
  static String _$closedRenderablePath(Openable v) => v.closedRenderablePath;
  static const Field<Openable, String> _f$closedRenderablePath = Field(
    'closedRenderablePath',
    _$closedRenderablePath,
  );
  static bool _$blocksMovementWhenClosed(Openable v) =>
      v.blocksMovementWhenClosed;
  static const Field<Openable, bool> _f$blocksMovementWhenClosed = Field(
    'blocksMovementWhenClosed',
    _$blocksMovementWhenClosed,
    opt: true,
    def: true,
  );
  static bool _$blocksVisionWhenClosed(Openable v) => v.blocksVisionWhenClosed;
  static const Field<Openable, bool> _f$blocksVisionWhenClosed = Field(
    'blocksVisionWhenClosed',
    _$blocksVisionWhenClosed,
    opt: true,
    def: true,
  );

  @override
  final MappableFields<Openable> fields = const {
    #isOpen: _f$isOpen,
    #openRenderablePath: _f$openRenderablePath,
    #closedRenderablePath: _f$closedRenderablePath,
    #blocksMovementWhenClosed: _f$blocksMovementWhenClosed,
    #blocksVisionWhenClosed: _f$blocksVisionWhenClosed,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'Openable';
  @override
  late final ClassMapperBase superMapper = ComponentMapper.ensureInitialized();

  static Openable _instantiate(DecodingData data) {
    return Openable(
      isOpen: data.dec(_f$isOpen),
      openRenderablePath: data.dec(_f$openRenderablePath),
      closedRenderablePath: data.dec(_f$closedRenderablePath),
      blocksMovementWhenClosed: data.dec(_f$blocksMovementWhenClosed),
      blocksVisionWhenClosed: data.dec(_f$blocksVisionWhenClosed),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Openable fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Openable>(map);
  }

  static Openable fromJson(String json) {
    return ensureInitialized().decodeJson<Openable>(json);
  }
}

mixin OpenableMappable {
  String toJson() {
    return OpenableMapper.ensureInitialized().encodeJson<Openable>(
      this as Openable,
    );
  }

  Map<String, dynamic> toMap() {
    return OpenableMapper.ensureInitialized().encodeMap<Openable>(
      this as Openable,
    );
  }

  OpenableCopyWith<Openable, Openable, Openable> get copyWith =>
      _OpenableCopyWithImpl<Openable, Openable>(
        this as Openable,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return OpenableMapper.ensureInitialized().stringifyValue(this as Openable);
  }

  @override
  bool operator ==(Object other) {
    return OpenableMapper.ensureInitialized().equalsValue(
      this as Openable,
      other,
    );
  }

  @override
  int get hashCode {
    return OpenableMapper.ensureInitialized().hashValue(this as Openable);
  }
}

extension OpenableValueCopy<$R, $Out> on ObjectCopyWith<$R, Openable, $Out> {
  OpenableCopyWith<$R, Openable, $Out> get $asOpenable =>
      $base.as((v, t, t2) => _OpenableCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class OpenableCopyWith<$R, $In extends Openable, $Out>
    implements ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call({
    bool? isOpen,
    String? openRenderablePath,
    String? closedRenderablePath,
    bool? blocksMovementWhenClosed,
    bool? blocksVisionWhenClosed,
  });
  OpenableCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _OpenableCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Openable, $Out>
    implements OpenableCopyWith<$R, Openable, $Out> {
  _OpenableCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Openable> $mapper =
      OpenableMapper.ensureInitialized();
  @override
  $R call({
    bool? isOpen,
    String? openRenderablePath,
    String? closedRenderablePath,
    bool? blocksMovementWhenClosed,
    bool? blocksVisionWhenClosed,
  }) => $apply(
    FieldCopyWithData({
      if (isOpen != null) #isOpen: isOpen,
      if (openRenderablePath != null) #openRenderablePath: openRenderablePath,
      if (closedRenderablePath != null)
        #closedRenderablePath: closedRenderablePath,
      if (blocksMovementWhenClosed != null)
        #blocksMovementWhenClosed: blocksMovementWhenClosed,
      if (blocksVisionWhenClosed != null)
        #blocksVisionWhenClosed: blocksVisionWhenClosed,
    }),
  );
  @override
  Openable $make(CopyWithData data) => Openable(
    isOpen: data.get(#isOpen, or: $value.isOpen),
    openRenderablePath: data.get(
      #openRenderablePath,
      or: $value.openRenderablePath,
    ),
    closedRenderablePath: data.get(
      #closedRenderablePath,
      or: $value.closedRenderablePath,
    ),
    blocksMovementWhenClosed: data.get(
      #blocksMovementWhenClosed,
      or: $value.blocksMovementWhenClosed,
    ),
    blocksVisionWhenClosed: data.get(
      #blocksVisionWhenClosed,
      or: $value.blocksVisionWhenClosed,
    ),
  );

  @override
  OpenableCopyWith<$R2, Openable, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _OpenableCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class OpenIntentMapper extends SubClassMapperBase<OpenIntent> {
  OpenIntentMapper._();

  static OpenIntentMapper? _instance;
  static OpenIntentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OpenIntentMapper._());
      IntentComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'OpenIntent';

  static int _$targetEntityId(OpenIntent v) => v.targetEntityId;
  static const Field<OpenIntent, int> _f$targetEntityId = Field(
    'targetEntityId',
    _$targetEntityId,
  );
  static int _$lifetime(OpenIntent v) => v.lifetime;
  static const Field<OpenIntent, int> _f$lifetime = Field(
    'lifetime',
    _$lifetime,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<OpenIntent> fields = const {
    #targetEntityId: _f$targetEntityId,
    #lifetime: _f$lifetime,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'OpenIntent';
  @override
  late final ClassMapperBase superMapper =
      IntentComponentMapper.ensureInitialized();

  static OpenIntent _instantiate(DecodingData data) {
    return OpenIntent(targetEntityId: data.dec(_f$targetEntityId));
  }

  @override
  final Function instantiate = _instantiate;

  static OpenIntent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OpenIntent>(map);
  }

  static OpenIntent fromJson(String json) {
    return ensureInitialized().decodeJson<OpenIntent>(json);
  }
}

mixin OpenIntentMappable {
  String toJson() {
    return OpenIntentMapper.ensureInitialized().encodeJson<OpenIntent>(
      this as OpenIntent,
    );
  }

  Map<String, dynamic> toMap() {
    return OpenIntentMapper.ensureInitialized().encodeMap<OpenIntent>(
      this as OpenIntent,
    );
  }

  OpenIntentCopyWith<OpenIntent, OpenIntent, OpenIntent> get copyWith =>
      _OpenIntentCopyWithImpl<OpenIntent, OpenIntent>(
        this as OpenIntent,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return OpenIntentMapper.ensureInitialized().stringifyValue(
      this as OpenIntent,
    );
  }

  @override
  bool operator ==(Object other) {
    return OpenIntentMapper.ensureInitialized().equalsValue(
      this as OpenIntent,
      other,
    );
  }

  @override
  int get hashCode {
    return OpenIntentMapper.ensureInitialized().hashValue(this as OpenIntent);
  }
}

extension OpenIntentValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OpenIntent, $Out> {
  OpenIntentCopyWith<$R, OpenIntent, $Out> get $asOpenIntent =>
      $base.as((v, t, t2) => _OpenIntentCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class OpenIntentCopyWith<$R, $In extends OpenIntent, $Out>
    implements IntentComponentCopyWith<$R, $In, $Out> {
  @override
  $R call({int? targetEntityId});
  OpenIntentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _OpenIntentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OpenIntent, $Out>
    implements OpenIntentCopyWith<$R, OpenIntent, $Out> {
  _OpenIntentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OpenIntent> $mapper =
      OpenIntentMapper.ensureInitialized();
  @override
  $R call({int? targetEntityId}) => $apply(
    FieldCopyWithData({
      if (targetEntityId != null) #targetEntityId: targetEntityId,
    }),
  );
  @override
  OpenIntent $make(CopyWithData data) => OpenIntent(
    targetEntityId: data.get(#targetEntityId, or: $value.targetEntityId),
  );

  @override
  OpenIntentCopyWith<$R2, OpenIntent, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _OpenIntentCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CloseIntentMapper extends SubClassMapperBase<CloseIntent> {
  CloseIntentMapper._();

  static CloseIntentMapper? _instance;
  static CloseIntentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CloseIntentMapper._());
      IntentComponentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'CloseIntent';

  static int _$targetEntityId(CloseIntent v) => v.targetEntityId;
  static const Field<CloseIntent, int> _f$targetEntityId = Field(
    'targetEntityId',
    _$targetEntityId,
  );
  static int _$lifetime(CloseIntent v) => v.lifetime;
  static const Field<CloseIntent, int> _f$lifetime = Field(
    'lifetime',
    _$lifetime,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<CloseIntent> fields = const {
    #targetEntityId: _f$targetEntityId,
    #lifetime: _f$lifetime,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'CloseIntent';
  @override
  late final ClassMapperBase superMapper =
      IntentComponentMapper.ensureInitialized();

  static CloseIntent _instantiate(DecodingData data) {
    return CloseIntent(targetEntityId: data.dec(_f$targetEntityId));
  }

  @override
  final Function instantiate = _instantiate;

  static CloseIntent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CloseIntent>(map);
  }

  static CloseIntent fromJson(String json) {
    return ensureInitialized().decodeJson<CloseIntent>(json);
  }
}

mixin CloseIntentMappable {
  String toJson() {
    return CloseIntentMapper.ensureInitialized().encodeJson<CloseIntent>(
      this as CloseIntent,
    );
  }

  Map<String, dynamic> toMap() {
    return CloseIntentMapper.ensureInitialized().encodeMap<CloseIntent>(
      this as CloseIntent,
    );
  }

  CloseIntentCopyWith<CloseIntent, CloseIntent, CloseIntent> get copyWith =>
      _CloseIntentCopyWithImpl<CloseIntent, CloseIntent>(
        this as CloseIntent,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CloseIntentMapper.ensureInitialized().stringifyValue(
      this as CloseIntent,
    );
  }

  @override
  bool operator ==(Object other) {
    return CloseIntentMapper.ensureInitialized().equalsValue(
      this as CloseIntent,
      other,
    );
  }

  @override
  int get hashCode {
    return CloseIntentMapper.ensureInitialized().hashValue(this as CloseIntent);
  }
}

extension CloseIntentValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CloseIntent, $Out> {
  CloseIntentCopyWith<$R, CloseIntent, $Out> get $asCloseIntent =>
      $base.as((v, t, t2) => _CloseIntentCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CloseIntentCopyWith<$R, $In extends CloseIntent, $Out>
    implements IntentComponentCopyWith<$R, $In, $Out> {
  @override
  $R call({int? targetEntityId});
  CloseIntentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CloseIntentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CloseIntent, $Out>
    implements CloseIntentCopyWith<$R, CloseIntent, $Out> {
  _CloseIntentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CloseIntent> $mapper =
      CloseIntentMapper.ensureInitialized();
  @override
  $R call({int? targetEntityId}) => $apply(
    FieldCopyWithData({
      if (targetEntityId != null) #targetEntityId: targetEntityId,
    }),
  );
  @override
  CloseIntent $make(CopyWithData data) => CloseIntent(
    targetEntityId: data.get(#targetEntityId, or: $value.targetEntityId),
  );

  @override
  CloseIntentCopyWith<$R2, CloseIntent, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CloseIntentCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DidOpenMapper extends SubClassMapperBase<DidOpen> {
  DidOpenMapper._();

  static DidOpenMapper? _instance;
  static DidOpenMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DidOpenMapper._());
      BeforeTickMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'DidOpen';

  static int _$targetEntityId(DidOpen v) => v.targetEntityId;
  static const Field<DidOpen, int> _f$targetEntityId = Field(
    'targetEntityId',
    _$targetEntityId,
  );
  static int _$lifetime(DidOpen v) => v.lifetime;
  static const Field<DidOpen, int> _f$lifetime = Field(
    'lifetime',
    _$lifetime,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<DidOpen> fields = const {
    #targetEntityId: _f$targetEntityId,
    #lifetime: _f$lifetime,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'DidOpen';
  @override
  late final ClassMapperBase superMapper = BeforeTickMapper.ensureInitialized();

  static DidOpen _instantiate(DecodingData data) {
    return DidOpen(targetEntityId: data.dec(_f$targetEntityId));
  }

  @override
  final Function instantiate = _instantiate;

  static DidOpen fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DidOpen>(map);
  }

  static DidOpen fromJson(String json) {
    return ensureInitialized().decodeJson<DidOpen>(json);
  }
}

mixin DidOpenMappable {
  String toJson() {
    return DidOpenMapper.ensureInitialized().encodeJson<DidOpen>(
      this as DidOpen,
    );
  }

  Map<String, dynamic> toMap() {
    return DidOpenMapper.ensureInitialized().encodeMap<DidOpen>(
      this as DidOpen,
    );
  }

  DidOpenCopyWith<DidOpen, DidOpen, DidOpen> get copyWith =>
      _DidOpenCopyWithImpl<DidOpen, DidOpen>(
        this as DidOpen,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DidOpenMapper.ensureInitialized().stringifyValue(this as DidOpen);
  }

  @override
  bool operator ==(Object other) {
    return DidOpenMapper.ensureInitialized().equalsValue(
      this as DidOpen,
      other,
    );
  }

  @override
  int get hashCode {
    return DidOpenMapper.ensureInitialized().hashValue(this as DidOpen);
  }
}

extension DidOpenValueCopy<$R, $Out> on ObjectCopyWith<$R, DidOpen, $Out> {
  DidOpenCopyWith<$R, DidOpen, $Out> get $asDidOpen =>
      $base.as((v, t, t2) => _DidOpenCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DidOpenCopyWith<$R, $In extends DidOpen, $Out>
    implements
        BeforeTickCopyWith<$R, $In, $Out>,
        ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call({int? targetEntityId});
  DidOpenCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DidOpenCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DidOpen, $Out>
    implements DidOpenCopyWith<$R, DidOpen, $Out> {
  _DidOpenCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DidOpen> $mapper =
      DidOpenMapper.ensureInitialized();
  @override
  $R call({int? targetEntityId}) => $apply(
    FieldCopyWithData({
      if (targetEntityId != null) #targetEntityId: targetEntityId,
    }),
  );
  @override
  DidOpen $make(CopyWithData data) => DidOpen(
    targetEntityId: data.get(#targetEntityId, or: $value.targetEntityId),
  );

  @override
  DidOpenCopyWith<$R2, DidOpen, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _DidOpenCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DidCloseMapper extends SubClassMapperBase<DidClose> {
  DidCloseMapper._();

  static DidCloseMapper? _instance;
  static DidCloseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DidCloseMapper._());
      BeforeTickMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'DidClose';

  static int _$targetEntityId(DidClose v) => v.targetEntityId;
  static const Field<DidClose, int> _f$targetEntityId = Field(
    'targetEntityId',
    _$targetEntityId,
  );
  static int _$lifetime(DidClose v) => v.lifetime;
  static const Field<DidClose, int> _f$lifetime = Field(
    'lifetime',
    _$lifetime,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<DidClose> fields = const {
    #targetEntityId: _f$targetEntityId,
    #lifetime: _f$lifetime,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'DidClose';
  @override
  late final ClassMapperBase superMapper = BeforeTickMapper.ensureInitialized();

  static DidClose _instantiate(DecodingData data) {
    return DidClose(targetEntityId: data.dec(_f$targetEntityId));
  }

  @override
  final Function instantiate = _instantiate;

  static DidClose fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DidClose>(map);
  }

  static DidClose fromJson(String json) {
    return ensureInitialized().decodeJson<DidClose>(json);
  }
}

mixin DidCloseMappable {
  String toJson() {
    return DidCloseMapper.ensureInitialized().encodeJson<DidClose>(
      this as DidClose,
    );
  }

  Map<String, dynamic> toMap() {
    return DidCloseMapper.ensureInitialized().encodeMap<DidClose>(
      this as DidClose,
    );
  }

  DidCloseCopyWith<DidClose, DidClose, DidClose> get copyWith =>
      _DidCloseCopyWithImpl<DidClose, DidClose>(
        this as DidClose,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DidCloseMapper.ensureInitialized().stringifyValue(this as DidClose);
  }

  @override
  bool operator ==(Object other) {
    return DidCloseMapper.ensureInitialized().equalsValue(
      this as DidClose,
      other,
    );
  }

  @override
  int get hashCode {
    return DidCloseMapper.ensureInitialized().hashValue(this as DidClose);
  }
}

extension DidCloseValueCopy<$R, $Out> on ObjectCopyWith<$R, DidClose, $Out> {
  DidCloseCopyWith<$R, DidClose, $Out> get $asDidClose =>
      $base.as((v, t, t2) => _DidCloseCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DidCloseCopyWith<$R, $In extends DidClose, $Out>
    implements
        BeforeTickCopyWith<$R, $In, $Out>,
        ComponentCopyWith<$R, $In, $Out> {
  @override
  $R call({int? targetEntityId});
  DidCloseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DidCloseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DidClose, $Out>
    implements DidCloseCopyWith<$R, DidClose, $Out> {
  _DidCloseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DidClose> $mapper =
      DidCloseMapper.ensureInitialized();
  @override
  $R call({int? targetEntityId}) => $apply(
    FieldCopyWithData({
      if (targetEntityId != null) #targetEntityId: targetEntityId,
    }),
  );
  @override
  DidClose $make(CopyWithData data) => DidClose(
    targetEntityId: data.get(#targetEntityId, or: $value.targetEntityId),
  );

  @override
  DidCloseCopyWith<$R2, DidClose, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DidCloseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

