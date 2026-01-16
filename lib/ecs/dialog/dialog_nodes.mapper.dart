// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'dialog_nodes.dart';

class DialogResultMapper extends ClassMapperBase<DialogResult> {
  DialogResultMapper._();

  static DialogResultMapper? _instance;
  static DialogResultMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DialogResultMapper._());
      DialogAwaitingChoiceMapper.ensureInitialized();
      DialogEndedMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DialogResult';

  @override
  final MappableFields<DialogResult> fields = const {};

  static DialogResult _instantiate(DecodingData data) {
    throw MapperException.missingSubclass(
      'DialogResult',
      '__type',
      '${data.value['__type']}',
    );
  }

  @override
  final Function instantiate = _instantiate;

  static DialogResult fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DialogResult>(map);
  }

  static DialogResult fromJson(String json) {
    return ensureInitialized().decodeJson<DialogResult>(json);
  }
}

mixin DialogResultMappable {
  String toJson();
  Map<String, dynamic> toMap();
  DialogResultCopyWith<DialogResult, DialogResult, DialogResult> get copyWith;
}

abstract class DialogResultCopyWith<$R, $In extends DialogResult, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  DialogResultCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class DialogAwaitingChoiceMapper
    extends SubClassMapperBase<DialogAwaitingChoice> {
  DialogAwaitingChoiceMapper._();

  static DialogAwaitingChoiceMapper? _instance;
  static DialogAwaitingChoiceMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DialogAwaitingChoiceMapper._());
      DialogResultMapper.ensureInitialized().addSubMapper(_instance!);
      DialogChoiceMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DialogAwaitingChoice';

  static String _$speakerName(DialogAwaitingChoice v) => v.speakerName;
  static const Field<DialogAwaitingChoice, String> _f$speakerName = Field(
    'speakerName',
    _$speakerName,
  );
  static String _$text(DialogAwaitingChoice v) => v.text;
  static const Field<DialogAwaitingChoice, String> _f$text = Field(
    'text',
    _$text,
  );
  static List<DialogChoice> _$choices(DialogAwaitingChoice v) => v.choices;
  static const Field<DialogAwaitingChoice, List<DialogChoice>> _f$choices =
      Field('choices', _$choices);

  @override
  final MappableFields<DialogAwaitingChoice> fields = const {
    #speakerName: _f$speakerName,
    #text: _f$text,
    #choices: _f$choices,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'DialogAwaitingChoice';
  @override
  late final ClassMapperBase superMapper =
      DialogResultMapper.ensureInitialized();

  static DialogAwaitingChoice _instantiate(DecodingData data) {
    return DialogAwaitingChoice(
      speakerName: data.dec(_f$speakerName),
      text: data.dec(_f$text),
      choices: data.dec(_f$choices),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static DialogAwaitingChoice fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DialogAwaitingChoice>(map);
  }

  static DialogAwaitingChoice fromJson(String json) {
    return ensureInitialized().decodeJson<DialogAwaitingChoice>(json);
  }
}

mixin DialogAwaitingChoiceMappable {
  String toJson() {
    return DialogAwaitingChoiceMapper.ensureInitialized()
        .encodeJson<DialogAwaitingChoice>(this as DialogAwaitingChoice);
  }

  Map<String, dynamic> toMap() {
    return DialogAwaitingChoiceMapper.ensureInitialized()
        .encodeMap<DialogAwaitingChoice>(this as DialogAwaitingChoice);
  }

  DialogAwaitingChoiceCopyWith<
    DialogAwaitingChoice,
    DialogAwaitingChoice,
    DialogAwaitingChoice
  >
  get copyWith =>
      _DialogAwaitingChoiceCopyWithImpl<
        DialogAwaitingChoice,
        DialogAwaitingChoice
      >(this as DialogAwaitingChoice, $identity, $identity);
  @override
  String toString() {
    return DialogAwaitingChoiceMapper.ensureInitialized().stringifyValue(
      this as DialogAwaitingChoice,
    );
  }

  @override
  bool operator ==(Object other) {
    return DialogAwaitingChoiceMapper.ensureInitialized().equalsValue(
      this as DialogAwaitingChoice,
      other,
    );
  }

  @override
  int get hashCode {
    return DialogAwaitingChoiceMapper.ensureInitialized().hashValue(
      this as DialogAwaitingChoice,
    );
  }
}

extension DialogAwaitingChoiceValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DialogAwaitingChoice, $Out> {
  DialogAwaitingChoiceCopyWith<$R, DialogAwaitingChoice, $Out>
  get $asDialogAwaitingChoice => $base.as(
    (v, t, t2) => _DialogAwaitingChoiceCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class DialogAwaitingChoiceCopyWith<
  $R,
  $In extends DialogAwaitingChoice,
  $Out
>
    implements DialogResultCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    DialogChoice,
    DialogChoiceCopyWith<$R, DialogChoice, DialogChoice>
  >
  get choices;
  @override
  $R call({String? speakerName, String? text, List<DialogChoice>? choices});
  DialogAwaitingChoiceCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _DialogAwaitingChoiceCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DialogAwaitingChoice, $Out>
    implements DialogAwaitingChoiceCopyWith<$R, DialogAwaitingChoice, $Out> {
  _DialogAwaitingChoiceCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DialogAwaitingChoice> $mapper =
      DialogAwaitingChoiceMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    DialogChoice,
    DialogChoiceCopyWith<$R, DialogChoice, DialogChoice>
  >
  get choices => ListCopyWith(
    $value.choices,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(choices: v),
  );
  @override
  $R call({String? speakerName, String? text, List<DialogChoice>? choices}) =>
      $apply(
        FieldCopyWithData({
          if (speakerName != null) #speakerName: speakerName,
          if (text != null) #text: text,
          if (choices != null) #choices: choices,
        }),
      );
  @override
  DialogAwaitingChoice $make(CopyWithData data) => DialogAwaitingChoice(
    speakerName: data.get(#speakerName, or: $value.speakerName),
    text: data.get(#text, or: $value.text),
    choices: data.get(#choices, or: $value.choices),
  );

  @override
  DialogAwaitingChoiceCopyWith<$R2, DialogAwaitingChoice, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _DialogAwaitingChoiceCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DialogChoiceMapper extends ClassMapperBase<DialogChoice> {
  DialogChoiceMapper._();

  static DialogChoiceMapper? _instance;
  static DialogChoiceMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DialogChoiceMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'DialogChoice';

  static String _$text(DialogChoice v) => v.text;
  static const Field<DialogChoice, String> _f$text = Field('text', _$text);
  static String? _$conditionLabel(DialogChoice v) => v.conditionLabel;
  static const Field<DialogChoice, String> _f$conditionLabel = Field(
    'conditionLabel',
    _$conditionLabel,
    opt: true,
  );
  static bool _$isAvailable(DialogChoice v) => v.isAvailable;
  static const Field<DialogChoice, bool> _f$isAvailable = Field(
    'isAvailable',
    _$isAvailable,
  );
  static int _$choiceIndex(DialogChoice v) => v.choiceIndex;
  static const Field<DialogChoice, int> _f$choiceIndex = Field(
    'choiceIndex',
    _$choiceIndex,
  );

  @override
  final MappableFields<DialogChoice> fields = const {
    #text: _f$text,
    #conditionLabel: _f$conditionLabel,
    #isAvailable: _f$isAvailable,
    #choiceIndex: _f$choiceIndex,
  };

  static DialogChoice _instantiate(DecodingData data) {
    return DialogChoice(
      text: data.dec(_f$text),
      conditionLabel: data.dec(_f$conditionLabel),
      isAvailable: data.dec(_f$isAvailable),
      choiceIndex: data.dec(_f$choiceIndex),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static DialogChoice fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DialogChoice>(map);
  }

  static DialogChoice fromJson(String json) {
    return ensureInitialized().decodeJson<DialogChoice>(json);
  }
}

mixin DialogChoiceMappable {
  String toJson() {
    return DialogChoiceMapper.ensureInitialized().encodeJson<DialogChoice>(
      this as DialogChoice,
    );
  }

  Map<String, dynamic> toMap() {
    return DialogChoiceMapper.ensureInitialized().encodeMap<DialogChoice>(
      this as DialogChoice,
    );
  }

  DialogChoiceCopyWith<DialogChoice, DialogChoice, DialogChoice> get copyWith =>
      _DialogChoiceCopyWithImpl<DialogChoice, DialogChoice>(
        this as DialogChoice,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DialogChoiceMapper.ensureInitialized().stringifyValue(
      this as DialogChoice,
    );
  }

  @override
  bool operator ==(Object other) {
    return DialogChoiceMapper.ensureInitialized().equalsValue(
      this as DialogChoice,
      other,
    );
  }

  @override
  int get hashCode {
    return DialogChoiceMapper.ensureInitialized().hashValue(
      this as DialogChoice,
    );
  }
}

extension DialogChoiceValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DialogChoice, $Out> {
  DialogChoiceCopyWith<$R, DialogChoice, $Out> get $asDialogChoice =>
      $base.as((v, t, t2) => _DialogChoiceCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DialogChoiceCopyWith<$R, $In extends DialogChoice, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? text,
    String? conditionLabel,
    bool? isAvailable,
    int? choiceIndex,
  });
  DialogChoiceCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DialogChoiceCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DialogChoice, $Out>
    implements DialogChoiceCopyWith<$R, DialogChoice, $Out> {
  _DialogChoiceCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DialogChoice> $mapper =
      DialogChoiceMapper.ensureInitialized();
  @override
  $R call({
    String? text,
    Object? conditionLabel = $none,
    bool? isAvailable,
    int? choiceIndex,
  }) => $apply(
    FieldCopyWithData({
      if (text != null) #text: text,
      if (conditionLabel != $none) #conditionLabel: conditionLabel,
      if (isAvailable != null) #isAvailable: isAvailable,
      if (choiceIndex != null) #choiceIndex: choiceIndex,
    }),
  );
  @override
  DialogChoice $make(CopyWithData data) => DialogChoice(
    text: data.get(#text, or: $value.text),
    conditionLabel: data.get(#conditionLabel, or: $value.conditionLabel),
    isAvailable: data.get(#isAvailable, or: $value.isAvailable),
    choiceIndex: data.get(#choiceIndex, or: $value.choiceIndex),
  );

  @override
  DialogChoiceCopyWith<$R2, DialogChoice, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DialogChoiceCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DialogEndedMapper extends SubClassMapperBase<DialogEnded> {
  DialogEndedMapper._();

  static DialogEndedMapper? _instance;
  static DialogEndedMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DialogEndedMapper._());
      DialogResultMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'DialogEnded';

  @override
  final MappableFields<DialogEnded> fields = const {};

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'DialogEnded';
  @override
  late final ClassMapperBase superMapper =
      DialogResultMapper.ensureInitialized();

  static DialogEnded _instantiate(DecodingData data) {
    return DialogEnded();
  }

  @override
  final Function instantiate = _instantiate;

  static DialogEnded fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DialogEnded>(map);
  }

  static DialogEnded fromJson(String json) {
    return ensureInitialized().decodeJson<DialogEnded>(json);
  }
}

mixin DialogEndedMappable {
  String toJson() {
    return DialogEndedMapper.ensureInitialized().encodeJson<DialogEnded>(
      this as DialogEnded,
    );
  }

  Map<String, dynamic> toMap() {
    return DialogEndedMapper.ensureInitialized().encodeMap<DialogEnded>(
      this as DialogEnded,
    );
  }

  DialogEndedCopyWith<DialogEnded, DialogEnded, DialogEnded> get copyWith =>
      _DialogEndedCopyWithImpl<DialogEnded, DialogEnded>(
        this as DialogEnded,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DialogEndedMapper.ensureInitialized().stringifyValue(
      this as DialogEnded,
    );
  }

  @override
  bool operator ==(Object other) {
    return DialogEndedMapper.ensureInitialized().equalsValue(
      this as DialogEnded,
      other,
    );
  }

  @override
  int get hashCode {
    return DialogEndedMapper.ensureInitialized().hashValue(this as DialogEnded);
  }
}

extension DialogEndedValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DialogEnded, $Out> {
  DialogEndedCopyWith<$R, DialogEnded, $Out> get $asDialogEnded =>
      $base.as((v, t, t2) => _DialogEndedCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DialogEndedCopyWith<$R, $In extends DialogEnded, $Out>
    implements DialogResultCopyWith<$R, $In, $Out> {
  @override
  $R call();
  DialogEndedCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DialogEndedCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DialogEnded, $Out>
    implements DialogEndedCopyWith<$R, DialogEnded, $Out> {
  _DialogEndedCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DialogEnded> $mapper =
      DialogEndedMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  DialogEnded $make(CopyWithData data) => DialogEnded();

  @override
  DialogEndedCopyWith<$R2, DialogEnded, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DialogEndedCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DialogNodeMapper extends ClassMapperBase<DialogNode> {
  DialogNodeMapper._();

  static DialogNodeMapper? _instance;
  static DialogNodeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DialogNodeMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'DialogNode';

  @override
  final MappableFields<DialogNode> fields = const {};

  static DialogNode _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('DialogNode');
  }

  @override
  final Function instantiate = _instantiate;

  static DialogNode fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DialogNode>(map);
  }

  static DialogNode fromJson(String json) {
    return ensureInitialized().decodeJson<DialogNode>(json);
  }
}

mixin DialogNodeMappable {
  String toJson();
  Map<String, dynamic> toMap();
  DialogNodeCopyWith<DialogNode, DialogNode, DialogNode> get copyWith;
}

abstract class DialogNodeCopyWith<$R, $In extends DialogNode, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  DialogNodeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

