// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'game_settings_service.dart';

class InteractionMacroModeMapper extends EnumMapper<InteractionMacroMode> {
  InteractionMacroModeMapper._();

  static InteractionMacroModeMapper? _instance;
  static InteractionMacroModeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = InteractionMacroModeMapper._());
    }
    return _instance!;
  }

  static InteractionMacroMode fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  InteractionMacroMode decode(dynamic value) {
    switch (value) {
      case r'disabled':
        return InteractionMacroMode.disabled;
      case r'lookBack':
        return InteractionMacroMode.lookBack;
      case r'remainFacing':
        return InteractionMacroMode.remainFacing;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(InteractionMacroMode self) {
    switch (self) {
      case InteractionMacroMode.disabled:
        return r'disabled';
      case InteractionMacroMode.lookBack:
        return r'lookBack';
      case InteractionMacroMode.remainFacing:
        return r'remainFacing';
    }
  }
}

extension InteractionMacroModeMapperExtension on InteractionMacroMode {
  String toValue() {
    InteractionMacroModeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<InteractionMacroMode>(this)
        as String;
  }
}

class DialogPositionMapper extends EnumMapper<DialogPosition> {
  DialogPositionMapper._();

  static DialogPositionMapper? _instance;
  static DialogPositionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DialogPositionMapper._());
    }
    return _instance!;
  }

  static DialogPosition fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  DialogPosition decode(dynamic value) {
    switch (value) {
      case r'bottom':
        return DialogPosition.bottom;
      case r'center':
        return DialogPosition.center;
      case r'top':
        return DialogPosition.top;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(DialogPosition self) {
    switch (self) {
      case DialogPosition.bottom:
        return r'bottom';
      case DialogPosition.center:
        return r'center';
      case DialogPosition.top:
        return r'top';
    }
  }
}

extension DialogPositionMapperExtension on DialogPosition {
  String toValue() {
    DialogPositionMapper.ensureInitialized();
    return MapperContainer.globals.toValue<DialogPosition>(this) as String;
  }
}

class GameSettingsMapper extends ClassMapperBase<GameSettings> {
  GameSettingsMapper._();

  static GameSettingsMapper? _instance;
  static GameSettingsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = GameSettingsMapper._());
      InteractionMacroModeMapper.ensureInitialized();
      DialogPositionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'GameSettings';

  static bool _$alwaysShowHealthBars(GameSettings v) => v.alwaysShowHealthBars;
  static const Field<GameSettings, bool> _f$alwaysShowHealthBars = Field(
    'alwaysShowHealthBars',
    _$alwaysShowHealthBars,
    opt: true,
    def: false,
  );
  static InteractionMacroMode _$interactionMacroMode(GameSettings v) =>
      v.interactionMacroMode;
  static const Field<GameSettings, InteractionMacroMode>
  _f$interactionMacroMode = Field(
    'interactionMacroMode',
    _$interactionMacroMode,
    opt: true,
    def: InteractionMacroMode.lookBack,
  );
  static DialogPosition _$dialogPosition(GameSettings v) => v.dialogPosition;
  static const Field<GameSettings, DialogPosition> _f$dialogPosition = Field(
    'dialogPosition',
    _$dialogPosition,
    opt: true,
    def: DialogPosition.bottom,
  );

  @override
  final MappableFields<GameSettings> fields = const {
    #alwaysShowHealthBars: _f$alwaysShowHealthBars,
    #interactionMacroMode: _f$interactionMacroMode,
    #dialogPosition: _f$dialogPosition,
  };

  static GameSettings _instantiate(DecodingData data) {
    return GameSettings(
      alwaysShowHealthBars: data.dec(_f$alwaysShowHealthBars),
      interactionMacroMode: data.dec(_f$interactionMacroMode),
      dialogPosition: data.dec(_f$dialogPosition),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static GameSettings fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<GameSettings>(map);
  }

  static GameSettings fromJson(String json) {
    return ensureInitialized().decodeJson<GameSettings>(json);
  }
}

mixin GameSettingsMappable {
  String toJson() {
    return GameSettingsMapper.ensureInitialized().encodeJson<GameSettings>(
      this as GameSettings,
    );
  }

  Map<String, dynamic> toMap() {
    return GameSettingsMapper.ensureInitialized().encodeMap<GameSettings>(
      this as GameSettings,
    );
  }

  GameSettingsCopyWith<GameSettings, GameSettings, GameSettings> get copyWith =>
      _GameSettingsCopyWithImpl<GameSettings, GameSettings>(
        this as GameSettings,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return GameSettingsMapper.ensureInitialized().stringifyValue(
      this as GameSettings,
    );
  }

  @override
  bool operator ==(Object other) {
    return GameSettingsMapper.ensureInitialized().equalsValue(
      this as GameSettings,
      other,
    );
  }

  @override
  int get hashCode {
    return GameSettingsMapper.ensureInitialized().hashValue(
      this as GameSettings,
    );
  }
}

extension GameSettingsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, GameSettings, $Out> {
  GameSettingsCopyWith<$R, GameSettings, $Out> get $asGameSettings =>
      $base.as((v, t, t2) => _GameSettingsCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class GameSettingsCopyWith<$R, $In extends GameSettings, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    bool? alwaysShowHealthBars,
    InteractionMacroMode? interactionMacroMode,
    DialogPosition? dialogPosition,
  });
  GameSettingsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _GameSettingsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, GameSettings, $Out>
    implements GameSettingsCopyWith<$R, GameSettings, $Out> {
  _GameSettingsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<GameSettings> $mapper =
      GameSettingsMapper.ensureInitialized();
  @override
  $R call({
    bool? alwaysShowHealthBars,
    InteractionMacroMode? interactionMacroMode,
    DialogPosition? dialogPosition,
  }) => $apply(
    FieldCopyWithData({
      if (alwaysShowHealthBars != null)
        #alwaysShowHealthBars: alwaysShowHealthBars,
      if (interactionMacroMode != null)
        #interactionMacroMode: interactionMacroMode,
      if (dialogPosition != null) #dialogPosition: dialogPosition,
    }),
  );
  @override
  GameSettings $make(CopyWithData data) => GameSettings(
    alwaysShowHealthBars: data.get(
      #alwaysShowHealthBars,
      or: $value.alwaysShowHealthBars,
    ),
    interactionMacroMode: data.get(
      #interactionMacroMode,
      or: $value.interactionMacroMode,
    ),
    dialogPosition: data.get(#dialogPosition, or: $value.dialogPosition),
  );

  @override
  GameSettingsCopyWith<$R2, GameSettings, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _GameSettingsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

