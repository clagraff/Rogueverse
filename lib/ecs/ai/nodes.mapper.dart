// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'nodes.dart';

class NodeMapper extends ClassMapperBase<Node> {
  NodeMapper._();

  static NodeMapper? _instance;
  static NodeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = NodeMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Node';

  @override
  final MappableFields<Node> fields = const {};

  static Node _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('Node');
  }

  @override
  final Function instantiate = _instantiate;

  static Node fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Node>(map);
  }

  static Node fromJson(String json) {
    return ensureInitialized().decodeJson<Node>(json);
  }
}

mixin NodeMappable {
  String toJson();
  Map<String, dynamic> toMap();
  NodeCopyWith<Node, Node, Node> get copyWith;
}

abstract class NodeCopyWith<$R, $In extends Node, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  NodeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

