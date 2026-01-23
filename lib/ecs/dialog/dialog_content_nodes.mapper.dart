// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'dialog_content_nodes.dart';

class ChoiceMapper extends ClassMapperBase<Choice> {
  ChoiceMapper._();

  static ChoiceMapper? _instance;
  static ChoiceMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ChoiceMapper._());
      DialogConditionMapper.ensureInitialized();
      DialogNodeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Choice';

  static String _$text(Choice v) => v.text;
  static const Field<Choice, String> _f$text = Field('text', _$text);
  static DialogCondition? _$condition(Choice v) => v.condition;
  static const Field<Choice, DialogCondition> _f$condition = Field(
    'condition',
    _$condition,
    opt: true,
  );
  static String? _$conditionLabel(Choice v) => v.conditionLabel;
  static const Field<Choice, String> _f$conditionLabel = Field(
    'conditionLabel',
    _$conditionLabel,
    opt: true,
  );
  static bool _$showWhenUnavailable(Choice v) => v.showWhenUnavailable;
  static const Field<Choice, bool> _f$showWhenUnavailable = Field(
    'showWhenUnavailable',
    _$showWhenUnavailable,
    opt: true,
    def: true,
  );
  static DialogNode _$child(Choice v) => v.child;
  static const Field<Choice, DialogNode> _f$child = Field('child', _$child);

  @override
  final MappableFields<Choice> fields = const {
    #text: _f$text,
    #condition: _f$condition,
    #conditionLabel: _f$conditionLabel,
    #showWhenUnavailable: _f$showWhenUnavailable,
    #child: _f$child,
  };

  static Choice _instantiate(DecodingData data) {
    return Choice(
      text: data.dec(_f$text),
      condition: data.dec(_f$condition),
      conditionLabel: data.dec(_f$conditionLabel),
      showWhenUnavailable: data.dec(_f$showWhenUnavailable),
      child: data.dec(_f$child),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Choice fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Choice>(map);
  }

  static Choice fromJson(String json) {
    return ensureInitialized().decodeJson<Choice>(json);
  }
}

mixin ChoiceMappable {
  String toJson() {
    return ChoiceMapper.ensureInitialized().encodeJson<Choice>(this as Choice);
  }

  Map<String, dynamic> toMap() {
    return ChoiceMapper.ensureInitialized().encodeMap<Choice>(this as Choice);
  }

  ChoiceCopyWith<Choice, Choice, Choice> get copyWith =>
      _ChoiceCopyWithImpl<Choice, Choice>(this as Choice, $identity, $identity);
  @override
  String toString() {
    return ChoiceMapper.ensureInitialized().stringifyValue(this as Choice);
  }

  @override
  bool operator ==(Object other) {
    return ChoiceMapper.ensureInitialized().equalsValue(this as Choice, other);
  }

  @override
  int get hashCode {
    return ChoiceMapper.ensureInitialized().hashValue(this as Choice);
  }
}

