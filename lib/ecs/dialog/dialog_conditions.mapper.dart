// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'dialog_conditions.dart';

class DialogConditionMapper extends ClassMapperBase<DialogCondition> {
  DialogConditionMapper._();

  static DialogConditionMapper? _instance;
  static DialogConditionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DialogConditionMapper._());
      AlwaysConditionMapper.ensureInitialized();
      NeverConditionMapper.ensureInitialized();
      NotConditionMapper.ensureInitialized();
      AllConditionMapper.ensureInitialized();
      AnyConditionMapper.ensureInitialized();
      HasItemConditionMapper.ensureInitialized();
      HealthConditionMapper.ensureInitialized();
      HasComponentConditionMapper.ensureInitialized();
      CustomConditionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DialogCondition';

  @override
  final MappableFields<DialogCondition> fields = const {};

  static DialogCondition _instantiate(DecodingData data) {
    throw MapperException.missingSubclass(
      'DialogCondition',
      '__type',
      '${data.value['__type']}',
    );
  }

  @override
  final Function instantiate = _instantiate;

  static DialogCondition fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DialogCondition>(map);
  }

  static DialogCondition fromJson(String json) {
    return ensureInitialized().decodeJson<DialogCondition>(json);
  }
}

mixin DialogConditionMappable {
  String toJson();
  Map<String, dynamic> toMap();
  DialogConditionCopyWith<DialogCondition, DialogCondition, DialogCondition>
  get copyWith;
}

abstract class DialogConditionCopyWith<$R, $In extends DialogCondition, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  DialogConditionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class AlwaysConditionMapper extends SubClassMapperBase<AlwaysCondition> {
  AlwaysConditionMapper._();

  static AlwaysConditionMapper? _instance;
  static AlwaysConditionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AlwaysConditionMapper._());
      DialogConditionMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'AlwaysCondition';

  @override
  final MappableFields<AlwaysCondition> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'AlwaysCondition';
  @override
  late final ClassMapperBase superMapper =
      DialogConditionMapper.ensureInitialized();

  static AlwaysCondition _instantiate(DecodingData data) {
    return AlwaysCondition();
  }

  @override
  final Function instantiate = _instantiate;

  static AlwaysCondition fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AlwaysCondition>(map);
  }

  static AlwaysCondition fromJson(String json) {
    return ensureInitialized().decodeJson<AlwaysCondition>(json);
  }
}

mixin AlwaysConditionMappable {
  String toJson() {
    return AlwaysConditionMapper.ensureInitialized()
        .encodeJson<AlwaysCondition>(this as AlwaysCondition);
  }

  Map<String, dynamic> toMap() {
    return AlwaysConditionMapper.ensureInitialized().encodeMap<AlwaysCondition>(
      this as AlwaysCondition,
    );
  }

  AlwaysConditionCopyWith<AlwaysCondition, AlwaysCondition, AlwaysCondition>
  get copyWith =>
      _AlwaysConditionCopyWithImpl<AlwaysCondition, AlwaysCondition>(
        this as AlwaysCondition,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AlwaysConditionMapper.ensureInitialized().stringifyValue(
      this as AlwaysCondition,
    );
  }

  @override
  bool operator ==(Object other) {
    return AlwaysConditionMapper.ensureInitialized().equalsValue(
      this as AlwaysCondition,
      other,
    );
  }

  @override
  int get hashCode {
    return AlwaysConditionMapper.ensureInitialized().hashValue(
      this as AlwaysCondition,
    );
  }
}

