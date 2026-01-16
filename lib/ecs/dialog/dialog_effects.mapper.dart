// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'dialog_effects.dart';

class DialogEffectMapper extends ClassMapperBase<DialogEffect> {
  DialogEffectMapper._();

  static DialogEffectMapper? _instance;
  static DialogEffectMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DialogEffectMapper._());
      TriggerTickEffectMapper.ensureInitialized();
      HealEffectMapper.ensureInitialized();
      DamageEffectMapper.ensureInitialized();
      GiveItemEffectMapper.ensureInitialized();
      RemoveItemEffectMapper.ensureInitialized();
      TeleportEffectMapper.ensureInitialized();
      MoveEntityEffectMapper.ensureInitialized();
      OpenDoorEffectMapper.ensureInitialized();
      CloseDoorEffectMapper.ensureInitialized();
      SetParentEffectMapper.ensureInitialized();
      RemoveParentEffectMapper.ensureInitialized();
      AddComponentEffectMapper.ensureInitialized();
      RemoveComponentEffectMapper.ensureInitialized();
      SequenceEffectMapper.ensureInitialized();
      CustomEffectMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DialogEffect';

  @override
  final MappableFields<DialogEffect> fields = const {};

  static DialogEffect _instantiate(DecodingData data) {
    throw MapperException.missingSubclass(
      'DialogEffect',
      '__type',
      '${data.value['__type']}',
    );
  }

  @override
  final Function instantiate = _instantiate;

  static DialogEffect fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DialogEffect>(map);
  }

  static DialogEffect fromJson(String json) {
    return ensureInitialized().decodeJson<DialogEffect>(json);
  }
}

mixin DialogEffectMappable {
  String toJson();
  Map<String, dynamic> toMap();
  DialogEffectCopyWith<DialogEffect, DialogEffect, DialogEffect> get copyWith;
}

abstract class DialogEffectCopyWith<$R, $In extends DialogEffect, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  DialogEffectCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class TriggerTickEffectMapper extends SubClassMapperBase<TriggerTickEffect> {
  TriggerTickEffectMapper._();

  static TriggerTickEffectMapper? _instance;
  static TriggerTickEffectMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TriggerTickEffectMapper._());
      DialogEffectMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'TriggerTickEffect';

  static int _$count(TriggerTickEffect v) => v.count;
  static const Field<TriggerTickEffect, int> _f$count = Field(
    'count',
    _$count,
    opt: true,
    def: 1,
  );

  @override
  final MappableFields<TriggerTickEffect> fields = const {#count: _f$count};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'TriggerTickEffect';
  @override
  late final ClassMapperBase superMapper =
      DialogEffectMapper.ensureInitialized();

  static TriggerTickEffect _instantiate(DecodingData data) {
    return TriggerTickEffect(count: data.dec(_f$count));
  }

  @override
  final Function instantiate = _instantiate;

  static TriggerTickEffect fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TriggerTickEffect>(map);
  }

  static TriggerTickEffect fromJson(String json) {
    return ensureInitialized().decodeJson<TriggerTickEffect>(json);
  }
}

mixin TriggerTickEffectMappable {
  String toJson() {
    return TriggerTickEffectMapper.ensureInitialized()
        .encodeJson<TriggerTickEffect>(this as TriggerTickEffect);
  }

  Map<String, dynamic> toMap() {
    return TriggerTickEffectMapper.ensureInitialized()
        .encodeMap<TriggerTickEffect>(this as TriggerTickEffect);
  }

  TriggerTickEffectCopyWith<
    TriggerTickEffect,
    TriggerTickEffect,
    TriggerTickEffect
  >
  get copyWith =>
      _TriggerTickEffectCopyWithImpl<TriggerTickEffect, TriggerTickEffect>(
        this as TriggerTickEffect,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return TriggerTickEffectMapper.ensureInitialized().stringifyValue(
      this as TriggerTickEffect,
    );
  }

  @override
  bool operator ==(Object other) {
    return TriggerTickEffectMapper.ensureInitialized().equalsValue(
      this as TriggerTickEffect,
      other,
    );
  }

  @override
  int get hashCode {
    return TriggerTickEffectMapper.ensureInitialized().hashValue(
      this as TriggerTickEffect,
    );
  }
}