extension ChoiceValueCopy<$R, $Out> on ObjectCopyWith<$R, Choice, $Out> {
  ChoiceCopyWith<$R, Choice, $Out> get $asChoice =>
      $base.as((v, t, t2) => _ChoiceCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ChoiceCopyWith<$R, $In extends Choice, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  DialogNodeCopyWith<$R, DialogNode, DialogNode> get child;
  $R call({
    String? text,
    DialogCondition? condition,
    String? conditionLabel,
    bool? showWhenUnavailable,
    DialogNode? child,
  });
  ChoiceCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ChoiceCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Choice, $Out>
    implements ChoiceCopyWith<$R, Choice, $Out> {
  _ChoiceCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Choice> $mapper = ChoiceMapper.ensureInitialized();
  @override
  DialogNodeCopyWith<$R, DialogNode, DialogNode> get child =>
      $value.child.copyWith.$chain((v) => call(child: v));
  @override
  $R call({
    String? text,
    Object? condition = $none,
    Object? conditionLabel = $none,
    bool? showWhenUnavailable,
    DialogNode? child,
  }) => $apply(
    FieldCopyWithData({
      if (text != null) #text: text,
      if (condition != $none) #condition: condition,
      if (conditionLabel != $none) #conditionLabel: conditionLabel,
      if (showWhenUnavailable != null)
        #showWhenUnavailable: showWhenUnavailable,
      if (child != null) #child: child,
    }),
  );
  @override
  Choice $make(CopyWithData data) => Choice(
    text: data.get(#text, or: $value.text),
    condition: data.get(#condition, or: $value.condition),
    conditionLabel: data.get(#conditionLabel, or: $value.conditionLabel),
    showWhenUnavailable: data.get(
      #showWhenUnavailable,
      or: $value.showWhenUnavailable,
    ),
    child: data.get(#child, or: $value.child),
  );

  @override
  ChoiceCopyWith<$R2, Choice, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ChoiceCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class SpeakNodeMapper extends SubClassMapperBase<SpeakNode> {
  SpeakNodeMapper._();

  static SpeakNodeMapper? _instance;
  static SpeakNodeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SpeakNodeMapper._());
      DialogNodeMapper.ensureInitialized().addSubMapper(_instance!);
      ChoiceMapper.ensureInitialized();
      DialogEffectMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'SpeakNode';

  static String _$id(SpeakNode v) => v.id;
  static const Field<SpeakNode, String> _f$id = Field('id', _$id);
  static String _$speakerName(SpeakNode v) => v.speakerName;
  static const Field<SpeakNode, String> _f$speakerName = Field(
    'speakerName',
    _$speakerName,
  );
  static String _$text(SpeakNode v) => v.text;
  static const Field<SpeakNode, String> _f$text = Field('text', _$text);
  static List<Choice> _$choices(SpeakNode v) => v.choices;
  static const Field<SpeakNode, List<Choice>> _f$choices = Field(
    'choices',
    _$choices,
  );
  static List<DialogEffect> _$effects(SpeakNode v) => v.effects;
  static const Field<SpeakNode, List<DialogEffect>> _f$effects = Field(
    'effects',
    _$effects,
    opt: true,
    def: const [],
  );

  @override
  final MappableFields<SpeakNode> fields = const {
    #id: _f$id,
    #speakerName: _f$speakerName,
    #text: _f$text,
    #choices: _f$choices,
    #effects: _f$effects,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'SpeakNode';
  @override
  late final ClassMapperBase superMapper = DialogNodeMapper.ensureInitialized();

  static SpeakNode _instantiate(DecodingData data) {
    return SpeakNode(
      id: data.dec(_f$id),
      speakerName: data.dec(_f$speakerName),
      text: data.dec(_f$text),
      choices: data.dec(_f$choices),
      effects: data.dec(_f$effects),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static SpeakNode fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SpeakNode>(map);
  }

  static SpeakNode fromJson(String json) {
    return ensureInitialized().decodeJson<SpeakNode>(json);
  }
}

mixin SpeakNodeMappable {
  String toJson() {
    return SpeakNodeMapper.ensureInitialized().encodeJson<SpeakNode>(
      this as SpeakNode,
    );
  }

  Map<String, dynamic> toMap() {
    return SpeakNodeMapper.ensureInitialized().encodeMap<SpeakNode>(
      this as SpeakNode,
    );
  }

  SpeakNodeCopyWith<SpeakNode, SpeakNode, SpeakNode> get copyWith =>
      _SpeakNodeCopyWithImpl<SpeakNode, SpeakNode>(
        this as SpeakNode,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return SpeakNodeMapper.ensureInitialized().stringifyValue(
      this as SpeakNode,
    );
  }

  @override
  bool operator ==(Object other) {
    return SpeakNodeMapper.ensureInitialized().equalsValue(
      this as SpeakNode,
      other,
    );
  }

  @override
  int get hashCode {
    return SpeakNodeMapper.ensureInitialized().hashValue(this as SpeakNode);
  }
}

extension SpeakNodeValueCopy<$R, $Out> on ObjectCopyWith<$R, SpeakNode, $Out> {
  SpeakNodeCopyWith<$R, SpeakNode, $Out> get $asSpeakNode =>
      $base.as((v, t, t2) => _SpeakNodeCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class SpeakNodeCopyWith<$R, $In extends SpeakNode, $Out>
    implements DialogNodeCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Choice, ChoiceCopyWith<$R, Choice, Choice>> get choices;
  ListCopyWith<$R, DialogEffect, ObjectCopyWith<$R, DialogEffect, DialogEffect>>
  get effects;
  @override
  $R call({
    String? id,
    String? speakerName,
    String? text,
    List<Choice>? choices,
    List<DialogEffect>? effects,
  });
  SpeakNodeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _SpeakNodeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SpeakNode, $Out>
    implements SpeakNodeCopyWith<$R, SpeakNode, $Out> {
  _SpeakNodeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SpeakNode> $mapper =
      SpeakNodeMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Choice, ChoiceCopyWith<$R, Choice, Choice>> get choices =>
      ListCopyWith(
        $value.choices,
        (v, t) => v.copyWith.$chain(t),
        (v) => call(choices: v),
      );
  @override
  ListCopyWith<$R, DialogEffect, ObjectCopyWith<$R, DialogEffect, DialogEffect>>
  get effects => ListCopyWith(
    $value.effects,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(effects: v),
  );
  @override
  $R call({
    String? id,
    String? speakerName,
    String? text,
    List<Choice>? choices,
    List<DialogEffect>? effects,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (speakerName != null) #speakerName: speakerName,
      if (text != null) #text: text,
      if (choices != null) #choices: choices,
      if (effects != null) #effects: effects,
    }),
  );
  @override
  SpeakNode $make(CopyWithData data) => SpeakNode(
    id: data.get(#id, or: $value.id),
    speakerName: data.get(#speakerName, or: $value.speakerName),
    text: data.get(#text, or: $value.text),
    choices: data.get(#choices, or: $value.choices),
    effects: data.get(#effects, or: $value.effects),
  );

  @override
  SpeakNodeCopyWith<$R2, SpeakNode, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _SpeakNodeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class TextNodeMapper extends SubClassMapperBase<TextNode> {
  TextNodeMapper._();

  static TextNodeMapper? _instance;
  static TextNodeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TextNodeMapper._());
      DialogNodeMapper.ensureInitialized().addSubMapper(_instance!);
      DialogNodeMapper.ensureInitialized();
      DialogEffectMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'TextNode';

  static String _$id(TextNode v) => v.id;
  static const Field<TextNode, String> _f$id = Field('id', _$id);
  static String _$speakerName(TextNode v) => v.speakerName;
  static const Field<TextNode, String> _f$speakerName = Field(
    'speakerName',
    _$speakerName,
  );
  static String _$text(TextNode v) => v.text;
  static const Field<TextNode, String> _f$text = Field('text', _$text);
  static DialogNode? _$next(TextNode v) => v.next;
  static const Field<TextNode, DialogNode> _f$next = Field(
    'next',
    _$next,
    opt: true,
  );
  static List<DialogEffect> _$effects(TextNode v) => v.effects;
  static const Field<TextNode, List<DialogEffect>> _f$effects = Field(
    'effects',
    _$effects,
    opt: true,
    def: const [],
  );
  static String _$continueText(TextNode v) => v.continueText;
  static const Field<TextNode, String> _f$continueText = Field(
    'continueText',
    _$continueText,
    opt: true,
    def: '(continue)',
  );

  @override
  final MappableFields<TextNode> fields = const {
    #id: _f$id,
    #speakerName: _f$speakerName,
    #text: _f$text,
    #next: _f$next,
    #effects: _f$effects,
    #continueText: _f$continueText,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'TextNode';
  @override
  late final ClassMapperBase superMapper = DialogNodeMapper.ensureInitialized();

  static TextNode _instantiate(DecodingData data) {
    return TextNode(
      id: data.dec(_f$id),
      speakerName: data.dec(_f$speakerName),
      text: data.dec(_f$text),
      next: data.dec(_f$next),
      effects: data.dec(_f$effects),
      continueText: data.dec(_f$continueText),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TextNode fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TextNode>(map);
  }

  static TextNode fromJson(String json) {
    return ensureInitialized().decodeJson<TextNode>(json);
  }
}

mixin TextNodeMappable {
  String toJson() {
    return TextNodeMapper.ensureInitialized().encodeJson<TextNode>(
      this as TextNode,
    );
  }

  Map<String, dynamic> toMap() {
    return TextNodeMapper.ensureInitialized().encodeMap<TextNode>(
      this as TextNode,
    );
  }

  TextNodeCopyWith<TextNode, TextNode, TextNode> get copyWith =>
      _TextNodeCopyWithImpl<TextNode, TextNode>(
        this as TextNode,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return TextNodeMapper.ensureInitialized().stringifyValue(this as TextNode);
  }

  @override
  bool operator ==(Object other) {
    return TextNodeMapper.ensureInitialized().equalsValue(
      this as TextNode,
      other,
    );
  }

  @override
  int get hashCode {
    return TextNodeMapper.ensureInitialized().hashValue(this as TextNode);
  }
}

extension TextNodeValueCopy<$R, $Out> on ObjectCopyWith<$R, TextNode, $Out> {
  TextNodeCopyWith<$R, TextNode, $Out> get $asTextNode =>
      $base.as((v, t, t2) => _TextNodeCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TextNodeCopyWith<$R, $In extends TextNode, $Out>
    implements DialogNodeCopyWith<$R, $In, $Out> {
  DialogNodeCopyWith<$R, DialogNode, DialogNode>? get next;
  ListCopyWith<$R, DialogEffect, ObjectCopyWith<$R, DialogEffect, DialogEffect>>
  get effects;
  @override
  $R call({
    String? id,
    String? speakerName,
    String? text,
    DialogNode? next,
    List<DialogEffect>? effects,
    String? continueText,
  });
  TextNodeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _TextNodeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TextNode, $Out>
    implements TextNodeCopyWith<$R, TextNode, $Out> {
  _TextNodeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TextNode> $mapper =
      TextNodeMapper.ensureInitialized();
  @override
  DialogNodeCopyWith<$R, DialogNode, DialogNode>? get next =>
      $value.next?.copyWith.$chain((v) => call(next: v));
  @override
  ListCopyWith<$R, DialogEffect, ObjectCopyWith<$R, DialogEffect, DialogEffect>>
  get effects => ListCopyWith(
    $value.effects,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(effects: v),
  );
  @override
  $R call({
    String? id,
    String? speakerName,
    String? text,
    Object? next = $none,
    List<DialogEffect>? effects,
    String? continueText,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (speakerName != null) #speakerName: speakerName,
      if (text != null) #text: text,
      if (next != $none) #next: next,
      if (effects != null) #effects: effects,
      if (continueText != null) #continueText: continueText,
    }),
  );
  @override
  TextNode $make(CopyWithData data) => TextNode(
    id: data.get(#id, or: $value.id),
    speakerName: data.get(#speakerName, or: $value.speakerName),
    text: data.get(#text, or: $value.text),
    next: data.get(#next, or: $value.next),
    effects: data.get(#effects, or: $value.effects),
    continueText: data.get(#continueText, or: $value.continueText),
  );

  @override
  TextNodeCopyWith<$R2, TextNode, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TextNodeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class EndNodeMapper extends SubClassMapperBase<EndNode> {
  EndNodeMapper._();

  static EndNodeMapper? _instance;
  static EndNodeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EndNodeMapper._());
      DialogNodeMapper.ensureInitialized().addSubMapper(_instance!);
      DialogEffectMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'EndNode';

  static String _$id(EndNode v) => v.id;
  static const Field<EndNode, String> _f$id = Field('id', _$id);
  static List<DialogEffect> _$effects(EndNode v) => v.effects;
  static const Field<EndNode, List<DialogEffect>> _f$effects = Field(
    'effects',
    _$effects,
    opt: true,
    def: const [],
  );

  @override
  final MappableFields<EndNode> fields = const {
    #id: _f$id,
    #effects: _f$effects,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'EndNode';
  @override
  late final ClassMapperBase superMapper = DialogNodeMapper.ensureInitialized();

  static EndNode _instantiate(DecodingData data) {
    return EndNode(id: data.dec(_f$id), effects: data.dec(_f$effects));
  }

  @override
  final Function instantiate = _instantiate;

  static EndNode fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EndNode>(map);
  }

  static EndNode fromJson(String json) {
    return ensureInitialized().decodeJson<EndNode>(json);
  }
}

mixin EndNodeMappable {
  String toJson() {
    return EndNodeMapper.ensureInitialized().encodeJson<EndNode>(
      this as EndNode,
    );
  }

  Map<String, dynamic> toMap() {
    return EndNodeMapper.ensureInitialized().encodeMap<EndNode>(
      this as EndNode,
    );
  }

  EndNodeCopyWith<EndNode, EndNode, EndNode> get copyWith =>
      _EndNodeCopyWithImpl<EndNode, EndNode>(
        this as EndNode,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return EndNodeMapper.ensureInitialized().stringifyValue(this as EndNode);
  }

  @override
  bool operator ==(Object other) {
    return EndNodeMapper.ensureInitialized().equalsValue(
      this as EndNode,
      other,
    );
  }

  @override
  int get hashCode {
    return EndNodeMapper.ensureInitialized().hashValue(this as EndNode);
  }
}

extension EndNodeValueCopy<$R, $Out> on ObjectCopyWith<$R, EndNode, $Out> {
  EndNodeCopyWith<$R, EndNode, $Out> get $asEndNode =>
      $base.as((v, t, t2) => _EndNodeCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class EndNodeCopyWith<$R, $In extends EndNode, $Out>
    implements DialogNodeCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, DialogEffect, ObjectCopyWith<$R, DialogEffect, DialogEffect>>
  get effects;
  @override
  $R call({String? id, List<DialogEffect>? effects});
  EndNodeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _EndNodeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EndNode, $Out>
    implements EndNodeCopyWith<$R, EndNode, $Out> {
  _EndNodeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EndNode> $mapper =
      EndNodeMapper.ensureInitialized();
  @override
  ListCopyWith<$R, DialogEffect, ObjectCopyWith<$R, DialogEffect, DialogEffect>>
  get effects => ListCopyWith(
    $value.effects,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(effects: v),
  );
  @override
  $R call({String? id, List<DialogEffect>? effects}) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (effects != null) #effects: effects,
    }),
  );
  @override
  EndNode $make(CopyWithData data) => EndNode(
    id: data.get(#id, or: $value.id),
    effects: data.get(#effects, or: $value.effects),
  );

  @override
  EndNodeCopyWith<$R2, EndNode, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _EndNodeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class EffectNodeMapper extends SubClassMapperBase<EffectNode> {
  EffectNodeMapper._();

  static EffectNodeMapper? _instance;
  static EffectNodeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EffectNodeMapper._());
      DialogNodeMapper.ensureInitialized().addSubMapper(_instance!);
      DialogEffectMapper.ensureInitialized();
      DialogNodeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'EffectNode';

  static String _$id(EffectNode v) => v.id;
  static const Field<EffectNode, String> _f$id = Field('id', _$id);
  static List<DialogEffect> _$effects(EffectNode v) => v.effects;
  static const Field<EffectNode, List<DialogEffect>> _f$effects = Field(
    'effects',
    _$effects,
  );
  static DialogNode _$next(EffectNode v) => v.next;
  static const Field<EffectNode, DialogNode> _f$next = Field('next', _$next);

  @override
  final MappableFields<EffectNode> fields = const {
    #id: _f$id,
    #effects: _f$effects,
    #next: _f$next,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'EffectNode';
  @override
  late final ClassMapperBase superMapper = DialogNodeMapper.ensureInitialized();

  static EffectNode _instantiate(DecodingData data) {
    return EffectNode(
      id: data.dec(_f$id),
      effects: data.dec(_f$effects),
      next: data.dec(_f$next),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static EffectNode fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EffectNode>(map);
  }

  static EffectNode fromJson(String json) {
    return ensureInitialized().decodeJson<EffectNode>(json);
  }
}

mixin EffectNodeMappable {
  String toJson() {
    return EffectNodeMapper.ensureInitialized().encodeJson<EffectNode>(
      this as EffectNode,
    );
  }

  Map<String, dynamic> toMap() {
    return EffectNodeMapper.ensureInitialized().encodeMap<EffectNode>(
      this as EffectNode,
    );
  }

  EffectNodeCopyWith<EffectNode, EffectNode, EffectNode> get copyWith =>
      _EffectNodeCopyWithImpl<EffectNode, EffectNode>(
        this as EffectNode,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return EffectNodeMapper.ensureInitialized().stringifyValue(
      this as EffectNode,
    );
  }

  @override
  bool operator ==(Object other) {
    return EffectNodeMapper.ensureInitialized().equalsValue(
      this as EffectNode,
      other,
    );
  }

  @override
  int get hashCode {
    return EffectNodeMapper.ensureInitialized().hashValue(this as EffectNode);
  }
}

extension EffectNodeValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EffectNode, $Out> {
  EffectNodeCopyWith<$R, EffectNode, $Out> get $asEffectNode =>
      $base.as((v, t, t2) => _EffectNodeCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class EffectNodeCopyWith<$R, $In extends EffectNode, $Out>
    implements DialogNodeCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, DialogEffect, ObjectCopyWith<$R, DialogEffect, DialogEffect>>
  get effects;
  DialogNodeCopyWith<$R, DialogNode, DialogNode> get next;
  @override
  $R call({String? id, List<DialogEffect>? effects, DialogNode? next});
  EffectNodeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _EffectNodeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EffectNode, $Out>
    implements EffectNodeCopyWith<$R, EffectNode, $Out> {
  _EffectNodeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EffectNode> $mapper =
      EffectNodeMapper.ensureInitialized();
  @override
  ListCopyWith<$R, DialogEffect, ObjectCopyWith<$R, DialogEffect, DialogEffect>>
  get effects => ListCopyWith(
    $value.effects,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(effects: v),
  );
  @override
  DialogNodeCopyWith<$R, DialogNode, DialogNode> get next =>
      $value.next.copyWith.$chain((v) => call(next: v));
  @override
  $R call({String? id, List<DialogEffect>? effects, DialogNode? next}) =>
      $apply(
        FieldCopyWithData({
          if (id != null) #id: id,
          if (effects != null) #effects: effects,
          if (next != null) #next: next,
        }),
      );
  @override
  EffectNode $make(CopyWithData data) => EffectNode(
    id: data.get(#id, or: $value.id),
    effects: data.get(#effects, or: $value.effects),
    next: data.get(#next, or: $value.next),
  );

  @override
  EffectNodeCopyWith<$R2, EffectNode, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _EffectNodeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ConditionalNodeMapper extends SubClassMapperBase<ConditionalNode> {
  ConditionalNodeMapper._();

  static ConditionalNodeMapper? _instance;
  static ConditionalNodeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ConditionalNodeMapper._());
      DialogNodeMapper.ensureInitialized().addSubMapper(_instance!);
      DialogConditionMapper.ensureInitialized();
      DialogNodeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ConditionalNode';

  static String _$id(ConditionalNode v) => v.id;
  static const Field<ConditionalNode, String> _f$id = Field('id', _$id);
  static DialogCondition _$condition(ConditionalNode v) => v.condition;
  static const Field<ConditionalNode, DialogCondition> _f$condition = Field(
    'condition',
    _$condition,
  );
  static DialogNode _$onPass(ConditionalNode v) => v.onPass;
  static const Field<ConditionalNode, DialogNode> _f$onPass = Field(
    'onPass',
    _$onPass,
  );
  static DialogNode _$onFail(ConditionalNode v) => v.onFail;
  static const Field<ConditionalNode, DialogNode> _f$onFail = Field(
    'onFail',
    _$onFail,
  );

  @override
  final MappableFields<ConditionalNode> fields = const {
    #id: _f$id,
    #condition: _f$condition,
    #onPass: _f$onPass,
    #onFail: _f$onFail,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'ConditionalNode';
  @override
  late final ClassMapperBase superMapper = DialogNodeMapper.ensureInitialized();

  static ConditionalNode _instantiate(DecodingData data) {
    return ConditionalNode(
      id: data.dec(_f$id),
      condition: data.dec(_f$condition),
      onPass: data.dec(_f$onPass),
      onFail: data.dec(_f$onFail),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ConditionalNode fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ConditionalNode>(map);
  }

  static ConditionalNode fromJson(String json) {
    return ensureInitialized().decodeJson<ConditionalNode>(json);
  }
}

mixin ConditionalNodeMappable {
  String toJson() {
    return ConditionalNodeMapper.ensureInitialized()
        .encodeJson<ConditionalNode>(this as ConditionalNode);
  }

  Map<String, dynamic> toMap() {
    return ConditionalNodeMapper.ensureInitialized().encodeMap<ConditionalNode>(
      this as ConditionalNode,
    );
  }

  ConditionalNodeCopyWith<ConditionalNode, ConditionalNode, ConditionalNode>
  get copyWith =>
      _ConditionalNodeCopyWithImpl<ConditionalNode, ConditionalNode>(
        this as ConditionalNode,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ConditionalNodeMapper.ensureInitialized().stringifyValue(
      this as ConditionalNode,
    );
  }

  @override
  bool operator ==(Object other) {
    return ConditionalNodeMapper.ensureInitialized().equalsValue(
      this as ConditionalNode,
      other,
    );
  }

  @override
  int get hashCode {
    return ConditionalNodeMapper.ensureInitialized().hashValue(
      this as ConditionalNode,
    );
  }
}

extension ConditionalNodeValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ConditionalNode, $Out> {
  ConditionalNodeCopyWith<$R, ConditionalNode, $Out> get $asConditionalNode =>
      $base.as((v, t, t2) => _ConditionalNodeCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ConditionalNodeCopyWith<$R, $In extends ConditionalNode, $Out>
    implements DialogNodeCopyWith<$R, $In, $Out> {
  DialogNodeCopyWith<$R, DialogNode, DialogNode> get onPass;
  DialogNodeCopyWith<$R, DialogNode, DialogNode> get onFail;
  @override
  $R call({
    String? id,
    DialogCondition? condition,
    DialogNode? onPass,
    DialogNode? onFail,
  });
  ConditionalNodeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ConditionalNodeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ConditionalNode, $Out>
    implements ConditionalNodeCopyWith<$R, ConditionalNode, $Out> {
  _ConditionalNodeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ConditionalNode> $mapper =
      ConditionalNodeMapper.ensureInitialized();
  @override
  DialogNodeCopyWith<$R, DialogNode, DialogNode> get onPass =>
      $value.onPass.copyWith.$chain((v) => call(onPass: v));
  @override
  DialogNodeCopyWith<$R, DialogNode, DialogNode> get onFail =>
      $value.onFail.copyWith.$chain((v) => call(onFail: v));
  @override
  $R call({
    String? id,
    DialogCondition? condition,
    DialogNode? onPass,
    DialogNode? onFail,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (condition != null) #condition: condition,
      if (onPass != null) #onPass: onPass,
      if (onFail != null) #onFail: onFail,
    }),
  );
  @override
  ConditionalNode $make(CopyWithData data) => ConditionalNode(
    id: data.get(#id, or: $value.id),
    condition: data.get(#condition, or: $value.condition),
    onPass: data.get(#onPass, or: $value.onPass),
    onFail: data.get(#onFail, or: $value.onFail),
  );

  @override
  ConditionalNodeCopyWith<$R2, ConditionalNode, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ConditionalNodeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class GotoNodeMapper extends SubClassMapperBase<GotoNode> {
  GotoNodeMapper._();

  static GotoNodeMapper? _instance;
  static GotoNodeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = GotoNodeMapper._());
      DialogNodeMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'GotoNode';

  static String _$id(GotoNode v) => v.id;
  static const Field<GotoNode, String> _f$id = Field('id', _$id);
  static String _$targetId(GotoNode v) => v.targetId;
  static const Field<GotoNode, String> _f$targetId = Field(
    'targetId',
    _$targetId,
  );

  @override
  final MappableFields<GotoNode> fields = const {
    #id: _f$id,
    #targetId: _f$targetId,
  };

  @override
  final String discriminatorKey = '__type';
  @override
  final dynamic discriminatorValue = 'GotoNode';
  @override
  late final ClassMapperBase superMapper = DialogNodeMapper.ensureInitialized();

  static GotoNode _instantiate(DecodingData data) {
    return GotoNode(id: data.dec(_f$id), targetId: data.dec(_f$targetId));
  }

  @override
  final Function instantiate = _instantiate;

  static GotoNode fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<GotoNode>(map);
  }

  static GotoNode fromJson(String json) {
    return ensureInitialized().decodeJson<GotoNode>(json);
  }
}

mixin GotoNodeMappable {
  String toJson() {
    return GotoNodeMapper.ensureInitialized().encodeJson<GotoNode>(
      this as GotoNode,
    );
  }

  Map<String, dynamic> toMap() {
    return GotoNodeMapper.ensureInitialized().encodeMap<GotoNode>(
      this as GotoNode,
    );
  }

  GotoNodeCopyWith<GotoNode, GotoNode, GotoNode> get copyWith =>
      _GotoNodeCopyWithImpl<GotoNode, GotoNode>(
        this as GotoNode,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return GotoNodeMapper.ensureInitialized().stringifyValue(this as GotoNode);
  }

  @override
  bool operator ==(Object other) {
    return GotoNodeMapper.ensureInitialized().equalsValue(
      this as GotoNode,
      other,
    );
  }

  @override
  int get hashCode {
    return GotoNodeMapper.ensureInitialized().hashValue(this as GotoNode);
  }
}

extension GotoNodeValueCopy<$R, $Out> on ObjectCopyWith<$R, GotoNode, $Out> {
  GotoNodeCopyWith<$R, GotoNode, $Out> get $asGotoNode =>
      $base.as((v, t, t2) => _GotoNodeCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class GotoNodeCopyWith<$R, $In extends GotoNode, $Out>
    implements DialogNodeCopyWith<$R, $In, $Out> {
  @override
  $R call({String? id, String? targetId});
  GotoNodeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _GotoNodeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, GotoNode, $Out>
    implements GotoNodeCopyWith<$R, GotoNode, $Out> {
  _GotoNodeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<GotoNode> $mapper =
      GotoNodeMapper.ensureInitialized();
  @override
  $R call({String? id, String? targetId}) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (targetId != null) #targetId: targetId,
    }),
  );
  @override
  GotoNode $make(CopyWithData data) => GotoNode(
    id: data.get(#id, or: $value.id),
    targetId: data.get(#targetId, or: $value.targetId),
  );

  @override
  GotoNodeCopyWith<$R2, GotoNode, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _GotoNodeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

