// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'composite_nodes.dart';

class SelectorMapper extends SubClassMapperBase<Selector> {
  SelectorMapper._();

  static SelectorMapper? _instance;
  static SelectorMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SelectorMapper._());
      NodeMapper.ensureInitialized().addSubMapper(_instance!);
      NodeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Selector';

  static List<Node> _$children(Selector v) => v.children;
  static const Field<Selector, List<Node>> _f$children = Field(
    'children',
    _$children,
  );

  @override
  final MappableFields<Selector> fields = const {#children: _f$children};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'Selector';
  @override
  late final ClassMapperBase superMapper = NodeMapper.ensureInitialized();

  static Selector _instantiate(DecodingData data) {
    return Selector(data.dec(_f$children));
  }

  @override
  final Function instantiate = _instantiate;

  static Selector fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Selector>(map);
  }

  static Selector fromJson(String json) {
    return ensureInitialized().decodeJson<Selector>(json);
  }
}

mixin SelectorMappable {
  String toJson() {
    return SelectorMapper.ensureInitialized().encodeJson<Selector>(
      this as Selector,
    );
  }

  Map<String, dynamic> toMap() {
    return SelectorMapper.ensureInitialized().encodeMap<Selector>(
      this as Selector,
    );
  }

  SelectorCopyWith<Selector, Selector, Selector> get copyWith =>
      _SelectorCopyWithImpl<Selector, Selector>(
        this as Selector,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return SelectorMapper.ensureInitialized().stringifyValue(this as Selector);
  }

  @override
  bool operator ==(Object other) {
    return SelectorMapper.ensureInitialized().equalsValue(
      this as Selector,
      other,
    );
  }

  @override
  int get hashCode {
    return SelectorMapper.ensureInitialized().hashValue(this as Selector);
  }
}

