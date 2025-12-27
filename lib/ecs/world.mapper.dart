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
  static Map<String, Map<int, Component>> _$components(World v) => v.components;
  static const Field<World, Map<String, Map<int, Component>>> _f$components =
      Field('components', _$components, hook: ComponentsHook());
  static int _$tickId(World v) => v.tickId;
  static const Field<World, int> _f$tickId = Field(
    'tickId',
    _$tickId,
    opt: true,
    def: 0,
  );
  static int _$lastId(World v) => v.lastId;
  static const Field<World, int> _f$lastId = Field(
    'lastId',
    _$lastId,
    opt: true,
    def: 0,
  );
  static HierarchyCache _$hierarchyCache(World v) => v.hierarchyCache;
  static const Field<World, HierarchyCache> _f$hierarchyCache = Field(
    'hierarchyCache',
    _$hierarchyCache,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<World> fields = const {
    #systems: _f$systems,
    #components: _f$components,
    #tickId: _f$tickId,
    #lastId: _f$lastId,
    #hierarchyCache: _f$hierarchyCache,
  };

  static World _instantiate(DecodingData data) {
    return World(
      data.dec(_f$systems),
      data.dec(_f$components),
      data.dec(_f$tickId),
      data.dec(_f$lastId),
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
    String,
    Map<int, Component>,
    ObjectCopyWith<$R, Map<int, Component>, Map<int, Component>>
  >
  get components;
  $R call({
    List<System>? systems,
    Map<String, Map<int, Component>>? components,
    int? tickId,
    int? lastId,
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
    String,
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
    Map<String, Map<int, Component>>? components,
    int? tickId,
    int? lastId,
  }) => $apply(
    FieldCopyWithData({
      if (systems != null) #systems: systems,
      if (components != null) #components: components,
      if (tickId != null) #tickId: tickId,
      if (lastId != null) #lastId: lastId,
    }),
  );
  @override
  World $make(CopyWithData data) => World(
    data.get(#systems, or: $value.systems),
    data.get(#components, or: $value.components),
    data.get(#tickId, or: $value.tickId),
    data.get(#lastId, or: $value.lastId),
  );

  @override
  WorldCopyWith<$R2, World, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _WorldCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

