// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'keybinding_service.dart';

class KeyComboMapper extends ClassMapperBase<KeyCombo> {
  KeyComboMapper._();

  static KeyComboMapper? _instance;
  static KeyComboMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = KeyComboMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'KeyCombo';

  static List<int> _$keyIds(KeyCombo v) => v.keyIds;
  static const Field<KeyCombo, List<int>> _f$keyIds = Field('keyIds', _$keyIds);

  @override
  final MappableFields<KeyCombo> fields = const {#keyIds: _f$keyIds};

  static KeyCombo _instantiate(DecodingData data) {
    return KeyCombo(data.dec(_f$keyIds));
  }

  @override
  final Function instantiate = _instantiate;

  static KeyCombo fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<KeyCombo>(map);
  }

  static KeyCombo fromJson(String json) {
    return ensureInitialized().decodeJson<KeyCombo>(json);
  }
}

mixin KeyComboMappable {
  String toJson() {
    return KeyComboMapper.ensureInitialized().encodeJson<KeyCombo>(
      this as KeyCombo,
    );
  }

  Map<String, dynamic> toMap() {
    return KeyComboMapper.ensureInitialized().encodeMap<KeyCombo>(
      this as KeyCombo,
    );
  }

  KeyComboCopyWith<KeyCombo, KeyCombo, KeyCombo> get copyWith =>
      _KeyComboCopyWithImpl<KeyCombo, KeyCombo>(
        this as KeyCombo,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return KeyComboMapper.ensureInitialized().stringifyValue(this as KeyCombo);
  }

  @override
  bool operator ==(Object other) {
    return KeyComboMapper.ensureInitialized().equalsValue(
      this as KeyCombo,
      other,
    );
  }

  @override
  int get hashCode {
    return KeyComboMapper.ensureInitialized().hashValue(this as KeyCombo);
  }
}

extension KeyComboValueCopy<$R, $Out> on ObjectCopyWith<$R, KeyCombo, $Out> {
  KeyComboCopyWith<$R, KeyCombo, $Out> get $asKeyCombo =>
      $base.as((v, t, t2) => _KeyComboCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class KeyComboCopyWith<$R, $In extends KeyCombo, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, int, ObjectCopyWith<$R, int, int>> get keyIds;
  $R call({List<int>? keyIds});
  KeyComboCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _KeyComboCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, KeyCombo, $Out>
    implements KeyComboCopyWith<$R, KeyCombo, $Out> {
  _KeyComboCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<KeyCombo> $mapper =
      KeyComboMapper.ensureInitialized();
  @override
  ListCopyWith<$R, int, ObjectCopyWith<$R, int, int>> get keyIds =>
      ListCopyWith(
        $value.keyIds,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(keyIds: v),
      );
  @override
  $R call({List<int>? keyIds}) =>
      $apply(FieldCopyWithData({if (keyIds != null) #keyIds: keyIds}));
  @override
  KeyCombo $make(CopyWithData data) =>
      KeyCombo(data.get(#keyIds, or: $value.keyIds));

  @override
  KeyComboCopyWith<$R2, KeyCombo, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _KeyComboCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class KeyBindingMapper extends ClassMapperBase<KeyBinding> {
  KeyBindingMapper._();

  static KeyBindingMapper? _instance;
  static KeyBindingMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = KeyBindingMapper._());
      KeyComboMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'KeyBinding';

  static String _$action(KeyBinding v) => v.action;
  static const Field<KeyBinding, String> _f$action = Field('action', _$action);
  static KeyCombo _$combo(KeyBinding v) => v.combo;
  static const Field<KeyBinding, KeyCombo> _f$combo = Field('combo', _$combo);

  @override
  final MappableFields<KeyBinding> fields = const {
    #action: _f$action,
    #combo: _f$combo,
  };

  static KeyBinding _instantiate(DecodingData data) {
    return KeyBinding(action: data.dec(_f$action), combo: data.dec(_f$combo));
  }

  @override
  final Function instantiate = _instantiate;

  static KeyBinding fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<KeyBinding>(map);
  }

  static KeyBinding fromJson(String json) {
    return ensureInitialized().decodeJson<KeyBinding>(json);
  }
}

mixin KeyBindingMappable {
  String toJson() {
    return KeyBindingMapper.ensureInitialized().encodeJson<KeyBinding>(
      this as KeyBinding,
    );
  }

  Map<String, dynamic> toMap() {
    return KeyBindingMapper.ensureInitialized().encodeMap<KeyBinding>(
      this as KeyBinding,
    );
  }

  KeyBindingCopyWith<KeyBinding, KeyBinding, KeyBinding> get copyWith =>
      _KeyBindingCopyWithImpl<KeyBinding, KeyBinding>(
        this as KeyBinding,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return KeyBindingMapper.ensureInitialized().stringifyValue(
      this as KeyBinding,
    );
  }

  @override
  bool operator ==(Object other) {
    return KeyBindingMapper.ensureInitialized().equalsValue(
      this as KeyBinding,
      other,
    );
  }

  @override
  int get hashCode {
    return KeyBindingMapper.ensureInitialized().hashValue(this as KeyBinding);
  }
}

extension KeyBindingValueCopy<$R, $Out>
    on ObjectCopyWith<$R, KeyBinding, $Out> {
  KeyBindingCopyWith<$R, KeyBinding, $Out> get $asKeyBinding =>
      $base.as((v, t, t2) => _KeyBindingCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class KeyBindingCopyWith<$R, $In extends KeyBinding, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  KeyComboCopyWith<$R, KeyCombo, KeyCombo> get combo;
  $R call({String? action, KeyCombo? combo});
  KeyBindingCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _KeyBindingCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, KeyBinding, $Out>
    implements KeyBindingCopyWith<$R, KeyBinding, $Out> {
  _KeyBindingCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<KeyBinding> $mapper =
      KeyBindingMapper.ensureInitialized();
  @override
  KeyComboCopyWith<$R, KeyCombo, KeyCombo> get combo =>
      $value.combo.copyWith.$chain((v) => call(combo: v));
  @override
  $R call({String? action, KeyCombo? combo}) => $apply(
    FieldCopyWithData({
      if (action != null) #action: action,
      if (combo != null) #combo: combo,
    }),
  );
  @override
  KeyBinding $make(CopyWithData data) => KeyBinding(
    action: data.get(#action, or: $value.action),
    combo: data.get(#combo, or: $value.combo),
  );

  @override
  KeyBindingCopyWith<$R2, KeyBinding, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _KeyBindingCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

