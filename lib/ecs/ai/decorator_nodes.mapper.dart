// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'decorator_nodes.dart';

class InverterMapper extends SubClassMapperBase<Inverter> {
  InverterMapper._();

  static InverterMapper? _instance;
  static InverterMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = InverterMapper._());
      NodeMapper.ensureInitialized().addSubMapper(_instance!);
      NodeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Inverter';

  static Node _$child(Inverter v) => v.child;
  static const Field<Inverter, Node> _f$child = Field('child', _$child);

  @override
  final MappableFields<Inverter> fields = const {#child: _f$child};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'Inverter';
  @override
  late final ClassMapperBase superMapper = NodeMapper.ensureInitialized();

  static Inverter _instantiate(DecodingData data) {
    return Inverter(data.dec(_f$child));
  }

  @override
  final Function instantiate = _instantiate;

  static Inverter fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Inverter>(map);
  }

  static Inverter fromJson(String json) {
    return ensureInitialized().decodeJson<Inverter>(json);
  }
}

mixin InverterMappable {
  String toJson() {
    return InverterMapper.ensureInitialized().encodeJson<Inverter>(
      this as Inverter,
    );
  }

  Map<String, dynamic> toMap() {
    return InverterMapper.ensureInitialized().encodeMap<Inverter>(
      this as Inverter,
    );
  }

  InverterCopyWith<Inverter, Inverter, Inverter> get copyWith =>
      _InverterCopyWithImpl<Inverter, Inverter>(
        this as Inverter,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return InverterMapper.ensureInitialized().stringifyValue(this as Inverter);
  }

  @override
  bool operator ==(Object other) {
    return InverterMapper.ensureInitialized().equalsValue(
      this as Inverter,
      other,
    );
  }

  @override
  int get hashCode {
    return InverterMapper.ensureInitialized().hashValue(this as Inverter);
  }
}