extension TriggerTickEffectValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TriggerTickEffect, $Out> {
  TriggerTickEffectCopyWith<$R, TriggerTickEffect, $Out>
  get $asTriggerTickEffect => $base.as(
    (v, t, t2) => _TriggerTickEffectCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class TriggerTickEffectCopyWith<
  $R,
  $In extends TriggerTickEffect,
  $Out
>
    implements DialogEffectCopyWith<$R, $In, $Out> {
  @override
  $R call({int? count});
  TriggerTickEffectCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _TriggerTickEffectCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TriggerTickEffect, $Out>
    implements TriggerTickEffectCopyWith<$R, TriggerTickEffect, $Out> {
  _TriggerTickEffectCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TriggerTickEffect> $mapper =
      TriggerTickEffectMapper.ensureInitialized();
  @override
  $R call({int? count}) =>
      $apply(FieldCopyWithData({if (count != null) #count: count}));
  @override
  TriggerTickEffect $make(CopyWithData data) =>
      TriggerTickEffect(count: data.get(#count, or: $value.count));

  @override
  TriggerTickEffectCopyWith<$R2, TriggerTickEffect, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TriggerTickEffectCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class HealEffectMapper extends SubClassMapperBase<HealEffect> {
  HealEffectMapper._();

  static HealEffectMapper? _instance;
  static HealEffectMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = HealEffectMapper._());
      DialogEffectMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'HealEffect';

  static int? _$amount(HealEffect v) => v.amount;
  static const Field<HealEffect, int> _f$amount = Field(
    'amount',
    _$amount,
    opt: true,
  );
  static bool _$fullHeal(HealEffect v) => v.fullHeal;
  static const Field<HealEffect, bool> _f$fullHeal = Field(
    'fullHeal',
    _$fullHeal,
    opt: true,
    def: false,
  );
  static bool _$targetPlayer(HealEffect v) => v.targetPlayer;
  static const Field<HealEffect, bool> _f$targetPlayer = Field(
    'targetPlayer',
    _$targetPlayer,
    opt: true,
    def: true,
  );

  @override
  final MappableFields<HealEffect> fields = const {
    #amount: _f$amount,
    #fullHeal: _f$fullHeal,
    #targetPlayer: _f$targetPlayer,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'HealEffect';
  @override
  late final ClassMapperBase superMapper =
      DialogEffectMapper.ensureInitialized();

  static HealEffect _instantiate(DecodingData data) {
    return HealEffect(
      amount: data.dec(_f$amount),
      fullHeal: data.dec(_f$fullHeal),
      targetPlayer: data.dec(_f$targetPlayer),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static HealEffect fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<HealEffect>(map);
  }

  static HealEffect fromJson(String json) {
    return ensureInitialized().decodeJson<HealEffect>(json);
  }
}

mixin HealEffectMappable {
  String toJson() {
    return HealEffectMapper.ensureInitialized().encodeJson<HealEffect>(
      this as HealEffect,
    );
  }

  Map<String, dynamic> toMap() {
    return HealEffectMapper.ensureInitialized().encodeMap<HealEffect>(
      this as HealEffect,
    );
  }

  HealEffectCopyWith<HealEffect, HealEffect, HealEffect> get copyWith =>
      _HealEffectCopyWithImpl<HealEffect, HealEffect>(
        this as HealEffect,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return HealEffectMapper.ensureInitialized().stringifyValue(
      this as HealEffect,
    );
  }

  @override
  bool operator ==(Object other) {
    return HealEffectMapper.ensureInitialized().equalsValue(
      this as HealEffect,
      other,
    );
  }

  @override
  int get hashCode {
    return HealEffectMapper.ensureInitialized().hashValue(this as HealEffect);
  }
}

extension HealEffectValueCopy<$R, $Out>
    on ObjectCopyWith<$R, HealEffect, $Out> {
  HealEffectCopyWith<$R, HealEffect, $Out> get $asHealEffect =>
      $base.as((v, t, t2) => _HealEffectCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class HealEffectCopyWith<$R, $In extends HealEffect, $Out>
    implements DialogEffectCopyWith<$R, $In, $Out> {
  @override
  $R call({int? amount, bool? fullHeal, bool? targetPlayer});
  HealEffectCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _HealEffectCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, HealEffect, $Out>
    implements HealEffectCopyWith<$R, HealEffect, $Out> {
  _HealEffectCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<HealEffect> $mapper =
      HealEffectMapper.ensureInitialized();
  @override
  $R call({Object? amount = $none, bool? fullHeal, bool? targetPlayer}) =>
      $apply(
        FieldCopyWithData({
          if (amount != $none) #amount: amount,
          if (fullHeal != null) #fullHeal: fullHeal,
          if (targetPlayer != null) #targetPlayer: targetPlayer,
        }),
      );
  @override
  HealEffect $make(CopyWithData data) => HealEffect(
    amount: data.get(#amount, or: $value.amount),
    fullHeal: data.get(#fullHeal, or: $value.fullHeal),
    targetPlayer: data.get(#targetPlayer, or: $value.targetPlayer),
  );

  @override
  HealEffectCopyWith<$R2, HealEffect, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _HealEffectCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DamageEffectMapper extends SubClassMapperBase<DamageEffect> {
  DamageEffectMapper._();

  static DamageEffectMapper? _instance;
  static DamageEffectMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DamageEffectMapper._());
      DialogEffectMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'DamageEffect';

  static int _$amount(DamageEffect v) => v.amount;
  static const Field<DamageEffect, int> _f$amount = Field('amount', _$amount);
  static bool _$targetPlayer(DamageEffect v) => v.targetPlayer;
  static const Field<DamageEffect, bool> _f$targetPlayer = Field(
    'targetPlayer',
    _$targetPlayer,
    opt: true,
    def: true,
  );

  @override
  final MappableFields<DamageEffect> fields = const {
    #amount: _f$amount,
    #targetPlayer: _f$targetPlayer,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'DamageEffect';
  @override
  late final ClassMapperBase superMapper =
      DialogEffectMapper.ensureInitialized();

  static DamageEffect _instantiate(DecodingData data) {
    return DamageEffect(
      amount: data.dec(_f$amount),
      targetPlayer: data.dec(_f$targetPlayer),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static DamageEffect fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DamageEffect>(map);
  }

  static DamageEffect fromJson(String json) {
    return ensureInitialized().decodeJson<DamageEffect>(json);
  }
}

mixin DamageEffectMappable {
  String toJson() {
    return DamageEffectMapper.ensureInitialized().encodeJson<DamageEffect>(
      this as DamageEffect,
    );
  }

  Map<String, dynamic> toMap() {
    return DamageEffectMapper.ensureInitialized().encodeMap<DamageEffect>(
      this as DamageEffect,
    );
  }

  DamageEffectCopyWith<DamageEffect, DamageEffect, DamageEffect> get copyWith =>
      _DamageEffectCopyWithImpl<DamageEffect, DamageEffect>(
        this as DamageEffect,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DamageEffectMapper.ensureInitialized().stringifyValue(
      this as DamageEffect,
    );
  }

  @override
  bool operator ==(Object other) {
    return DamageEffectMapper.ensureInitialized().equalsValue(
      this as DamageEffect,
      other,
    );
  }

  @override
  int get hashCode {
    return DamageEffectMapper.ensureInitialized().hashValue(
      this as DamageEffect,
    );
  }
}

extension DamageEffectValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DamageEffect, $Out> {
  DamageEffectCopyWith<$R, DamageEffect, $Out> get $asDamageEffect =>
      $base.as((v, t, t2) => _DamageEffectCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DamageEffectCopyWith<$R, $In extends DamageEffect, $Out>
    implements DialogEffectCopyWith<$R, $In, $Out> {
  @override
  $R call({int? amount, bool? targetPlayer});
  DamageEffectCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DamageEffectCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DamageEffect, $Out>
    implements DamageEffectCopyWith<$R, DamageEffect, $Out> {
  _DamageEffectCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DamageEffect> $mapper =
      DamageEffectMapper.ensureInitialized();
  @override
  $R call({int? amount, bool? targetPlayer}) => $apply(
    FieldCopyWithData({
      if (amount != null) #amount: amount,
      if (targetPlayer != null) #targetPlayer: targetPlayer,
    }),
  );
  @override
  DamageEffect $make(CopyWithData data) => DamageEffect(
    amount: data.get(#amount, or: $value.amount),
    targetPlayer: data.get(#targetPlayer, or: $value.targetPlayer),
  );

  @override
  DamageEffectCopyWith<$R2, DamageEffect, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DamageEffectCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class GiveItemEffectMapper extends SubClassMapperBase<GiveItemEffect> {
  GiveItemEffectMapper._();

  static GiveItemEffectMapper? _instance;
  static GiveItemEffectMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = GiveItemEffectMapper._());
      DialogEffectMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'GiveItemEffect';

  static String _$itemName(GiveItemEffect v) => v.itemName;
  static const Field<GiveItemEffect, String> _f$itemName = Field(
    'itemName',
    _$itemName,
  );
  static int _$count(GiveItemEffect v) => v.count;
  static const Field<GiveItemEffect, int> _f$count = Field(
    'count',
    _$count,
    opt: true,
    def: 1,
  );

  @override
  final MappableFields<GiveItemEffect> fields = const {
    #itemName: _f$itemName,
    #count: _f$count,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'GiveItemEffect';
  @override
  late final ClassMapperBase superMapper =
      DialogEffectMapper.ensureInitialized();

  static GiveItemEffect _instantiate(DecodingData data) {
    return GiveItemEffect(
      itemName: data.dec(_f$itemName),
      count: data.dec(_f$count),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static GiveItemEffect fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<GiveItemEffect>(map);
  }

  static GiveItemEffect fromJson(String json) {
    return ensureInitialized().decodeJson<GiveItemEffect>(json);
  }
}

mixin GiveItemEffectMappable {
  String toJson() {
    return GiveItemEffectMapper.ensureInitialized().encodeJson<GiveItemEffect>(
      this as GiveItemEffect,
    );
  }

  Map<String, dynamic> toMap() {
    return GiveItemEffectMapper.ensureInitialized().encodeMap<GiveItemEffect>(
      this as GiveItemEffect,
    );
  }

  GiveItemEffectCopyWith<GiveItemEffect, GiveItemEffect, GiveItemEffect>
  get copyWith => _GiveItemEffectCopyWithImpl<GiveItemEffect, GiveItemEffect>(
    this as GiveItemEffect,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return GiveItemEffectMapper.ensureInitialized().stringifyValue(
      this as GiveItemEffect,
    );
  }

  @override
  bool operator ==(Object other) {
    return GiveItemEffectMapper.ensureInitialized().equalsValue(
      this as GiveItemEffect,
      other,
    );
  }

  @override
  int get hashCode {
    return GiveItemEffectMapper.ensureInitialized().hashValue(
      this as GiveItemEffect,
    );
  }
}

extension GiveItemEffectValueCopy<$R, $Out>
    on ObjectCopyWith<$R, GiveItemEffect, $Out> {
  GiveItemEffectCopyWith<$R, GiveItemEffect, $Out> get $asGiveItemEffect =>
      $base.as((v, t, t2) => _GiveItemEffectCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class GiveItemEffectCopyWith<$R, $In extends GiveItemEffect, $Out>
    implements DialogEffectCopyWith<$R, $In, $Out> {
  @override
  $R call({String? itemName, int? count});
  GiveItemEffectCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _GiveItemEffectCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, GiveItemEffect, $Out>
    implements GiveItemEffectCopyWith<$R, GiveItemEffect, $Out> {
  _GiveItemEffectCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<GiveItemEffect> $mapper =
      GiveItemEffectMapper.ensureInitialized();
  @override
  $R call({String? itemName, int? count}) => $apply(
    FieldCopyWithData({
      if (itemName != null) #itemName: itemName,
      if (count != null) #count: count,
    }),
  );
  @override
  GiveItemEffect $make(CopyWithData data) => GiveItemEffect(
    itemName: data.get(#itemName, or: $value.itemName),
    count: data.get(#count, or: $value.count),
  );

  @override
  GiveItemEffectCopyWith<$R2, GiveItemEffect, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _GiveItemEffectCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class RemoveItemEffectMapper extends SubClassMapperBase<RemoveItemEffect> {
  RemoveItemEffectMapper._();

  static RemoveItemEffectMapper? _instance;
  static RemoveItemEffectMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RemoveItemEffectMapper._());
      DialogEffectMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'RemoveItemEffect';

  static String _$itemName(RemoveItemEffect v) => v.itemName;
  static const Field<RemoveItemEffect, String> _f$itemName = Field(
    'itemName',
    _$itemName,
  );
  static int _$count(RemoveItemEffect v) => v.count;
  static const Field<RemoveItemEffect, int> _f$count = Field(
    'count',
    _$count,
    opt: true,
    def: 1,
  );

  @override
  final MappableFields<RemoveItemEffect> fields = const {
    #itemName: _f$itemName,
    #count: _f$count,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'RemoveItemEffect';
  @override
  late final ClassMapperBase superMapper =
      DialogEffectMapper.ensureInitialized();

  static RemoveItemEffect _instantiate(DecodingData data) {
    return RemoveItemEffect(
      itemName: data.dec(_f$itemName),
      count: data.dec(_f$count),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static RemoveItemEffect fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<RemoveItemEffect>(map);
  }

  static RemoveItemEffect fromJson(String json) {
    return ensureInitialized().decodeJson<RemoveItemEffect>(json);
  }
}

mixin RemoveItemEffectMappable {
  String toJson() {
    return RemoveItemEffectMapper.ensureInitialized()
        .encodeJson<RemoveItemEffect>(this as RemoveItemEffect);
  }

  Map<String, dynamic> toMap() {
    return RemoveItemEffectMapper.ensureInitialized()
        .encodeMap<RemoveItemEffect>(this as RemoveItemEffect);
  }

  RemoveItemEffectCopyWith<RemoveItemEffect, RemoveItemEffect, RemoveItemEffect>
  get copyWith =>
      _RemoveItemEffectCopyWithImpl<RemoveItemEffect, RemoveItemEffect>(
        this as RemoveItemEffect,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return RemoveItemEffectMapper.ensureInitialized().stringifyValue(
      this as RemoveItemEffect,
    );
  }

  @override
  bool operator ==(Object other) {
    return RemoveItemEffectMapper.ensureInitialized().equalsValue(
      this as RemoveItemEffect,
      other,
    );
  }

  @override
  int get hashCode {
    return RemoveItemEffectMapper.ensureInitialized().hashValue(
      this as RemoveItemEffect,
    );
  }
}

extension RemoveItemEffectValueCopy<$R, $Out>
    on ObjectCopyWith<$R, RemoveItemEffect, $Out> {
  RemoveItemEffectCopyWith<$R, RemoveItemEffect, $Out>
  get $asRemoveItemEffect =>
      $base.as((v, t, t2) => _RemoveItemEffectCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class RemoveItemEffectCopyWith<$R, $In extends RemoveItemEffect, $Out>
    implements DialogEffectCopyWith<$R, $In, $Out> {
  @override
  $R call({String? itemName, int? count});
  RemoveItemEffectCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _RemoveItemEffectCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, RemoveItemEffect, $Out>
    implements RemoveItemEffectCopyWith<$R, RemoveItemEffect, $Out> {
  _RemoveItemEffectCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<RemoveItemEffect> $mapper =
      RemoveItemEffectMapper.ensureInitialized();
  @override
  $R call({String? itemName, int? count}) => $apply(
    FieldCopyWithData({
      if (itemName != null) #itemName: itemName,
      if (count != null) #count: count,
    }),
  );
  @override
  RemoveItemEffect $make(CopyWithData data) => RemoveItemEffect(
    itemName: data.get(#itemName, or: $value.itemName),
    count: data.get(#count, or: $value.count),
  );

  @override
  RemoveItemEffectCopyWith<$R2, RemoveItemEffect, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _RemoveItemEffectCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class TeleportEffectMapper extends SubClassMapperBase<TeleportEffect> {
  TeleportEffectMapper._();

  static TeleportEffectMapper? _instance;
  static TeleportEffectMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TeleportEffectMapper._());
      DialogEffectMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'TeleportEffect';

  static int _$x(TeleportEffect v) => v.x;
  static const Field<TeleportEffect, int> _f$x = Field('x', _$x);
  static int _$y(TeleportEffect v) => v.y;
  static const Field<TeleportEffect, int> _f$y = Field('y', _$y);
  static int? _$targetParentId(TeleportEffect v) => v.targetParentId;
  static const Field<TeleportEffect, int> _f$targetParentId = Field(
    'targetParentId',
    _$targetParentId,
    opt: true,
  );

  @override
  final MappableFields<TeleportEffect> fields = const {
    #x: _f$x,
    #y: _f$y,
    #targetParentId: _f$targetParentId,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'TeleportEffect';
  @override
  late final ClassMapperBase superMapper =
      DialogEffectMapper.ensureInitialized();

  static TeleportEffect _instantiate(DecodingData data) {
    return TeleportEffect(
      x: data.dec(_f$x),
      y: data.dec(_f$y),
      targetParentId: data.dec(_f$targetParentId),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TeleportEffect fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TeleportEffect>(map);
  }

  static TeleportEffect fromJson(String json) {
    return ensureInitialized().decodeJson<TeleportEffect>(json);
  }
}

mixin TeleportEffectMappable {
  String toJson() {
    return TeleportEffectMapper.ensureInitialized().encodeJson<TeleportEffect>(
      this as TeleportEffect,
    );
  }

  Map<String, dynamic> toMap() {
    return TeleportEffectMapper.ensureInitialized().encodeMap<TeleportEffect>(
      this as TeleportEffect,
    );
  }

  TeleportEffectCopyWith<TeleportEffect, TeleportEffect, TeleportEffect>
  get copyWith => _TeleportEffectCopyWithImpl<TeleportEffect, TeleportEffect>(
    this as TeleportEffect,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return TeleportEffectMapper.ensureInitialized().stringifyValue(
      this as TeleportEffect,
    );
  }

  @override
  bool operator ==(Object other) {
    return TeleportEffectMapper.ensureInitialized().equalsValue(
      this as TeleportEffect,
      other,
    );
  }

  @override
  int get hashCode {
    return TeleportEffectMapper.ensureInitialized().hashValue(
      this as TeleportEffect,
    );
  }
}

extension TeleportEffectValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TeleportEffect, $Out> {
  TeleportEffectCopyWith<$R, TeleportEffect, $Out> get $asTeleportEffect =>
      $base.as((v, t, t2) => _TeleportEffectCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TeleportEffectCopyWith<$R, $In extends TeleportEffect, $Out>
    implements DialogEffectCopyWith<$R, $In, $Out> {
  @override
  $R call({int? x, int? y, int? targetParentId});
  TeleportEffectCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _TeleportEffectCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TeleportEffect, $Out>
    implements TeleportEffectCopyWith<$R, TeleportEffect, $Out> {
  _TeleportEffectCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TeleportEffect> $mapper =
      TeleportEffectMapper.ensureInitialized();
  @override
  $R call({int? x, int? y, Object? targetParentId = $none}) => $apply(
    FieldCopyWithData({
      if (x != null) #x: x,
      if (y != null) #y: y,
      if (targetParentId != $none) #targetParentId: targetParentId,
    }),
  );
  @override
  TeleportEffect $make(CopyWithData data) => TeleportEffect(
    x: data.get(#x, or: $value.x),
    y: data.get(#y, or: $value.y),
    targetParentId: data.get(#targetParentId, or: $value.targetParentId),
  );

  @override
  TeleportEffectCopyWith<$R2, TeleportEffect, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TeleportEffectCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class MoveEntityEffectMapper extends SubClassMapperBase<MoveEntityEffect> {
  MoveEntityEffectMapper._();

  static MoveEntityEffectMapper? _instance;
  static MoveEntityEffectMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MoveEntityEffectMapper._());
      DialogEffectMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'MoveEntityEffect';

  static int _$x(MoveEntityEffect v) => v.x;
  static const Field<MoveEntityEffect, int> _f$x = Field('x', _$x);
  static int _$y(MoveEntityEffect v) => v.y;
  static const Field<MoveEntityEffect, int> _f$y = Field('y', _$y);
  static bool _$targetPlayer(MoveEntityEffect v) => v.targetPlayer;
  static const Field<MoveEntityEffect, bool> _f$targetPlayer = Field(
    'targetPlayer',
    _$targetPlayer,
    opt: true,
    def: true,
  );

  @override
  final MappableFields<MoveEntityEffect> fields = const {
    #x: _f$x,
    #y: _f$y,
    #targetPlayer: _f$targetPlayer,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'MoveEntityEffect';
  @override
  late final ClassMapperBase superMapper =
      DialogEffectMapper.ensureInitialized();

  static MoveEntityEffect _instantiate(DecodingData data) {
    return MoveEntityEffect(
      x: data.dec(_f$x),
      y: data.dec(_f$y),
      targetPlayer: data.dec(_f$targetPlayer),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MoveEntityEffect fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MoveEntityEffect>(map);
  }

  static MoveEntityEffect fromJson(String json) {
    return ensureInitialized().decodeJson<MoveEntityEffect>(json);
  }
}

mixin MoveEntityEffectMappable {
  String toJson() {
    return MoveEntityEffectMapper.ensureInitialized()
        .encodeJson<MoveEntityEffect>(this as MoveEntityEffect);
  }

  Map<String, dynamic> toMap() {
    return MoveEntityEffectMapper.ensureInitialized()
        .encodeMap<MoveEntityEffect>(this as MoveEntityEffect);
  }

  MoveEntityEffectCopyWith<MoveEntityEffect, MoveEntityEffect, MoveEntityEffect>
  get copyWith =>
      _MoveEntityEffectCopyWithImpl<MoveEntityEffect, MoveEntityEffect>(
        this as MoveEntityEffect,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MoveEntityEffectMapper.ensureInitialized().stringifyValue(
      this as MoveEntityEffect,
    );
  }

  @override
  bool operator ==(Object other) {
    return MoveEntityEffectMapper.ensureInitialized().equalsValue(
      this as MoveEntityEffect,
      other,
    );
  }

  @override
  int get hashCode {
    return MoveEntityEffectMapper.ensureInitialized().hashValue(
      this as MoveEntityEffect,
    );
  }
}

extension MoveEntityEffectValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MoveEntityEffect, $Out> {
  MoveEntityEffectCopyWith<$R, MoveEntityEffect, $Out>
  get $asMoveEntityEffect =>
      $base.as((v, t, t2) => _MoveEntityEffectCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MoveEntityEffectCopyWith<$R, $In extends MoveEntityEffect, $Out>
    implements DialogEffectCopyWith<$R, $In, $Out> {
  @override
  $R call({int? x, int? y, bool? targetPlayer});
  MoveEntityEffectCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _MoveEntityEffectCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MoveEntityEffect, $Out>
    implements MoveEntityEffectCopyWith<$R, MoveEntityEffect, $Out> {
  _MoveEntityEffectCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MoveEntityEffect> $mapper =
      MoveEntityEffectMapper.ensureInitialized();
  @override
  $R call({int? x, int? y, bool? targetPlayer}) => $apply(
    FieldCopyWithData({
      if (x != null) #x: x,
      if (y != null) #y: y,
      if (targetPlayer != null) #targetPlayer: targetPlayer,
    }),
  );
  @override
  MoveEntityEffect $make(CopyWithData data) => MoveEntityEffect(
    x: data.get(#x, or: $value.x),
    y: data.get(#y, or: $value.y),
    targetPlayer: data.get(#targetPlayer, or: $value.targetPlayer),
  );

  @override
  MoveEntityEffectCopyWith<$R2, MoveEntityEffect, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MoveEntityEffectCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class OpenDoorEffectMapper extends SubClassMapperBase<OpenDoorEffect> {
  OpenDoorEffectMapper._();

  static OpenDoorEffectMapper? _instance;
  static OpenDoorEffectMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OpenDoorEffectMapper._());
      DialogEffectMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'OpenDoorEffect';

  static int _$doorEntityId(OpenDoorEffect v) => v.doorEntityId;
  static const Field<OpenDoorEffect, int> _f$doorEntityId = Field(
    'doorEntityId',
    _$doorEntityId,
  );

  @override
  final MappableFields<OpenDoorEffect> fields = const {
    #doorEntityId: _f$doorEntityId,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'OpenDoorEffect';
  @override
  late final ClassMapperBase superMapper =
      DialogEffectMapper.ensureInitialized();

  static OpenDoorEffect _instantiate(DecodingData data) {
    return OpenDoorEffect(doorEntityId: data.dec(_f$doorEntityId));
  }

  @override
  final Function instantiate = _instantiate;

  static OpenDoorEffect fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OpenDoorEffect>(map);
  }

  static OpenDoorEffect fromJson(String json) {
    return ensureInitialized().decodeJson<OpenDoorEffect>(json);
  }
}

mixin OpenDoorEffectMappable {
  String toJson() {
    return OpenDoorEffectMapper.ensureInitialized().encodeJson<OpenDoorEffect>(
      this as OpenDoorEffect,
    );
  }

  Map<String, dynamic> toMap() {
    return OpenDoorEffectMapper.ensureInitialized().encodeMap<OpenDoorEffect>(
      this as OpenDoorEffect,
    );
  }

  OpenDoorEffectCopyWith<OpenDoorEffect, OpenDoorEffect, OpenDoorEffect>
  get copyWith => _OpenDoorEffectCopyWithImpl<OpenDoorEffect, OpenDoorEffect>(
    this as OpenDoorEffect,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return OpenDoorEffectMapper.ensureInitialized().stringifyValue(
      this as OpenDoorEffect,
    );
  }

  @override
  bool operator ==(Object other) {
    return OpenDoorEffectMapper.ensureInitialized().equalsValue(
      this as OpenDoorEffect,
      other,
    );
  }

  @override
  int get hashCode {
    return OpenDoorEffectMapper.ensureInitialized().hashValue(
      this as OpenDoorEffect,
    );
  }
}

extension OpenDoorEffectValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OpenDoorEffect, $Out> {
  OpenDoorEffectCopyWith<$R, OpenDoorEffect, $Out> get $asOpenDoorEffect =>
      $base.as((v, t, t2) => _OpenDoorEffectCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class OpenDoorEffectCopyWith<$R, $In extends OpenDoorEffect, $Out>
    implements DialogEffectCopyWith<$R, $In, $Out> {
  @override
  $R call({int? doorEntityId});
  OpenDoorEffectCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _OpenDoorEffectCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OpenDoorEffect, $Out>
    implements OpenDoorEffectCopyWith<$R, OpenDoorEffect, $Out> {
  _OpenDoorEffectCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OpenDoorEffect> $mapper =
      OpenDoorEffectMapper.ensureInitialized();
  @override
  $R call({int? doorEntityId}) => $apply(
    FieldCopyWithData({if (doorEntityId != null) #doorEntityId: doorEntityId}),
  );
  @override
  OpenDoorEffect $make(CopyWithData data) => OpenDoorEffect(
    doorEntityId: data.get(#doorEntityId, or: $value.doorEntityId),
  );

  @override
  OpenDoorEffectCopyWith<$R2, OpenDoorEffect, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _OpenDoorEffectCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CloseDoorEffectMapper extends SubClassMapperBase<CloseDoorEffect> {
  CloseDoorEffectMapper._();

  static CloseDoorEffectMapper? _instance;
  static CloseDoorEffectMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CloseDoorEffectMapper._());
      DialogEffectMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'CloseDoorEffect';

  static int _$doorEntityId(CloseDoorEffect v) => v.doorEntityId;
  static const Field<CloseDoorEffect, int> _f$doorEntityId = Field(
    'doorEntityId',
    _$doorEntityId,
  );

  @override
  final MappableFields<CloseDoorEffect> fields = const {
    #doorEntityId: _f$doorEntityId,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'CloseDoorEffect';
  @override
  late final ClassMapperBase superMapper =
      DialogEffectMapper.ensureInitialized();

  static CloseDoorEffect _instantiate(DecodingData data) {
    return CloseDoorEffect(doorEntityId: data.dec(_f$doorEntityId));
  }

  @override
  final Function instantiate = _instantiate;

  static CloseDoorEffect fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CloseDoorEffect>(map);
  }

  static CloseDoorEffect fromJson(String json) {
    return ensureInitialized().decodeJson<CloseDoorEffect>(json);
  }
}

mixin CloseDoorEffectMappable {
  String toJson() {
    return CloseDoorEffectMapper.ensureInitialized()
        .encodeJson<CloseDoorEffect>(this as CloseDoorEffect);
  }

  Map<String, dynamic> toMap() {
    return CloseDoorEffectMapper.ensureInitialized().encodeMap<CloseDoorEffect>(
      this as CloseDoorEffect,
    );
  }

  CloseDoorEffectCopyWith<CloseDoorEffect, CloseDoorEffect, CloseDoorEffect>
  get copyWith =>
      _CloseDoorEffectCopyWithImpl<CloseDoorEffect, CloseDoorEffect>(
        this as CloseDoorEffect,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CloseDoorEffectMapper.ensureInitialized().stringifyValue(
      this as CloseDoorEffect,
    );
  }

  @override
  bool operator ==(Object other) {
    return CloseDoorEffectMapper.ensureInitialized().equalsValue(
      this as CloseDoorEffect,
      other,
    );
  }

  @override
  int get hashCode {
    return CloseDoorEffectMapper.ensureInitialized().hashValue(
      this as CloseDoorEffect,
    );
  }
}

extension CloseDoorEffectValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CloseDoorEffect, $Out> {
  CloseDoorEffectCopyWith<$R, CloseDoorEffect, $Out> get $asCloseDoorEffect =>
      $base.as((v, t, t2) => _CloseDoorEffectCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CloseDoorEffectCopyWith<$R, $In extends CloseDoorEffect, $Out>
    implements DialogEffectCopyWith<$R, $In, $Out> {
  @override
  $R call({int? doorEntityId});
  CloseDoorEffectCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CloseDoorEffectCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CloseDoorEffect, $Out>
    implements CloseDoorEffectCopyWith<$R, CloseDoorEffect, $Out> {
  _CloseDoorEffectCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CloseDoorEffect> $mapper =
      CloseDoorEffectMapper.ensureInitialized();
  @override
  $R call({int? doorEntityId}) => $apply(
    FieldCopyWithData({if (doorEntityId != null) #doorEntityId: doorEntityId}),
  );
  @override
  CloseDoorEffect $make(CopyWithData data) => CloseDoorEffect(
    doorEntityId: data.get(#doorEntityId, or: $value.doorEntityId),
  );

  @override
  CloseDoorEffectCopyWith<$R2, CloseDoorEffect, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CloseDoorEffectCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class SetParentEffectMapper extends SubClassMapperBase<SetParentEffect> {
  SetParentEffectMapper._();

  static SetParentEffectMapper? _instance;
  static SetParentEffectMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SetParentEffectMapper._());
      DialogEffectMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'SetParentEffect';

  static bool _$targetPlayer(SetParentEffect v) => v.targetPlayer;
  static const Field<SetParentEffect, bool> _f$targetPlayer = Field(
    'targetPlayer',
    _$targetPlayer,
    opt: true,
    def: true,
  );
  static ParentTarget _$parentTarget(SetParentEffect v) => v.parentTarget;
  static const Field<SetParentEffect, ParentTarget> _f$parentTarget = Field(
    'parentTarget',
    _$parentTarget,
    opt: true,
    def: ParentTarget.player,
  );
  static int? _$customParentId(SetParentEffect v) => v.customParentId;
  static const Field<SetParentEffect, int> _f$customParentId = Field(
    'customParentId',
    _$customParentId,
    opt: true,
  );

  @override
  final MappableFields<SetParentEffect> fields = const {
    #targetPlayer: _f$targetPlayer,
    #parentTarget: _f$parentTarget,
    #customParentId: _f$customParentId,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'SetParentEffect';
  @override
  late final ClassMapperBase superMapper =
      DialogEffectMapper.ensureInitialized();

  static SetParentEffect _instantiate(DecodingData data) {
    return SetParentEffect(
      targetPlayer: data.dec(_f$targetPlayer),
      parentTarget: data.dec(_f$parentTarget),
      customParentId: data.dec(_f$customParentId),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static SetParentEffect fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SetParentEffect>(map);
  }

  static SetParentEffect fromJson(String json) {
    return ensureInitialized().decodeJson<SetParentEffect>(json);
  }
}

mixin SetParentEffectMappable {
  String toJson() {
    return SetParentEffectMapper.ensureInitialized()
        .encodeJson<SetParentEffect>(this as SetParentEffect);
  }

  Map<String, dynamic> toMap() {
    return SetParentEffectMapper.ensureInitialized().encodeMap<SetParentEffect>(
      this as SetParentEffect,
    );
  }

  SetParentEffectCopyWith<SetParentEffect, SetParentEffect, SetParentEffect>
  get copyWith =>
      _SetParentEffectCopyWithImpl<SetParentEffect, SetParentEffect>(
        this as SetParentEffect,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return SetParentEffectMapper.ensureInitialized().stringifyValue(
      this as SetParentEffect,
    );
  }

  @override
  bool operator ==(Object other) {
    return SetParentEffectMapper.ensureInitialized().equalsValue(
      this as SetParentEffect,
      other,
    );
  }

  @override
  int get hashCode {
    return SetParentEffectMapper.ensureInitialized().hashValue(
      this as SetParentEffect,
    );
  }
}

extension SetParentEffectValueCopy<$R, $Out>
    on ObjectCopyWith<$R, SetParentEffect, $Out> {
  SetParentEffectCopyWith<$R, SetParentEffect, $Out> get $asSetParentEffect =>
      $base.as((v, t, t2) => _SetParentEffectCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class SetParentEffectCopyWith<$R, $In extends SetParentEffect, $Out>
    implements DialogEffectCopyWith<$R, $In, $Out> {
  @override
  $R call({
    bool? targetPlayer,
    ParentTarget? parentTarget,
    int? customParentId,
  });
  SetParentEffectCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _SetParentEffectCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SetParentEffect, $Out>
    implements SetParentEffectCopyWith<$R, SetParentEffect, $Out> {
  _SetParentEffectCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SetParentEffect> $mapper =
      SetParentEffectMapper.ensureInitialized();
  @override
  $R call({
    bool? targetPlayer,
    ParentTarget? parentTarget,
    Object? customParentId = $none,
  }) => $apply(
    FieldCopyWithData({
      if (targetPlayer != null) #targetPlayer: targetPlayer,
      if (parentTarget != null) #parentTarget: parentTarget,
      if (customParentId != $none) #customParentId: customParentId,
    }),
  );
  @override
  SetParentEffect $make(CopyWithData data) => SetParentEffect(
    targetPlayer: data.get(#targetPlayer, or: $value.targetPlayer),
    parentTarget: data.get(#parentTarget, or: $value.parentTarget),
    customParentId: data.get(#customParentId, or: $value.customParentId),
  );

  @override
  SetParentEffectCopyWith<$R2, SetParentEffect, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _SetParentEffectCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class RemoveParentEffectMapper extends SubClassMapperBase<RemoveParentEffect> {
  RemoveParentEffectMapper._();

  static RemoveParentEffectMapper? _instance;
  static RemoveParentEffectMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RemoveParentEffectMapper._());
      DialogEffectMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'RemoveParentEffect';

  static bool _$targetPlayer(RemoveParentEffect v) => v.targetPlayer;
  static const Field<RemoveParentEffect, bool> _f$targetPlayer = Field(
    'targetPlayer',
    _$targetPlayer,
    opt: true,
    def: true,
  );

  @override
  final MappableFields<RemoveParentEffect> fields = const {
    #targetPlayer: _f$targetPlayer,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'RemoveParentEffect';
  @override
  late final ClassMapperBase superMapper =
      DialogEffectMapper.ensureInitialized();

  static RemoveParentEffect _instantiate(DecodingData data) {
    return RemoveParentEffect(targetPlayer: data.dec(_f$targetPlayer));
  }

  @override
  final Function instantiate = _instantiate;

  static RemoveParentEffect fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<RemoveParentEffect>(map);
  }

  static RemoveParentEffect fromJson(String json) {
    return ensureInitialized().decodeJson<RemoveParentEffect>(json);
  }
}

mixin RemoveParentEffectMappable {
  String toJson() {
    return RemoveParentEffectMapper.ensureInitialized()
        .encodeJson<RemoveParentEffect>(this as RemoveParentEffect);
  }

  Map<String, dynamic> toMap() {
    return RemoveParentEffectMapper.ensureInitialized()
        .encodeMap<RemoveParentEffect>(this as RemoveParentEffect);
  }

  RemoveParentEffectCopyWith<
    RemoveParentEffect,
    RemoveParentEffect,
    RemoveParentEffect
  >
  get copyWith =>
      _RemoveParentEffectCopyWithImpl<RemoveParentEffect, RemoveParentEffect>(
        this as RemoveParentEffect,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return RemoveParentEffectMapper.ensureInitialized().stringifyValue(
      this as RemoveParentEffect,
    );
  }

  @override
  bool operator ==(Object other) {
    return RemoveParentEffectMapper.ensureInitialized().equalsValue(
      this as RemoveParentEffect,
      other,
    );
  }

  @override
  int get hashCode {
    return RemoveParentEffectMapper.ensureInitialized().hashValue(
      this as RemoveParentEffect,
    );
  }
}

extension RemoveParentEffectValueCopy<$R, $Out>
    on ObjectCopyWith<$R, RemoveParentEffect, $Out> {
  RemoveParentEffectCopyWith<$R, RemoveParentEffect, $Out>
  get $asRemoveParentEffect => $base.as(
    (v, t, t2) => _RemoveParentEffectCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class RemoveParentEffectCopyWith<
  $R,
  $In extends RemoveParentEffect,
  $Out
>
    implements DialogEffectCopyWith<$R, $In, $Out> {
  @override
  $R call({bool? targetPlayer});
  RemoveParentEffectCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _RemoveParentEffectCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, RemoveParentEffect, $Out>
    implements RemoveParentEffectCopyWith<$R, RemoveParentEffect, $Out> {
  _RemoveParentEffectCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<RemoveParentEffect> $mapper =
      RemoveParentEffectMapper.ensureInitialized();
  @override
  $R call({bool? targetPlayer}) => $apply(
    FieldCopyWithData({if (targetPlayer != null) #targetPlayer: targetPlayer}),
  );
  @override
  RemoveParentEffect $make(CopyWithData data) => RemoveParentEffect(
    targetPlayer: data.get(#targetPlayer, or: $value.targetPlayer),
  );

  @override
  RemoveParentEffectCopyWith<$R2, RemoveParentEffect, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _RemoveParentEffectCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class AddComponentEffectMapper extends SubClassMapperBase<AddComponentEffect> {
  AddComponentEffectMapper._();

  static AddComponentEffectMapper? _instance;
  static AddComponentEffectMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AddComponentEffectMapper._());
      DialogEffectMapper.ensureInitialized().addSubMapper(_instance!);
      ComponentMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AddComponentEffect';

  static Component _$component(AddComponentEffect v) => v.component;
  static const Field<AddComponentEffect, Component> _f$component = Field(
    'component',
    _$component,
  );
  static bool _$targetPlayer(AddComponentEffect v) => v.targetPlayer;
  static const Field<AddComponentEffect, bool> _f$targetPlayer = Field(
    'targetPlayer',
    _$targetPlayer,
    opt: true,
    def: true,
  );

  @override
  final MappableFields<AddComponentEffect> fields = const {
    #component: _f$component,
    #targetPlayer: _f$targetPlayer,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'AddComponentEffect';
  @override
  late final ClassMapperBase superMapper =
      DialogEffectMapper.ensureInitialized();

  static AddComponentEffect _instantiate(DecodingData data) {
    return AddComponentEffect(
      component: data.dec(_f$component),
      targetPlayer: data.dec(_f$targetPlayer),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static AddComponentEffect fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AddComponentEffect>(map);
  }

  static AddComponentEffect fromJson(String json) {
    return ensureInitialized().decodeJson<AddComponentEffect>(json);
  }
}

mixin AddComponentEffectMappable {
  String toJson() {
    return AddComponentEffectMapper.ensureInitialized()
        .encodeJson<AddComponentEffect>(this as AddComponentEffect);
  }

  Map<String, dynamic> toMap() {
    return AddComponentEffectMapper.ensureInitialized()
        .encodeMap<AddComponentEffect>(this as AddComponentEffect);
  }

  AddComponentEffectCopyWith<
    AddComponentEffect,
    AddComponentEffect,
    AddComponentEffect
  >
  get copyWith =>
      _AddComponentEffectCopyWithImpl<AddComponentEffect, AddComponentEffect>(
        this as AddComponentEffect,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AddComponentEffectMapper.ensureInitialized().stringifyValue(
      this as AddComponentEffect,
    );
  }

  @override
  bool operator ==(Object other) {
    return AddComponentEffectMapper.ensureInitialized().equalsValue(
      this as AddComponentEffect,
      other,
    );
  }

  @override
  int get hashCode {
    return AddComponentEffectMapper.ensureInitialized().hashValue(
      this as AddComponentEffect,
    );
  }
}

extension AddComponentEffectValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AddComponentEffect, $Out> {
  AddComponentEffectCopyWith<$R, AddComponentEffect, $Out>
  get $asAddComponentEffect => $base.as(
    (v, t, t2) => _AddComponentEffectCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class AddComponentEffectCopyWith<
  $R,
  $In extends AddComponentEffect,
  $Out
>
    implements DialogEffectCopyWith<$R, $In, $Out> {
  @override
  $R call({Component? component, bool? targetPlayer});
  AddComponentEffectCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _AddComponentEffectCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AddComponentEffect, $Out>
    implements AddComponentEffectCopyWith<$R, AddComponentEffect, $Out> {
  _AddComponentEffectCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AddComponentEffect> $mapper =
      AddComponentEffectMapper.ensureInitialized();
  @override
  $R call({Component? component, bool? targetPlayer}) => $apply(
    FieldCopyWithData({
      if (component != null) #component: component,
      if (targetPlayer != null) #targetPlayer: targetPlayer,
    }),
  );
  @override
  AddComponentEffect $make(CopyWithData data) => AddComponentEffect(
    component: data.get(#component, or: $value.component),
    targetPlayer: data.get(#targetPlayer, or: $value.targetPlayer),
  );

  @override
  AddComponentEffectCopyWith<$R2, AddComponentEffect, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _AddComponentEffectCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class RemoveComponentEffectMapper
    extends SubClassMapperBase<RemoveComponentEffect> {
  RemoveComponentEffectMapper._();

  static RemoveComponentEffectMapper? _instance;
  static RemoveComponentEffectMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RemoveComponentEffectMapper._());
      DialogEffectMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'RemoveComponentEffect';

  static String _$componentType(RemoveComponentEffect v) => v.componentType;
  static const Field<RemoveComponentEffect, String> _f$componentType = Field(
    'componentType',
    _$componentType,
  );
  static bool _$targetPlayer(RemoveComponentEffect v) => v.targetPlayer;
  static const Field<RemoveComponentEffect, bool> _f$targetPlayer = Field(
    'targetPlayer',
    _$targetPlayer,
    opt: true,
    def: true,
  );

  @override
  final MappableFields<RemoveComponentEffect> fields = const {
    #componentType: _f$componentType,
    #targetPlayer: _f$targetPlayer,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'RemoveComponentEffect';
  @override
  late final ClassMapperBase superMapper =
      DialogEffectMapper.ensureInitialized();

  static RemoveComponentEffect _instantiate(DecodingData data) {
    return RemoveComponentEffect(
      componentType: data.dec(_f$componentType),
      targetPlayer: data.dec(_f$targetPlayer),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static RemoveComponentEffect fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<RemoveComponentEffect>(map);
  }

  static RemoveComponentEffect fromJson(String json) {
    return ensureInitialized().decodeJson<RemoveComponentEffect>(json);
  }
}

mixin RemoveComponentEffectMappable {
  String toJson() {
    return RemoveComponentEffectMapper.ensureInitialized()
        .encodeJson<RemoveComponentEffect>(this as RemoveComponentEffect);
  }

  Map<String, dynamic> toMap() {
    return RemoveComponentEffectMapper.ensureInitialized()
        .encodeMap<RemoveComponentEffect>(this as RemoveComponentEffect);
  }

  RemoveComponentEffectCopyWith<
    RemoveComponentEffect,
    RemoveComponentEffect,
    RemoveComponentEffect
  >
  get copyWith =>
      _RemoveComponentEffectCopyWithImpl<
        RemoveComponentEffect,
        RemoveComponentEffect
      >(this as RemoveComponentEffect, $identity, $identity);
  @override
  String toString() {
    return RemoveComponentEffectMapper.ensureInitialized().stringifyValue(
      this as RemoveComponentEffect,
    );
  }

  @override
  bool operator ==(Object other) {
    return RemoveComponentEffectMapper.ensureInitialized().equalsValue(
      this as RemoveComponentEffect,
      other,
    );
  }

  @override
  int get hashCode {
    return RemoveComponentEffectMapper.ensureInitialized().hashValue(
      this as RemoveComponentEffect,
    );
  }
}

extension RemoveComponentEffectValueCopy<$R, $Out>
    on ObjectCopyWith<$R, RemoveComponentEffect, $Out> {
  RemoveComponentEffectCopyWith<$R, RemoveComponentEffect, $Out>
  get $asRemoveComponentEffect => $base.as(
    (v, t, t2) => _RemoveComponentEffectCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class RemoveComponentEffectCopyWith<
  $R,
  $In extends RemoveComponentEffect,
  $Out
>
    implements DialogEffectCopyWith<$R, $In, $Out> {
  @override
  $R call({String? componentType, bool? targetPlayer});
  RemoveComponentEffectCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _RemoveComponentEffectCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, RemoveComponentEffect, $Out>
    implements RemoveComponentEffectCopyWith<$R, RemoveComponentEffect, $Out> {
  _RemoveComponentEffectCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<RemoveComponentEffect> $mapper =
      RemoveComponentEffectMapper.ensureInitialized();
  @override
  $R call({String? componentType, bool? targetPlayer}) => $apply(
    FieldCopyWithData({
      if (componentType != null) #componentType: componentType,
      if (targetPlayer != null) #targetPlayer: targetPlayer,
    }),
  );
  @override
  RemoveComponentEffect $make(CopyWithData data) => RemoveComponentEffect(
    componentType: data.get(#componentType, or: $value.componentType),
    targetPlayer: data.get(#targetPlayer, or: $value.targetPlayer),
  );

  @override
  RemoveComponentEffectCopyWith<$R2, RemoveComponentEffect, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _RemoveComponentEffectCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class SequenceEffectMapper extends SubClassMapperBase<SequenceEffect> {
  SequenceEffectMapper._();

  static SequenceEffectMapper? _instance;
  static SequenceEffectMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SequenceEffectMapper._());
      DialogEffectMapper.ensureInitialized().addSubMapper(_instance!);
      DialogEffectMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'SequenceEffect';

  static List<DialogEffect> _$effects(SequenceEffect v) => v.effects;
  static const Field<SequenceEffect, List<DialogEffect>> _f$effects = Field(
    'effects',
    _$effects,
  );

  @override
  final MappableFields<SequenceEffect> fields = const {#effects: _f$effects};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'SequenceEffect';
  @override
  late final ClassMapperBase superMapper =
      DialogEffectMapper.ensureInitialized();

  static SequenceEffect _instantiate(DecodingData data) {
    return SequenceEffect(data.dec(_f$effects));
  }

  @override
  final Function instantiate = _instantiate;

  static SequenceEffect fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SequenceEffect>(map);
  }

  static SequenceEffect fromJson(String json) {
    return ensureInitialized().decodeJson<SequenceEffect>(json);
  }
}

mixin SequenceEffectMappable {
  String toJson() {
    return SequenceEffectMapper.ensureInitialized().encodeJson<SequenceEffect>(
      this as SequenceEffect,
    );
  }

  Map<String, dynamic> toMap() {
    return SequenceEffectMapper.ensureInitialized().encodeMap<SequenceEffect>(
      this as SequenceEffect,
    );
  }

  SequenceEffectCopyWith<SequenceEffect, SequenceEffect, SequenceEffect>
  get copyWith => _SequenceEffectCopyWithImpl<SequenceEffect, SequenceEffect>(
    this as SequenceEffect,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return SequenceEffectMapper.ensureInitialized().stringifyValue(
      this as SequenceEffect,
    );
  }

  @override
  bool operator ==(Object other) {
    return SequenceEffectMapper.ensureInitialized().equalsValue(
      this as SequenceEffect,
      other,
    );
  }

  @override
  int get hashCode {
    return SequenceEffectMapper.ensureInitialized().hashValue(
      this as SequenceEffect,
    );
  }
}

extension SequenceEffectValueCopy<$R, $Out>
    on ObjectCopyWith<$R, SequenceEffect, $Out> {
  SequenceEffectCopyWith<$R, SequenceEffect, $Out> get $asSequenceEffect =>
      $base.as((v, t, t2) => _SequenceEffectCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class SequenceEffectCopyWith<$R, $In extends SequenceEffect, $Out>
    implements DialogEffectCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    DialogEffect,
    DialogEffectCopyWith<$R, DialogEffect, DialogEffect>
  >
  get effects;
  @override
  $R call({List<DialogEffect>? effects});
  SequenceEffectCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _SequenceEffectCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SequenceEffect, $Out>
    implements SequenceEffectCopyWith<$R, SequenceEffect, $Out> {
  _SequenceEffectCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SequenceEffect> $mapper =
      SequenceEffectMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    DialogEffect,
    DialogEffectCopyWith<$R, DialogEffect, DialogEffect>
  >
  get effects => ListCopyWith(
    $value.effects,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(effects: v),
  );
  @override
  $R call({List<DialogEffect>? effects}) =>
      $apply(FieldCopyWithData({if (effects != null) #effects: effects}));
  @override
  SequenceEffect $make(CopyWithData data) =>
      SequenceEffect(data.get(#effects, or: $value.effects));

  @override
  SequenceEffectCopyWith<$R2, SequenceEffect, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _SequenceEffectCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CustomEffectMapper extends SubClassMapperBase<CustomEffect> {
  CustomEffectMapper._();

  static CustomEffectMapper? _instance;
  static CustomEffectMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CustomEffectMapper._());
      DialogEffectMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'CustomEffect';

  static Function? _$executor(CustomEffect v) =>
      (v as dynamic).executor as Function?;
  static dynamic _arg$executor(f) => f<void Function(Entity, Entity)>();
  static const Field<CustomEffect, Function?> _f$executor = Field(
    'executor',
    _$executor,
    opt: true,
    arg: _arg$executor,
    hook: IgnoreHook(),
  );

  @override
  final MappableFields<CustomEffect> fields = const {#executor: _f$executor};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'CustomEffect';
  @override
  late final ClassMapperBase superMapper =
      DialogEffectMapper.ensureInitialized();

  static CustomEffect _instantiate(DecodingData data) {
    return CustomEffect(executor: data.dec(_f$executor));
  }

  @override
  final Function instantiate = _instantiate;

  static CustomEffect fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CustomEffect>(map);
  }

  static CustomEffect fromJson(String json) {
    return ensureInitialized().decodeJson<CustomEffect>(json);
  }
}

mixin CustomEffectMappable {
  String toJson() {
    return CustomEffectMapper.ensureInitialized().encodeJson<CustomEffect>(
      this as CustomEffect,
    );
  }

  Map<String, dynamic> toMap() {
    return CustomEffectMapper.ensureInitialized().encodeMap<CustomEffect>(
      this as CustomEffect,
    );
  }

  CustomEffectCopyWith<CustomEffect, CustomEffect, CustomEffect> get copyWith =>
      _CustomEffectCopyWithImpl<CustomEffect, CustomEffect>(
        this as CustomEffect,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CustomEffectMapper.ensureInitialized().stringifyValue(
      this as CustomEffect,
    );
  }

  @override
  bool operator ==(Object other) {
    return CustomEffectMapper.ensureInitialized().equalsValue(
      this as CustomEffect,
      other,
    );
  }

  @override
  int get hashCode {
    return CustomEffectMapper.ensureInitialized().hashValue(
      this as CustomEffect,
    );
  }
}

extension CustomEffectValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CustomEffect, $Out> {
  CustomEffectCopyWith<$R, CustomEffect, $Out> get $asCustomEffect =>
      $base.as((v, t, t2) => _CustomEffectCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CustomEffectCopyWith<$R, $In extends CustomEffect, $Out>
    implements DialogEffectCopyWith<$R, $In, $Out> {
  @override
  $R call({void Function(Entity, Entity)? executor});
  CustomEffectCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CustomEffectCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CustomEffect, $Out>
    implements CustomEffectCopyWith<$R, CustomEffect, $Out> {
  _CustomEffectCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CustomEffect> $mapper =
      CustomEffectMapper.ensureInitialized();
  @override
  $R call({Object? executor = $none}) =>
      $apply(FieldCopyWithData({if (executor != $none) #executor: executor}));
  @override
  CustomEffect $make(CopyWithData data) =>
      CustomEffect(executor: data.get(#executor, or: $value.executor));

  @override
  CustomEffectCopyWith<$R2, CustomEffect, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CustomEffectCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

