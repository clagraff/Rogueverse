// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'game_settings_service.dart';

class GameSettingsMapper extends ClassMapperBase<GameSettings> {
  GameSettingsMapper._();

  static GameSettingsMapper? _instance;
  static GameSettingsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = GameSettingsMapper._());
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

  @override
  final MappableFields<GameSettings> fields = const {
    #alwaysShowHealthBars: _f$alwaysShowHealthBars,
  };

  static GameSettings _instantiate(DecodingData data) {
    return GameSettings(
      alwaysShowHealthBars: data.dec(_f$alwaysShowHealthBars),
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
  $R call({bool? alwaysShowHealthBars});
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
  $R call({bool? alwaysShowHealthBars}) => $apply(
    FieldCopyWithData({
      if (alwaysShowHealthBars != null)
        #alwaysShowHealthBars: alwaysShowHealthBars,
    }),
  );
  @override
  GameSettings $make(CopyWithData data) => GameSettings(
    alwaysShowHealthBars: data.get(
      #alwaysShowHealthBars,
      or: $value.alwaysShowHealthBars,
    ),
  );

  @override
  GameSettingsCopyWith<$R2, GameSettings, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _GameSettingsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