extension SelectorValueCopy<$R, $Out> on ObjectCopyWith<$R, Selector, $Out> {
  SelectorCopyWith<$R, Selector, $Out> get $asSelector =>
      $base.as((v, t, t2) => _SelectorCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class SelectorCopyWith<$R, $In extends Selector, $Out>
    implements NodeCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Node, NodeCopyWith<$R, Node, Node>> get children;
  @override
  $R call({List<Node>? children});
  SelectorCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _SelectorCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Selector, $Out>
    implements SelectorCopyWith<$R, Selector, $Out> {
  _SelectorCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Selector> $mapper =
      SelectorMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Node, NodeCopyWith<$R, Node, Node>> get children =>
      ListCopyWith(
        $value.children,
        (v, t) => v.copyWith.$chain(t),
        (v) => call(children: v),
      );
  @override
  $R call({List<Node>? children}) =>
      $apply(FieldCopyWithData({if (children != null) #children: children}));
  @override
  Selector $make(CopyWithData data) =>
      Selector(data.get(#children, or: $value.children));

  @override
  SelectorCopyWith<$R2, Selector, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _SelectorCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ParallelMapper extends SubClassMapperBase<Parallel> {
  ParallelMapper._();

  static ParallelMapper? _instance;
  static ParallelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ParallelMapper._());
      NodeMapper.ensureInitialized().addSubMapper(_instance!);
      NodeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Parallel';

  static List<Node> _$children(Parallel v) => v.children;
  static const Field<Parallel, List<Node>> _f$children = Field(
    'children',
    _$children,
  );
  static bool _$requireAllSuccess(Parallel v) => v.requireAllSuccess;
  static const Field<Parallel, bool> _f$requireAllSuccess = Field(
    'requireAllSuccess',
    _$requireAllSuccess,
    opt: true,
    def: true,
  );
  static bool _$requireAllFailure(Parallel v) => v.requireAllFailure;
  static const Field<Parallel, bool> _f$requireAllFailure = Field(
    'requireAllFailure',
    _$requireAllFailure,
    opt: true,
    def: false,
  );

  @override
  final MappableFields<Parallel> fields = const {
    #children: _f$children,
    #requireAllSuccess: _f$requireAllSuccess,
    #requireAllFailure: _f$requireAllFailure,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'Parallel';
  @override
  late final ClassMapperBase superMapper = NodeMapper.ensureInitialized();

  static Parallel _instantiate(DecodingData data) {
    return Parallel(
      data.dec(_f$children),
      requireAllSuccess: data.dec(_f$requireAllSuccess),
      requireAllFailure: data.dec(_f$requireAllFailure),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Parallel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Parallel>(map);
  }

  static Parallel fromJson(String json) {
    return ensureInitialized().decodeJson<Parallel>(json);
  }
}

mixin ParallelMappable {
  String toJson() {
    return ParallelMapper.ensureInitialized().encodeJson<Parallel>(
      this as Parallel,
    );
  }

  Map<String, dynamic> toMap() {
    return ParallelMapper.ensureInitialized().encodeMap<Parallel>(
      this as Parallel,
    );
  }

  ParallelCopyWith<Parallel, Parallel, Parallel> get copyWith =>
      _ParallelCopyWithImpl<Parallel, Parallel>(
        this as Parallel,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ParallelMapper.ensureInitialized().stringifyValue(this as Parallel);
  }

  @override
  bool operator ==(Object other) {
    return ParallelMapper.ensureInitialized().equalsValue(
      this as Parallel,
      other,
    );
  }

  @override
  int get hashCode {
    return ParallelMapper.ensureInitialized().hashValue(this as Parallel);
  }
}

extension ParallelValueCopy<$R, $Out> on ObjectCopyWith<$R, Parallel, $Out> {
  ParallelCopyWith<$R, Parallel, $Out> get $asParallel =>
      $base.as((v, t, t2) => _ParallelCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ParallelCopyWith<$R, $In extends Parallel, $Out>
    implements NodeCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Node, NodeCopyWith<$R, Node, Node>> get children;
  @override
  $R call({
    List<Node>? children,
    bool? requireAllSuccess,
    bool? requireAllFailure,
  });
  ParallelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ParallelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Parallel, $Out>
    implements ParallelCopyWith<$R, Parallel, $Out> {
  _ParallelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Parallel> $mapper =
      ParallelMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Node, NodeCopyWith<$R, Node, Node>> get children =>
      ListCopyWith(
        $value.children,
        (v, t) => v.copyWith.$chain(t),
        (v) => call(children: v),
      );
  @override
  $R call({
    List<Node>? children,
    bool? requireAllSuccess,
    bool? requireAllFailure,
  }) => $apply(
    FieldCopyWithData({
      if (children != null) #children: children,
      if (requireAllSuccess != null) #requireAllSuccess: requireAllSuccess,
      if (requireAllFailure != null) #requireAllFailure: requireAllFailure,
    }),
  );
  @override
  Parallel $make(CopyWithData data) => Parallel(
    data.get(#children, or: $value.children),
    requireAllSuccess: data.get(
      #requireAllSuccess,
      or: $value.requireAllSuccess,
    ),
    requireAllFailure: data.get(
      #requireAllFailure,
      or: $value.requireAllFailure,
    ),
  );

  @override
  ParallelCopyWith<$R2, Parallel, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ParallelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class RandomSelectorMapper extends SubClassMapperBase<RandomSelector> {
  RandomSelectorMapper._();

  static RandomSelectorMapper? _instance;
  static RandomSelectorMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RandomSelectorMapper._());
      NodeMapper.ensureInitialized().addSubMapper(_instance!);
      NodeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'RandomSelector';

  static List<Node> _$children(RandomSelector v) => v.children;
  static const Field<RandomSelector, List<Node>> _f$children = Field(
    'children',
    _$children,
  );

  @override
  final MappableFields<RandomSelector> fields = const {#children: _f$children};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'RandomSelector';
  @override
  late final ClassMapperBase superMapper = NodeMapper.ensureInitialized();

  static RandomSelector _instantiate(DecodingData data) {
    return RandomSelector(data.dec(_f$children));
  }

  @override
  final Function instantiate = _instantiate;

  static RandomSelector fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<RandomSelector>(map);
  }

  static RandomSelector fromJson(String json) {
    return ensureInitialized().decodeJson<RandomSelector>(json);
  }
}

mixin RandomSelectorMappable {
  String toJson() {
    return RandomSelectorMapper.ensureInitialized().encodeJson<RandomSelector>(
      this as RandomSelector,
    );
  }

  Map<String, dynamic> toMap() {
    return RandomSelectorMapper.ensureInitialized().encodeMap<RandomSelector>(
      this as RandomSelector,
    );
  }

  RandomSelectorCopyWith<RandomSelector, RandomSelector, RandomSelector>
  get copyWith => _RandomSelectorCopyWithImpl<RandomSelector, RandomSelector>(
    this as RandomSelector,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return RandomSelectorMapper.ensureInitialized().stringifyValue(
      this as RandomSelector,
    );
  }

  @override
  bool operator ==(Object other) {
    return RandomSelectorMapper.ensureInitialized().equalsValue(
      this as RandomSelector,
      other,
    );
  }

  @override
  int get hashCode {
    return RandomSelectorMapper.ensureInitialized().hashValue(
      this as RandomSelector,
    );
  }
}

extension RandomSelectorValueCopy<$R, $Out>
    on ObjectCopyWith<$R, RandomSelector, $Out> {
  RandomSelectorCopyWith<$R, RandomSelector, $Out> get $asRandomSelector =>
      $base.as((v, t, t2) => _RandomSelectorCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class RandomSelectorCopyWith<$R, $In extends RandomSelector, $Out>
    implements NodeCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Node, NodeCopyWith<$R, Node, Node>> get children;
  @override
  $R call({List<Node>? children});
  RandomSelectorCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _RandomSelectorCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, RandomSelector, $Out>
    implements RandomSelectorCopyWith<$R, RandomSelector, $Out> {
  _RandomSelectorCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<RandomSelector> $mapper =
      RandomSelectorMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Node, NodeCopyWith<$R, Node, Node>> get children =>
      ListCopyWith(
        $value.children,
        (v, t) => v.copyWith.$chain(t),
        (v) => call(children: v),
      );
  @override
  $R call({List<Node>? children}) =>
      $apply(FieldCopyWithData({if (children != null) #children: children}));
  @override
  RandomSelector $make(CopyWithData data) =>
      RandomSelector(data.get(#children, or: $value.children));

  @override
  RandomSelectorCopyWith<$R2, RandomSelector, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _RandomSelectorCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

