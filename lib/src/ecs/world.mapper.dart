// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'world.dart';

class WorldMapper extends ClassMapperBase<World> {
  WorldMapper._();

  static WorldMapper? _instance;
  static WorldMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = WorldMapper._());
      SystemMapper.ensureInitialized();
      ComponentMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'World';

  static List<System> _$systems(World v) => v.systems;
  static const Field<World, List<System>> _f$systems = Field(
    'systems',
    _$systems,
  );
  static Map<Type, Map<int, Component>> _$components(World v) => v.components;
  static const Field<World, Map<Type, Map<int, Component>>> _f$components =
      Field('components', _$components);
  static EventBus _$eventBus(World v) => v.eventBus;
  static const Field<World, EventBus> _f$eventBus = Field(
    'eventBus',
    _$eventBus,
  );
  static int _$tickId(World v) => v.tickId;
  static const Field<World, int> _f$tickId = Field(
    'tickId',
    _$tickId,
    mode: FieldMode.member,
  );
  static int _$lastId(World v) => v.lastId;
  static const Field<World, int> _f$lastId = Field(
    'lastId',
    _$lastId,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<World> fields = const {
    #systems: _f$systems,
    #components: _f$components,
    #eventBus: _f$eventBus,
    #tickId: _f$tickId,
    #lastId: _f$lastId,
  };

  static World _instantiate(DecodingData data) {
    return World(
      data.dec(_f$systems),
      data.dec(_f$components),
      data.dec(_f$eventBus),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static World fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<World>(map);
  }

  static World fromJson(String json) {
    return ensureInitialized().decodeJson<World>(json);
  }
}

mixin WorldMappable {
  String toJson() {
    return WorldMapper.ensureInitialized().encodeJson<World>(this as World);
  }

  Map<String, dynamic> toMap() {
    return WorldMapper.ensureInitialized().encodeMap<World>(this as World);
  }

  WorldCopyWith<World, World, World> get copyWith =>
      _WorldCopyWithImpl<World, World>(this as World, $identity, $identity);
  @override
  String toString() {
    return WorldMapper.ensureInitialized().stringifyValue(this as World);
  }

  @override
  bool operator ==(Object other) {
    return WorldMapper.ensureInitialized().equalsValue(this as World, other);
  }

  @override
  int get hashCode {
    return WorldMapper.ensureInitialized().hashValue(this as World);
  }
}

extension WorldValueCopy<$R, $Out> on ObjectCopyWith<$R, World, $Out> {
  WorldCopyWith<$R, World, $Out> get $asWorld =>
      $base.as((v, t, t2) => _WorldCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class WorldCopyWith<$R, $In extends World, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, System, ObjectCopyWith<$R, System, System>> get systems;
  MapCopyWith<
    $R,
    Type,
    Map<int, Component>,
    ObjectCopyWith<$R, Map<int, Component>, Map<int, Component>>
  >
  get components;
  $R call({
    List<System>? systems,
    Map<Type, Map<int, Component>>? components,
    EventBus? eventBus,
  });
  WorldCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _WorldCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, World, $Out>
    implements WorldCopyWith<$R, World, $Out> {
  _WorldCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<World> $mapper = WorldMapper.ensureInitialized();
  @override
  ListCopyWith<$R, System, ObjectCopyWith<$R, System, System>> get systems =>
      ListCopyWith(
        $value.systems,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(systems: v),
      );
  @override
  MapCopyWith<
    $R,
    Type,
    Map<int, Component>,
    ObjectCopyWith<$R, Map<int, Component>, Map<int, Component>>
  >
  get components => MapCopyWith(
    $value.components,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(components: v),
  );
  @override
  $R call({
    List<System>? systems,
    Map<Type, Map<int, Component>>? components,
    EventBus? eventBus,
  }) => $apply(
    FieldCopyWithData({
      if (systems != null) #systems: systems,
      if (components != null) #components: components,
      if (eventBus != null) #eventBus: eventBus,
    }),
  );
  @override
  World $make(CopyWithData data) => World(
    data.get(#systems, or: $value.systems),
    data.get(#components, or: $value.components),
    data.get(#eventBus, or: $value.eventBus),
  );

  @override
  WorldCopyWith<$R2, World, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _WorldCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

