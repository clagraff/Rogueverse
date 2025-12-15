// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'entity_template.dart';

class EntityTemplateMapper extends ClassMapperBase<EntityTemplate> {
  EntityTemplateMapper._();

  static EntityTemplateMapper? _instance;
  static EntityTemplateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EntityTemplateMapper._());
      ComponentMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'EntityTemplate';

  static int _$id(EntityTemplate v) => v.id;
  static const Field<EntityTemplate, int> _f$id = Field('id', _$id);
  static String _$displayName(EntityTemplate v) => v.displayName;
  static const Field<EntityTemplate, String> _f$displayName = Field(
    'displayName',
    _$displayName,
  );
  static List<Component> _$components(EntityTemplate v) => v.components;
  static const Field<EntityTemplate, List<Component>> _f$components = Field(
    'components',
    _$components,
    hook: ComponentListHook(),
  );

  @override
  final MappableFields<EntityTemplate> fields = const {
    #id: _f$id,
    #displayName: _f$displayName,
    #components: _f$components,
  };

  static EntityTemplate _instantiate(DecodingData data) {
    return EntityTemplate(
      id: data.dec(_f$id),
      displayName: data.dec(_f$displayName),
      components: data.dec(_f$components),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static EntityTemplate fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EntityTemplate>(map);
  }

  static EntityTemplate fromJson(String json) {
    return ensureInitialized().decodeJson<EntityTemplate>(json);
  }
}

mixin EntityTemplateMappable {
  String toJson() {
    return EntityTemplateMapper.ensureInitialized().encodeJson<EntityTemplate>(
      this as EntityTemplate,
    );
  }

  Map<String, dynamic> toMap() {
    return EntityTemplateMapper.ensureInitialized().encodeMap<EntityTemplate>(
      this as EntityTemplate,
    );
  }

  EntityTemplateCopyWith<EntityTemplate, EntityTemplate, EntityTemplate>
  get copyWith => _EntityTemplateCopyWithImpl<EntityTemplate, EntityTemplate>(
    this as EntityTemplate,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return EntityTemplateMapper.ensureInitialized().stringifyValue(
      this as EntityTemplate,
    );
  }

  @override
  bool operator ==(Object other) {
    return EntityTemplateMapper.ensureInitialized().equalsValue(
      this as EntityTemplate,
      other,
    );
  }

  @override
  int get hashCode {
    return EntityTemplateMapper.ensureInitialized().hashValue(
      this as EntityTemplate,
    );
  }
}

extension EntityTemplateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EntityTemplate, $Out> {
  EntityTemplateCopyWith<$R, EntityTemplate, $Out> get $asEntityTemplate =>
      $base.as((v, t, t2) => _EntityTemplateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class EntityTemplateCopyWith<$R, $In extends EntityTemplate, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Component, ObjectCopyWith<$R, Component, Component>>
  get components;
  $R call({int? id, String? displayName, List<Component>? components});
  EntityTemplateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _EntityTemplateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EntityTemplate, $Out>
    implements EntityTemplateCopyWith<$R, EntityTemplate, $Out> {
  _EntityTemplateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EntityTemplate> $mapper =
      EntityTemplateMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Component, ObjectCopyWith<$R, Component, Component>>
  get components => ListCopyWith(
    $value.components,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(components: v),
  );
  @override
  $R call({int? id, String? displayName, List<Component>? components}) =>
      $apply(
        FieldCopyWithData({
          if (id != null) #id: id,
          if (displayName != null) #displayName: displayName,
          if (components != null) #components: components,
        }),
      );
  @override
  EntityTemplate $make(CopyWithData data) => EntityTemplate(
    id: data.get(#id, or: $value.id),
    displayName: data.get(#displayName, or: $value.displayName),
    components: data.get(#components, or: $value.components),
  );

  @override
  EntityTemplateCopyWith<$R2, EntityTemplate, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _EntityTemplateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