extension InverterValueCopy<$R, $Out> on ObjectCopyWith<$R, Inverter, $Out> {
  InverterCopyWith<$R, Inverter, $Out> get $asInverter =>
      $base.as((v, t, t2) => _InverterCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class InverterCopyWith<$R, $In extends Inverter, $Out>
    implements NodeCopyWith<$R, $In, $Out> {
  NodeCopyWith<$R, Node, Node> get child;
  @override
  $R call({Node? child});
  InverterCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _InverterCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Inverter, $Out>
    implements InverterCopyWith<$R, Inverter, $Out> {
  _InverterCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Inverter> $mapper =
      InverterMapper.ensureInitialized();
  @override
  NodeCopyWith<$R, Node, Node> get child =>
      $value.child.copyWith.$chain((v) => call(child: v));
  @override
  $R call({Node? child}) =>
      $apply(FieldCopyWithData({if (child != null) #child: child}));
  @override
  Inverter $make(CopyWithData data) =>
      Inverter(data.get(#child, or: $value.child));

  @override
  InverterCopyWith<$R2, Inverter, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _InverterCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class RepeaterMapper extends SubClassMapperBase<Repeater> {
  RepeaterMapper._();

  static RepeaterMapper? _instance;
  static RepeaterMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RepeaterMapper._());
      NodeMapper.ensureInitialized().addSubMapper(_instance!);
      NodeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Repeater';

  static Node _$child(Repeater v) => v.child;
  static const Field<Repeater, Node> _f$child = Field('child', _$child);
  static int _$repeatCount(Repeater v) => v.repeatCount;
  static const Field<Repeater, int> _f$repeatCount = Field(
    'repeatCount',
    _$repeatCount,
  );

  @override
  final MappableFields<Repeater> fields = const {
    #child: _f$child,
    #repeatCount: _f$repeatCount,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'Repeater';
  @override
  late final ClassMapperBase superMapper = NodeMapper.ensureInitialized();

  static Repeater _instantiate(DecodingData data) {
    return Repeater(data.dec(_f$child), data.dec(_f$repeatCount));
  }

  @override
  final Function instantiate = _instantiate;

  static Repeater fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Repeater>(map);
  }

  static Repeater fromJson(String json) {
    return ensureInitialized().decodeJson<Repeater>(json);
  }
}

mixin RepeaterMappable {
  String toJson() {
    return RepeaterMapper.ensureInitialized().encodeJson<Repeater>(
      this as Repeater,
    );
  }

  Map<String, dynamic> toMap() {
    return RepeaterMapper.ensureInitialized().encodeMap<Repeater>(
      this as Repeater,
    );
  }

  RepeaterCopyWith<Repeater, Repeater, Repeater> get copyWith =>
      _RepeaterCopyWithImpl<Repeater, Repeater>(
        this as Repeater,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return RepeaterMapper.ensureInitialized().stringifyValue(this as Repeater);
  }

  @override
  bool operator ==(Object other) {
    return RepeaterMapper.ensureInitialized().equalsValue(
      this as Repeater,
      other,
    );
  }

  @override
  int get hashCode {
    return RepeaterMapper.ensureInitialized().hashValue(this as Repeater);
  }
}

extension RepeaterValueCopy<$R, $Out> on ObjectCopyWith<$R, Repeater, $Out> {
  RepeaterCopyWith<$R, Repeater, $Out> get $asRepeater =>
      $base.as((v, t, t2) => _RepeaterCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class RepeaterCopyWith<$R, $In extends Repeater, $Out>
    implements NodeCopyWith<$R, $In, $Out> {
  NodeCopyWith<$R, Node, Node> get child;
  @override
  $R call({Node? child, int? repeatCount});
  RepeaterCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _RepeaterCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Repeater, $Out>
    implements RepeaterCopyWith<$R, Repeater, $Out> {
  _RepeaterCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Repeater> $mapper =
      RepeaterMapper.ensureInitialized();
  @override
  NodeCopyWith<$R, Node, Node> get child =>
      $value.child.copyWith.$chain((v) => call(child: v));
  @override
  $R call({Node? child, int? repeatCount}) => $apply(
    FieldCopyWithData({
      if (child != null) #child: child,
      if (repeatCount != null) #repeatCount: repeatCount,
    }),
  );
  @override
  Repeater $make(CopyWithData data) => Repeater(
    data.get(#child, or: $value.child),
    data.get(#repeatCount, or: $value.repeatCount),
  );

  @override
  RepeaterCopyWith<$R2, Repeater, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _RepeaterCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class GuardMapper extends SubClassMapperBase<Guard> {
  GuardMapper._();

  static GuardMapper? _instance;
  static GuardMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = GuardMapper._());
      NodeMapper.ensureInitialized().addSubMapper(_instance!);
      NodeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Guard';

  static Function _$condition(Guard v) => (v as dynamic).condition as Function;
  static dynamic _arg$condition(f) => f<bool Function(Entity)>();
  static const Field<Guard, Function> _f$condition = Field(
    'condition',
    _$condition,
    arg: _arg$condition,
  );
  static Node _$child(Guard v) => v.child;
  static const Field<Guard, Node> _f$child = Field('child', _$child);

  @override
  final MappableFields<Guard> fields = const {
    #condition: _f$condition,
    #child: _f$child,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'Guard';
  @override
  late final ClassMapperBase superMapper = NodeMapper.ensureInitialized();

  static Guard _instantiate(DecodingData data) {
    return Guard(data.dec(_f$condition), data.dec(_f$child));
  }

  @override
  final Function instantiate = _instantiate;

  static Guard fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Guard>(map);
  }

  static Guard fromJson(String json) {
    return ensureInitialized().decodeJson<Guard>(json);
  }
}

mixin GuardMappable {
  String toJson() {
    return GuardMapper.ensureInitialized().encodeJson<Guard>(this as Guard);
  }

  Map<String, dynamic> toMap() {
    return GuardMapper.ensureInitialized().encodeMap<Guard>(this as Guard);
  }

  GuardCopyWith<Guard, Guard, Guard> get copyWith =>
      _GuardCopyWithImpl<Guard, Guard>(this as Guard, $identity, $identity);
  @override
  String toString() {
    return GuardMapper.ensureInitialized().stringifyValue(this as Guard);
  }

  @override
  bool operator ==(Object other) {
    return GuardMapper.ensureInitialized().equalsValue(this as Guard, other);
  }

  @override
  int get hashCode {
    return GuardMapper.ensureInitialized().hashValue(this as Guard);
  }
}

extension GuardValueCopy<$R, $Out> on ObjectCopyWith<$R, Guard, $Out> {
  GuardCopyWith<$R, Guard, $Out> get $asGuard =>
      $base.as((v, t, t2) => _GuardCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class GuardCopyWith<$R, $In extends Guard, $Out>
    implements NodeCopyWith<$R, $In, $Out> {
  NodeCopyWith<$R, Node, Node> get child;
  @override
  $R call({bool Function(Entity)? condition, Node? child});
  GuardCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _GuardCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Guard, $Out>
    implements GuardCopyWith<$R, Guard, $Out> {
  _GuardCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Guard> $mapper = GuardMapper.ensureInitialized();
  @override
  NodeCopyWith<$R, Node, Node> get child =>
      $value.child.copyWith.$chain((v) => call(child: v));
  @override
  $R call({bool Function(Entity)? condition, Node? child}) => $apply(
    FieldCopyWithData({
      if (condition != null) #condition: condition,
      if (child != null) #child: child,
    }),
  );
  @override
  Guard $make(CopyWithData data) => Guard(
    data.get(#condition, or: $value.condition),
    data.get(#child, or: $value.child),
  );

  @override
  GuardCopyWith<$R2, Guard, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _GuardCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class TimeoutMapper extends SubClassMapperBase<Timeout> {
  TimeoutMapper._();

  static TimeoutMapper? _instance;
  static TimeoutMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TimeoutMapper._());
      NodeMapper.ensureInitialized().addSubMapper(_instance!);
      NodeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Timeout';

  static Node _$child(Timeout v) => v.child;
  static const Field<Timeout, Node> _f$child = Field('child', _$child);
  static int _$timeoutMs(Timeout v) => v.timeoutMs;
  static const Field<Timeout, int> _f$timeoutMs = Field(
    'timeoutMs',
    _$timeoutMs,
  );

  @override
  final MappableFields<Timeout> fields = const {
    #child: _f$child,
    #timeoutMs: _f$timeoutMs,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'Timeout';
  @override
  late final ClassMapperBase superMapper = NodeMapper.ensureInitialized();

  static Timeout _instantiate(DecodingData data) {
    return Timeout(data.dec(_f$child), data.dec(_f$timeoutMs));
  }

  @override
  final Function instantiate = _instantiate;

  static Timeout fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Timeout>(map);
  }

  static Timeout fromJson(String json) {
    return ensureInitialized().decodeJson<Timeout>(json);
  }
}

mixin TimeoutMappable {
  String toJson() {
    return TimeoutMapper.ensureInitialized().encodeJson<Timeout>(
      this as Timeout,
    );
  }

  Map<String, dynamic> toMap() {
    return TimeoutMapper.ensureInitialized().encodeMap<Timeout>(
      this as Timeout,
    );
  }

  TimeoutCopyWith<Timeout, Timeout, Timeout> get copyWith =>
      _TimeoutCopyWithImpl<Timeout, Timeout>(
        this as Timeout,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return TimeoutMapper.ensureInitialized().stringifyValue(this as Timeout);
  }

  @override
  bool operator ==(Object other) {
    return TimeoutMapper.ensureInitialized().equalsValue(
      this as Timeout,
      other,
    );
  }

  @override
  int get hashCode {
    return TimeoutMapper.ensureInitialized().hashValue(this as Timeout);
  }
}

extension TimeoutValueCopy<$R, $Out> on ObjectCopyWith<$R, Timeout, $Out> {
  TimeoutCopyWith<$R, Timeout, $Out> get $asTimeout =>
      $base.as((v, t, t2) => _TimeoutCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TimeoutCopyWith<$R, $In extends Timeout, $Out>
    implements NodeCopyWith<$R, $In, $Out> {
  NodeCopyWith<$R, Node, Node> get child;
  @override
  $R call({Node? child, int? timeoutMs});
  TimeoutCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _TimeoutCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Timeout, $Out>
    implements TimeoutCopyWith<$R, Timeout, $Out> {
  _TimeoutCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Timeout> $mapper =
      TimeoutMapper.ensureInitialized();
  @override
  NodeCopyWith<$R, Node, Node> get child =>
      $value.child.copyWith.$chain((v) => call(child: v));
  @override
  $R call({Node? child, int? timeoutMs}) => $apply(
    FieldCopyWithData({
      if (child != null) #child: child,
      if (timeoutMs != null) #timeoutMs: timeoutMs,
    }),
  );
  @override
  Timeout $make(CopyWithData data) => Timeout(
    data.get(#child, or: $value.child),
    data.get(#timeoutMs, or: $value.timeoutMs),
  );

  @override
  TimeoutCopyWith<$R2, Timeout, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _TimeoutCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