extension AlwaysConditionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AlwaysCondition, $Out> {
  AlwaysConditionCopyWith<$R, AlwaysCondition, $Out> get $asAlwaysCondition =>
      $base.as((v, t, t2) => _AlwaysConditionCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AlwaysConditionCopyWith<$R, $In extends AlwaysCondition, $Out>
    implements DialogConditionCopyWith<$R, $In, $Out> {
  @override
  $R call();
  AlwaysConditionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _AlwaysConditionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AlwaysCondition, $Out>
    implements AlwaysConditionCopyWith<$R, AlwaysCondition, $Out> {
  _AlwaysConditionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AlwaysCondition> $mapper =
      AlwaysConditionMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  AlwaysCondition $make(CopyWithData data) => AlwaysCondition();

  @override
  AlwaysConditionCopyWith<$R2, AlwaysCondition, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _AlwaysConditionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class NeverConditionMapper extends SubClassMapperBase<NeverCondition> {
  NeverConditionMapper._();

  static NeverConditionMapper? _instance;
  static NeverConditionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = NeverConditionMapper._());
      DialogConditionMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'NeverCondition';

  @override
  final MappableFields<NeverCondition> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'NeverCondition';
  @override
  late final ClassMapperBase superMapper =
      DialogConditionMapper.ensureInitialized();

  static NeverCondition _instantiate(DecodingData data) {
    return NeverCondition();
  }

  @override
  final Function instantiate = _instantiate;

  static NeverCondition fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<NeverCondition>(map);
  }

  static NeverCondition fromJson(String json) {
    return ensureInitialized().decodeJson<NeverCondition>(json);
  }
}

mixin NeverConditionMappable {
  String toJson() {
    return NeverConditionMapper.ensureInitialized().encodeJson<NeverCondition>(
      this as NeverCondition,
    );
  }

  Map<String, dynamic> toMap() {
    return NeverConditionMapper.ensureInitialized().encodeMap<NeverCondition>(
      this as NeverCondition,
    );
  }

  NeverConditionCopyWith<NeverCondition, NeverCondition, NeverCondition>
  get copyWith => _NeverConditionCopyWithImpl<NeverCondition, NeverCondition>(
    this as NeverCondition,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return NeverConditionMapper.ensureInitialized().stringifyValue(
      this as NeverCondition,
    );
  }

  @override
  bool operator ==(Object other) {
    return NeverConditionMapper.ensureInitialized().equalsValue(
      this as NeverCondition,
      other,
    );
  }

  @override
  int get hashCode {
    return NeverConditionMapper.ensureInitialized().hashValue(
      this as NeverCondition,
    );
  }
}

extension NeverConditionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, NeverCondition, $Out> {
  NeverConditionCopyWith<$R, NeverCondition, $Out> get $asNeverCondition =>
      $base.as((v, t, t2) => _NeverConditionCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class NeverConditionCopyWith<$R, $In extends NeverCondition, $Out>
    implements DialogConditionCopyWith<$R, $In, $Out> {
  @override
  $R call();
  NeverConditionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _NeverConditionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, NeverCondition, $Out>
    implements NeverConditionCopyWith<$R, NeverCondition, $Out> {
  _NeverConditionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<NeverCondition> $mapper =
      NeverConditionMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  NeverCondition $make(CopyWithData data) => NeverCondition();

  @override
  NeverConditionCopyWith<$R2, NeverCondition, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _NeverConditionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class NotConditionMapper extends SubClassMapperBase<NotCondition> {
  NotConditionMapper._();

  static NotConditionMapper? _instance;
  static NotConditionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = NotConditionMapper._());
      DialogConditionMapper.ensureInitialized().addSubMapper(_instance!);
      DialogConditionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'NotCondition';

  static DialogCondition _$condition(NotCondition v) => v.condition;
  static const Field<NotCondition, DialogCondition> _f$condition = Field(
    'condition',
    _$condition,
  );

  @override
  final MappableFields<NotCondition> fields = const {#condition: _f$condition};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'NotCondition';
  @override
  late final ClassMapperBase superMapper =
      DialogConditionMapper.ensureInitialized();

  static NotCondition _instantiate(DecodingData data) {
    return NotCondition(data.dec(_f$condition));
  }

  @override
  final Function instantiate = _instantiate;

  static NotCondition fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<NotCondition>(map);
  }

  static NotCondition fromJson(String json) {
    return ensureInitialized().decodeJson<NotCondition>(json);
  }
}

mixin NotConditionMappable {
  String toJson() {
    return NotConditionMapper.ensureInitialized().encodeJson<NotCondition>(
      this as NotCondition,
    );
  }

  Map<String, dynamic> toMap() {
    return NotConditionMapper.ensureInitialized().encodeMap<NotCondition>(
      this as NotCondition,
    );
  }

  NotConditionCopyWith<NotCondition, NotCondition, NotCondition> get copyWith =>
      _NotConditionCopyWithImpl<NotCondition, NotCondition>(
        this as NotCondition,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return NotConditionMapper.ensureInitialized().stringifyValue(
      this as NotCondition,
    );
  }

  @override
  bool operator ==(Object other) {
    return NotConditionMapper.ensureInitialized().equalsValue(
      this as NotCondition,
      other,
    );
  }

  @override
  int get hashCode {
    return NotConditionMapper.ensureInitialized().hashValue(
      this as NotCondition,
    );
  }
}

extension NotConditionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, NotCondition, $Out> {
  NotConditionCopyWith<$R, NotCondition, $Out> get $asNotCondition =>
      $base.as((v, t, t2) => _NotConditionCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class NotConditionCopyWith<$R, $In extends NotCondition, $Out>
    implements DialogConditionCopyWith<$R, $In, $Out> {
  DialogConditionCopyWith<$R, DialogCondition, DialogCondition> get condition;
  @override
  $R call({DialogCondition? condition});
  NotConditionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _NotConditionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, NotCondition, $Out>
    implements NotConditionCopyWith<$R, NotCondition, $Out> {
  _NotConditionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<NotCondition> $mapper =
      NotConditionMapper.ensureInitialized();
  @override
  DialogConditionCopyWith<$R, DialogCondition, DialogCondition> get condition =>
      $value.condition.copyWith.$chain((v) => call(condition: v));
  @override
  $R call({DialogCondition? condition}) =>
      $apply(FieldCopyWithData({if (condition != null) #condition: condition}));
  @override
  NotCondition $make(CopyWithData data) =>
      NotCondition(data.get(#condition, or: $value.condition));

  @override
  NotConditionCopyWith<$R2, NotCondition, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _NotConditionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class AllConditionMapper extends SubClassMapperBase<AllCondition> {
  AllConditionMapper._();

  static AllConditionMapper? _instance;
  static AllConditionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AllConditionMapper._());
      DialogConditionMapper.ensureInitialized().addSubMapper(_instance!);
      DialogConditionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AllCondition';

  static List<DialogCondition> _$conditions(AllCondition v) => v.conditions;
  static const Field<AllCondition, List<DialogCondition>> _f$conditions = Field(
    'conditions',
    _$conditions,
  );

  @override
  final MappableFields<AllCondition> fields = const {
    #conditions: _f$conditions,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'AllCondition';
  @override
  late final ClassMapperBase superMapper =
      DialogConditionMapper.ensureInitialized();

  static AllCondition _instantiate(DecodingData data) {
    return AllCondition(data.dec(_f$conditions));
  }

  @override
  final Function instantiate = _instantiate;

  static AllCondition fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AllCondition>(map);
  }

  static AllCondition fromJson(String json) {
    return ensureInitialized().decodeJson<AllCondition>(json);
  }
}

mixin AllConditionMappable {
  String toJson() {
    return AllConditionMapper.ensureInitialized().encodeJson<AllCondition>(
      this as AllCondition,
    );
  }

  Map<String, dynamic> toMap() {
    return AllConditionMapper.ensureInitialized().encodeMap<AllCondition>(
      this as AllCondition,
    );
  }

  AllConditionCopyWith<AllCondition, AllCondition, AllCondition> get copyWith =>
      _AllConditionCopyWithImpl<AllCondition, AllCondition>(
        this as AllCondition,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AllConditionMapper.ensureInitialized().stringifyValue(
      this as AllCondition,
    );
  }

  @override
  bool operator ==(Object other) {
    return AllConditionMapper.ensureInitialized().equalsValue(
      this as AllCondition,
      other,
    );
  }

  @override
  int get hashCode {
    return AllConditionMapper.ensureInitialized().hashValue(
      this as AllCondition,
    );
  }
}

extension AllConditionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AllCondition, $Out> {
  AllConditionCopyWith<$R, AllCondition, $Out> get $asAllCondition =>
      $base.as((v, t, t2) => _AllConditionCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AllConditionCopyWith<$R, $In extends AllCondition, $Out>
    implements DialogConditionCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    DialogCondition,
    DialogConditionCopyWith<$R, DialogCondition, DialogCondition>
  >
  get conditions;
  @override
  $R call({List<DialogCondition>? conditions});
  AllConditionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AllConditionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AllCondition, $Out>
    implements AllConditionCopyWith<$R, AllCondition, $Out> {
  _AllConditionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AllCondition> $mapper =
      AllConditionMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    DialogCondition,
    DialogConditionCopyWith<$R, DialogCondition, DialogCondition>
  >
  get conditions => ListCopyWith(
    $value.conditions,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(conditions: v),
  );
  @override
  $R call({List<DialogCondition>? conditions}) => $apply(
    FieldCopyWithData({if (conditions != null) #conditions: conditions}),
  );
  @override
  AllCondition $make(CopyWithData data) =>
      AllCondition(data.get(#conditions, or: $value.conditions));

  @override
  AllConditionCopyWith<$R2, AllCondition, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _AllConditionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class AnyConditionMapper extends SubClassMapperBase<AnyCondition> {
  AnyConditionMapper._();

  static AnyConditionMapper? _instance;
  static AnyConditionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AnyConditionMapper._());
      DialogConditionMapper.ensureInitialized().addSubMapper(_instance!);
      DialogConditionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AnyCondition';

  static List<DialogCondition> _$conditions(AnyCondition v) => v.conditions;
  static const Field<AnyCondition, List<DialogCondition>> _f$conditions = Field(
    'conditions',
    _$conditions,
  );

  @override
  final MappableFields<AnyCondition> fields = const {
    #conditions: _f$conditions,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'AnyCondition';
  @override
  late final ClassMapperBase superMapper =
      DialogConditionMapper.ensureInitialized();

  static AnyCondition _instantiate(DecodingData data) {
    return AnyCondition(data.dec(_f$conditions));
  }

  @override
  final Function instantiate = _instantiate;

  static AnyCondition fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AnyCondition>(map);
  }

  static AnyCondition fromJson(String json) {
    return ensureInitialized().decodeJson<AnyCondition>(json);
  }
}

mixin AnyConditionMappable {
  String toJson() {
    return AnyConditionMapper.ensureInitialized().encodeJson<AnyCondition>(
      this as AnyCondition,
    );
  }

  Map<String, dynamic> toMap() {
    return AnyConditionMapper.ensureInitialized().encodeMap<AnyCondition>(
      this as AnyCondition,
    );
  }

  AnyConditionCopyWith<AnyCondition, AnyCondition, AnyCondition> get copyWith =>
      _AnyConditionCopyWithImpl<AnyCondition, AnyCondition>(
        this as AnyCondition,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AnyConditionMapper.ensureInitialized().stringifyValue(
      this as AnyCondition,
    );
  }

  @override
  bool operator ==(Object other) {
    return AnyConditionMapper.ensureInitialized().equalsValue(
      this as AnyCondition,
      other,
    );
  }

  @override
  int get hashCode {
    return AnyConditionMapper.ensureInitialized().hashValue(
      this as AnyCondition,
    );
  }
}

extension AnyConditionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AnyCondition, $Out> {
  AnyConditionCopyWith<$R, AnyCondition, $Out> get $asAnyCondition =>
      $base.as((v, t, t2) => _AnyConditionCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AnyConditionCopyWith<$R, $In extends AnyCondition, $Out>
    implements DialogConditionCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    DialogCondition,
    DialogConditionCopyWith<$R, DialogCondition, DialogCondition>
  >
  get conditions;
  @override
  $R call({List<DialogCondition>? conditions});
  AnyConditionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AnyConditionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AnyCondition, $Out>
    implements AnyConditionCopyWith<$R, AnyCondition, $Out> {
  _AnyConditionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AnyCondition> $mapper =
      AnyConditionMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    DialogCondition,
    DialogConditionCopyWith<$R, DialogCondition, DialogCondition>
  >
  get conditions => ListCopyWith(
    $value.conditions,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(conditions: v),
  );
  @override
  $R call({List<DialogCondition>? conditions}) => $apply(
    FieldCopyWithData({if (conditions != null) #conditions: conditions}),
  );
  @override
  AnyCondition $make(CopyWithData data) =>
      AnyCondition(data.get(#conditions, or: $value.conditions));

  @override
  AnyConditionCopyWith<$R2, AnyCondition, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _AnyConditionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class HasItemConditionMapper extends SubClassMapperBase<HasItemCondition> {
  HasItemConditionMapper._();

  static HasItemConditionMapper? _instance;
  static HasItemConditionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = HasItemConditionMapper._());
      DialogConditionMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'HasItemCondition';

  static String _$itemIdentifier(HasItemCondition v) => v.itemIdentifier;
  static const Field<HasItemCondition, String> _f$itemIdentifier = Field(
    'itemIdentifier',
    _$itemIdentifier,
  );
  static int _$minCount(HasItemCondition v) => v.minCount;
  static const Field<HasItemCondition, int> _f$minCount = Field(
    'minCount',
    _$minCount,
    opt: true,
    def: 1,
  );

  @override
  final MappableFields<HasItemCondition> fields = const {
    #itemIdentifier: _f$itemIdentifier,
    #minCount: _f$minCount,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'HasItemCondition';
  @override
  late final ClassMapperBase superMapper =
      DialogConditionMapper.ensureInitialized();

  static HasItemCondition _instantiate(DecodingData data) {
    return HasItemCondition(
      itemIdentifier: data.dec(_f$itemIdentifier),
      minCount: data.dec(_f$minCount),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static HasItemCondition fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<HasItemCondition>(map);
  }

  static HasItemCondition fromJson(String json) {
    return ensureInitialized().decodeJson<HasItemCondition>(json);
  }
}

mixin HasItemConditionMappable {
  String toJson() {
    return HasItemConditionMapper.ensureInitialized()
        .encodeJson<HasItemCondition>(this as HasItemCondition);
  }

  Map<String, dynamic> toMap() {
    return HasItemConditionMapper.ensureInitialized()
        .encodeMap<HasItemCondition>(this as HasItemCondition);
  }

  HasItemConditionCopyWith<HasItemCondition, HasItemCondition, HasItemCondition>
  get copyWith =>
      _HasItemConditionCopyWithImpl<HasItemCondition, HasItemCondition>(
        this as HasItemCondition,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return HasItemConditionMapper.ensureInitialized().stringifyValue(
      this as HasItemCondition,
    );
  }

  @override
  bool operator ==(Object other) {
    return HasItemConditionMapper.ensureInitialized().equalsValue(
      this as HasItemCondition,
      other,
    );
  }

  @override
  int get hashCode {
    return HasItemConditionMapper.ensureInitialized().hashValue(
      this as HasItemCondition,
    );
  }
}

extension HasItemConditionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, HasItemCondition, $Out> {
  HasItemConditionCopyWith<$R, HasItemCondition, $Out>
  get $asHasItemCondition =>
      $base.as((v, t, t2) => _HasItemConditionCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class HasItemConditionCopyWith<$R, $In extends HasItemCondition, $Out>
    implements DialogConditionCopyWith<$R, $In, $Out> {
  @override
  $R call({String? itemIdentifier, int? minCount});
  HasItemConditionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _HasItemConditionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, HasItemCondition, $Out>
    implements HasItemConditionCopyWith<$R, HasItemCondition, $Out> {
  _HasItemConditionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<HasItemCondition> $mapper =
      HasItemConditionMapper.ensureInitialized();
  @override
  $R call({String? itemIdentifier, int? minCount}) => $apply(
    FieldCopyWithData({
      if (itemIdentifier != null) #itemIdentifier: itemIdentifier,
      if (minCount != null) #minCount: minCount,
    }),
  );
  @override
  HasItemCondition $make(CopyWithData data) => HasItemCondition(
    itemIdentifier: data.get(#itemIdentifier, or: $value.itemIdentifier),
    minCount: data.get(#minCount, or: $value.minCount),
  );

  @override
  HasItemConditionCopyWith<$R2, HasItemCondition, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _HasItemConditionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class HealthConditionMapper extends SubClassMapperBase<HealthCondition> {
  HealthConditionMapper._();

  static HealthConditionMapper? _instance;
  static HealthConditionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = HealthConditionMapper._());
      DialogConditionMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'HealthCondition';

  static int? _$minHealth(HealthCondition v) => v.minHealth;
  static const Field<HealthCondition, int> _f$minHealth = Field(
    'minHealth',
    _$minHealth,
    opt: true,
  );
  static int? _$maxHealth(HealthCondition v) => v.maxHealth;
  static const Field<HealthCondition, int> _f$maxHealth = Field(
    'maxHealth',
    _$maxHealth,
    opt: true,
  );
  static double? _$minPercentage(HealthCondition v) => v.minPercentage;
  static const Field<HealthCondition, double> _f$minPercentage = Field(
    'minPercentage',
    _$minPercentage,
    opt: true,
  );
  static double? _$maxPercentage(HealthCondition v) => v.maxPercentage;
  static const Field<HealthCondition, double> _f$maxPercentage = Field(
    'maxPercentage',
    _$maxPercentage,
    opt: true,
  );

  @override
  final MappableFields<HealthCondition> fields = const {
    #minHealth: _f$minHealth,
    #maxHealth: _f$maxHealth,
    #minPercentage: _f$minPercentage,
    #maxPercentage: _f$maxPercentage,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'HealthCondition';
  @override
  late final ClassMapperBase superMapper =
      DialogConditionMapper.ensureInitialized();

  static HealthCondition _instantiate(DecodingData data) {
    return HealthCondition(
      minHealth: data.dec(_f$minHealth),
      maxHealth: data.dec(_f$maxHealth),
      minPercentage: data.dec(_f$minPercentage),
      maxPercentage: data.dec(_f$maxPercentage),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static HealthCondition fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<HealthCondition>(map);
  }

  static HealthCondition fromJson(String json) {
    return ensureInitialized().decodeJson<HealthCondition>(json);
  }
}

mixin HealthConditionMappable {
  String toJson() {
    return HealthConditionMapper.ensureInitialized()
        .encodeJson<HealthCondition>(this as HealthCondition);
  }

  Map<String, dynamic> toMap() {
    return HealthConditionMapper.ensureInitialized().encodeMap<HealthCondition>(
      this as HealthCondition,
    );
  }

  HealthConditionCopyWith<HealthCondition, HealthCondition, HealthCondition>
  get copyWith =>
      _HealthConditionCopyWithImpl<HealthCondition, HealthCondition>(
        this as HealthCondition,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return HealthConditionMapper.ensureInitialized().stringifyValue(
      this as HealthCondition,
    );
  }

  @override
  bool operator ==(Object other) {
    return HealthConditionMapper.ensureInitialized().equalsValue(
      this as HealthCondition,
      other,
    );
  }

  @override
  int get hashCode {
    return HealthConditionMapper.ensureInitialized().hashValue(
      this as HealthCondition,
    );
  }
}

extension HealthConditionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, HealthCondition, $Out> {
  HealthConditionCopyWith<$R, HealthCondition, $Out> get $asHealthCondition =>
      $base.as((v, t, t2) => _HealthConditionCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class HealthConditionCopyWith<$R, $In extends HealthCondition, $Out>
    implements DialogConditionCopyWith<$R, $In, $Out> {
  @override
  $R call({
    int? minHealth,
    int? maxHealth,
    double? minPercentage,
    double? maxPercentage,
  });
  HealthConditionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _HealthConditionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, HealthCondition, $Out>
    implements HealthConditionCopyWith<$R, HealthCondition, $Out> {
  _HealthConditionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<HealthCondition> $mapper =
      HealthConditionMapper.ensureInitialized();
  @override
  $R call({
    Object? minHealth = $none,
    Object? maxHealth = $none,
    Object? minPercentage = $none,
    Object? maxPercentage = $none,
  }) => $apply(
    FieldCopyWithData({
      if (minHealth != $none) #minHealth: minHealth,
      if (maxHealth != $none) #maxHealth: maxHealth,
      if (minPercentage != $none) #minPercentage: minPercentage,
      if (maxPercentage != $none) #maxPercentage: maxPercentage,
    }),
  );
  @override
  HealthCondition $make(CopyWithData data) => HealthCondition(
    minHealth: data.get(#minHealth, or: $value.minHealth),
    maxHealth: data.get(#maxHealth, or: $value.maxHealth),
    minPercentage: data.get(#minPercentage, or: $value.minPercentage),
    maxPercentage: data.get(#maxPercentage, or: $value.maxPercentage),
  );

  @override
  HealthConditionCopyWith<$R2, HealthCondition, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _HealthConditionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class HasComponentConditionMapper
    extends SubClassMapperBase<HasComponentCondition> {
  HasComponentConditionMapper._();

  static HasComponentConditionMapper? _instance;
  static HasComponentConditionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = HasComponentConditionMapper._());
      DialogConditionMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'HasComponentCondition';

  static String _$componentType(HasComponentCondition v) => v.componentType;
  static const Field<HasComponentCondition, String> _f$componentType = Field(
    'componentType',
    _$componentType,
  );
  static bool _$checkPlayer(HasComponentCondition v) => v.checkPlayer;
  static const Field<HasComponentCondition, bool> _f$checkPlayer = Field(
    'checkPlayer',
    _$checkPlayer,
    opt: true,
    def: true,
  );

  @override
  final MappableFields<HasComponentCondition> fields = const {
    #componentType: _f$componentType,
    #checkPlayer: _f$checkPlayer,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'HasComponentCondition';
  @override
  late final ClassMapperBase superMapper =
      DialogConditionMapper.ensureInitialized();

  static HasComponentCondition _instantiate(DecodingData data) {
    return HasComponentCondition(
      componentType: data.dec(_f$componentType),
      checkPlayer: data.dec(_f$checkPlayer),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static HasComponentCondition fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<HasComponentCondition>(map);
  }

  static HasComponentCondition fromJson(String json) {
    return ensureInitialized().decodeJson<HasComponentCondition>(json);
  }
}

mixin HasComponentConditionMappable {
  String toJson() {
    return HasComponentConditionMapper.ensureInitialized()
        .encodeJson<HasComponentCondition>(this as HasComponentCondition);
  }

  Map<String, dynamic> toMap() {
    return HasComponentConditionMapper.ensureInitialized()
        .encodeMap<HasComponentCondition>(this as HasComponentCondition);
  }

  HasComponentConditionCopyWith<
    HasComponentCondition,
    HasComponentCondition,
    HasComponentCondition
  >
  get copyWith =>
      _HasComponentConditionCopyWithImpl<
        HasComponentCondition,
        HasComponentCondition
      >(this as HasComponentCondition, $identity, $identity);
  @override
  String toString() {
    return HasComponentConditionMapper.ensureInitialized().stringifyValue(
      this as HasComponentCondition,
    );
  }

  @override
  bool operator ==(Object other) {
    return HasComponentConditionMapper.ensureInitialized().equalsValue(
      this as HasComponentCondition,
      other,
    );
  }

  @override
  int get hashCode {
    return HasComponentConditionMapper.ensureInitialized().hashValue(
      this as HasComponentCondition,
    );
  }
}

extension HasComponentConditionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, HasComponentCondition, $Out> {
  HasComponentConditionCopyWith<$R, HasComponentCondition, $Out>
  get $asHasComponentCondition => $base.as(
    (v, t, t2) => _HasComponentConditionCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class HasComponentConditionCopyWith<
  $R,
  $In extends HasComponentCondition,
  $Out
>
    implements DialogConditionCopyWith<$R, $In, $Out> {
  @override
  $R call({String? componentType, bool? checkPlayer});
  HasComponentConditionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _HasComponentConditionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, HasComponentCondition, $Out>
    implements HasComponentConditionCopyWith<$R, HasComponentCondition, $Out> {
  _HasComponentConditionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<HasComponentCondition> $mapper =
      HasComponentConditionMapper.ensureInitialized();
  @override
  $R call({String? componentType, bool? checkPlayer}) => $apply(
    FieldCopyWithData({
      if (componentType != null) #componentType: componentType,
      if (checkPlayer != null) #checkPlayer: checkPlayer,
    }),
  );
  @override
  HasComponentCondition $make(CopyWithData data) => HasComponentCondition(
    componentType: data.get(#componentType, or: $value.componentType),
    checkPlayer: data.get(#checkPlayer, or: $value.checkPlayer),
  );

  @override
  HasComponentConditionCopyWith<$R2, HasComponentCondition, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _HasComponentConditionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CustomConditionMapper extends SubClassMapperBase<CustomCondition> {
  CustomConditionMapper._();

  static CustomConditionMapper? _instance;
  static CustomConditionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CustomConditionMapper._());
      DialogConditionMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'CustomCondition';

  static Function? _$evaluator(CustomCondition v) =>
      (v as dynamic).evaluator as Function?;
  static dynamic _arg$evaluator(f) => f<bool Function(Entity, Entity)>();
  static const Field<CustomCondition, Function?> _f$evaluator = Field(
    'evaluator',
    _$evaluator,
    opt: true,
    arg: _arg$evaluator,
    hook: IgnoreHook(),
  );
  static bool _$fallbackValue(CustomCondition v) => v.fallbackValue;
  static const Field<CustomCondition, bool> _f$fallbackValue = Field(
    'fallbackValue',
    _$fallbackValue,
    opt: true,
    def: false,
  );

  @override
  final MappableFields<CustomCondition> fields = const {
    #evaluator: _f$evaluator,
    #fallbackValue: _f$fallbackValue,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'CustomCondition';
  @override
  late final ClassMapperBase superMapper =
      DialogConditionMapper.ensureInitialized();

  static CustomCondition _instantiate(DecodingData data) {
    return CustomCondition(
      evaluator: data.dec(_f$evaluator),
      fallbackValue: data.dec(_f$fallbackValue),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CustomCondition fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CustomCondition>(map);
  }

  static CustomCondition fromJson(String json) {
    return ensureInitialized().decodeJson<CustomCondition>(json);
  }
}

mixin CustomConditionMappable {
  String toJson() {
    return CustomConditionMapper.ensureInitialized()
        .encodeJson<CustomCondition>(this as CustomCondition);
  }

  Map<String, dynamic> toMap() {
    return CustomConditionMapper.ensureInitialized().encodeMap<CustomCondition>(
      this as CustomCondition,
    );
  }

  CustomConditionCopyWith<CustomCondition, CustomCondition, CustomCondition>
  get copyWith =>
      _CustomConditionCopyWithImpl<CustomCondition, CustomCondition>(
        this as CustomCondition,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CustomConditionMapper.ensureInitialized().stringifyValue(
      this as CustomCondition,
    );
  }

  @override
  bool operator ==(Object other) {
    return CustomConditionMapper.ensureInitialized().equalsValue(
      this as CustomCondition,
      other,
    );
  }

  @override
  int get hashCode {
    return CustomConditionMapper.ensureInitialized().hashValue(
      this as CustomCondition,
    );
  }
}

extension CustomConditionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CustomCondition, $Out> {
  CustomConditionCopyWith<$R, CustomCondition, $Out> get $asCustomCondition =>
      $base.as((v, t, t2) => _CustomConditionCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CustomConditionCopyWith<$R, $In extends CustomCondition, $Out>
    implements DialogConditionCopyWith<$R, $In, $Out> {
  @override
  $R call({bool Function(Entity, Entity)? evaluator, bool? fallbackValue});
  CustomConditionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CustomConditionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CustomCondition, $Out>
    implements CustomConditionCopyWith<$R, CustomCondition, $Out> {
  _CustomConditionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CustomCondition> $mapper =
      CustomConditionMapper.ensureInitialized();
  @override
  $R call({Object? evaluator = $none, bool? fallbackValue}) => $apply(
    FieldCopyWithData({
      if (evaluator != $none) #evaluator: evaluator,
      if (fallbackValue != null) #fallbackValue: fallbackValue,
    }),
  );
  @override
  CustomCondition $make(CopyWithData data) => CustomCondition(
    evaluator: data.get(#evaluator, or: $value.evaluator),
    fallbackValue: data.get(#fallbackValue, or: $value.fallbackValue),
  );

  @override
  CustomConditionCopyWith<$R2, CustomCondition, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CustomConditionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

