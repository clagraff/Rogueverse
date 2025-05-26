// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'components.dart';

class CellMapper extends ClassMapperBase<Cell> {
  CellMapper._();

  static CellMapper? _instance;
  static CellMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CellMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Cell';

  static Map<String, Map<int, dynamic>> _$components(Cell v) => v.components;
  static const Field<Cell, Map<String, Map<int, dynamic>>> _f$components =
      Field('components', _$components, opt: true);
  static int _$lastId(Cell v) => v.lastId;
  static const Field<Cell, int> _f$lastId =
      Field('lastId', _$lastId, opt: true);

  @override
  final MappableFields<Cell> fields = const {
    #components: _f$components,
    #lastId: _f$lastId,
  };

  static Cell _instantiate(DecodingData data) {
    return Cell(
        components: data.dec(_f$components), lastId: data.dec(_f$lastId));
  }

  @override
  final Function instantiate = _instantiate;

  static Cell fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Cell>(map);
  }

  static Cell fromJson(String json) {
    return ensureInitialized().decodeJson<Cell>(json);
  }
}

mixin CellMappable {
  String toJson() {
    return CellMapper.ensureInitialized().encodeJson<Cell>(this as Cell);
  }

  Map<String, dynamic> toMap() {
    return CellMapper.ensureInitialized().encodeMap<Cell>(this as Cell);
  }

  CellCopyWith<Cell, Cell, Cell> get copyWith =>
      _CellCopyWithImpl<Cell, Cell>(this as Cell, $identity, $identity);
  @override
  String toString() {
    return CellMapper.ensureInitialized().stringifyValue(this as Cell);
  }

  @override
  bool operator ==(Object other) {
    return CellMapper.ensureInitialized().equalsValue(this as Cell, other);
  }

  @override
  int get hashCode {
    return CellMapper.ensureInitialized().hashValue(this as Cell);
  }
}

extension CellValueCopy<$R, $Out> on ObjectCopyWith<$R, Cell, $Out> {
  CellCopyWith<$R, Cell, $Out> get $asCell =>
      $base.as((v, t, t2) => _CellCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CellCopyWith<$R, $In extends Cell, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, Map<int, dynamic>,
      ObjectCopyWith<$R, Map<int, dynamic>, Map<int, dynamic>>> get components;
  $R call({Map<String, Map<int, dynamic>>? components, int? lastId});
  CellCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CellCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Cell, $Out>
    implements CellCopyWith<$R, Cell, $Out> {
  _CellCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Cell> $mapper = CellMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, Map<int, dynamic>,
          ObjectCopyWith<$R, Map<int, dynamic>, Map<int, dynamic>>>
      get components => MapCopyWith(
          $value.components,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(components: v));
  @override
  $R call({Object? components = $none, Object? lastId = $none}) =>
      $apply(FieldCopyWithData({
        if (components != $none) #components: components,
        if (lastId != $none) #lastId: lastId
      }));
  @override
  Cell $make(CopyWithData data) => Cell(
      components: data.get(#components, or: $value.components),
      lastId: data.get(#lastId, or: $value.lastId));

  @override
  CellCopyWith<$R2, Cell, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _CellCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class NameMapper extends ClassMapperBase<Name> {
  NameMapper._();

  static NameMapper? _instance;
  static NameMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = NameMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Name';

  static String _$name(Name v) => v.name;
  static const Field<Name, String> _f$name = Field('name', _$name);

  @override
  final MappableFields<Name> fields = const {
    #name: _f$name,
  };

  static Name _instantiate(DecodingData data) {
    return Name(name: data.dec(_f$name));
  }

  @override
  final Function instantiate = _instantiate;

  static Name fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Name>(map);
  }

  static Name fromJson(String json) {
    return ensureInitialized().decodeJson<Name>(json);
  }
}

mixin NameMappable {
  String toJson() {
    return NameMapper.ensureInitialized().encodeJson<Name>(this as Name);
  }

  Map<String, dynamic> toMap() {
    return NameMapper.ensureInitialized().encodeMap<Name>(this as Name);
  }

  NameCopyWith<Name, Name, Name> get copyWith =>
      _NameCopyWithImpl<Name, Name>(this as Name, $identity, $identity);
  @override
  String toString() {
    return NameMapper.ensureInitialized().stringifyValue(this as Name);
  }

  @override
  bool operator ==(Object other) {
    return NameMapper.ensureInitialized().equalsValue(this as Name, other);
  }

  @override
  int get hashCode {
    return NameMapper.ensureInitialized().hashValue(this as Name);
  }
}

extension NameValueCopy<$R, $Out> on ObjectCopyWith<$R, Name, $Out> {
  NameCopyWith<$R, Name, $Out> get $asName =>
      $base.as((v, t, t2) => _NameCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class NameCopyWith<$R, $In extends Name, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? name});
  NameCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _NameCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Name, $Out>
    implements NameCopyWith<$R, Name, $Out> {
  _NameCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Name> $mapper = NameMapper.ensureInitialized();
  @override
  $R call({String? name}) =>
      $apply(FieldCopyWithData({if (name != null) #name: name}));
  @override
  Name $make(CopyWithData data) => Name(name: data.get(#name, or: $value.name));

  @override
  NameCopyWith<$R2, Name, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _NameCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class LocalPositionMapper extends ClassMapperBase<LocalPosition> {
  LocalPositionMapper._();

  static LocalPositionMapper? _instance;
  static LocalPositionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = LocalPositionMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'LocalPosition';

  static int _$x(LocalPosition v) => v.x;
  static const Field<LocalPosition, int> _f$x = Field('x', _$x);
  static int _$y(LocalPosition v) => v.y;
  static const Field<LocalPosition, int> _f$y = Field('y', _$y);

  @override
  final MappableFields<LocalPosition> fields = const {
    #x: _f$x,
    #y: _f$y,
  };

  static LocalPosition _instantiate(DecodingData data) {
    return LocalPosition(x: data.dec(_f$x), y: data.dec(_f$y));
  }

  @override
  final Function instantiate = _instantiate;

  static LocalPosition fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<LocalPosition>(map);
  }

  static LocalPosition fromJson(String json) {
    return ensureInitialized().decodeJson<LocalPosition>(json);
  }
}

mixin LocalPositionMappable {
  String toJson() {
    return LocalPositionMapper.ensureInitialized()
        .encodeJson<LocalPosition>(this as LocalPosition);
  }

  Map<String, dynamic> toMap() {
    return LocalPositionMapper.ensureInitialized()
        .encodeMap<LocalPosition>(this as LocalPosition);
  }

  LocalPositionCopyWith<LocalPosition, LocalPosition, LocalPosition>
      get copyWith => _LocalPositionCopyWithImpl<LocalPosition, LocalPosition>(
          this as LocalPosition, $identity, $identity);
  @override
  String toString() {
    return LocalPositionMapper.ensureInitialized()
        .stringifyValue(this as LocalPosition);
  }

  @override
  bool operator ==(Object other) {
    return LocalPositionMapper.ensureInitialized()
        .equalsValue(this as LocalPosition, other);
  }

  @override
  int get hashCode {
    return LocalPositionMapper.ensureInitialized()
        .hashValue(this as LocalPosition);
  }
}

extension LocalPositionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, LocalPosition, $Out> {
  LocalPositionCopyWith<$R, LocalPosition, $Out> get $asLocalPosition =>
      $base.as((v, t, t2) => _LocalPositionCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class LocalPositionCopyWith<$R, $In extends LocalPosition, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({int? x, int? y});
  LocalPositionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _LocalPositionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, LocalPosition, $Out>
    implements LocalPositionCopyWith<$R, LocalPosition, $Out> {
  _LocalPositionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<LocalPosition> $mapper =
      LocalPositionMapper.ensureInitialized();
  @override
  $R call({int? x, int? y}) =>
      $apply(FieldCopyWithData({if (x != null) #x: x, if (y != null) #y: y}));
  @override
  LocalPosition $make(CopyWithData data) => LocalPosition(
      x: data.get(#x, or: $value.x), y: data.get(#y, or: $value.y));

  @override
  LocalPositionCopyWith<$R2, LocalPosition, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _LocalPositionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class MoveByIntentMapper extends ClassMapperBase<MoveByIntent> {
  MoveByIntentMapper._();

  static MoveByIntentMapper? _instance;
  static MoveByIntentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MoveByIntentMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'MoveByIntent';

  static int _$dx(MoveByIntent v) => v.dx;
  static const Field<MoveByIntent, int> _f$dx = Field('dx', _$dx);
  static int _$dy(MoveByIntent v) => v.dy;
  static const Field<MoveByIntent, int> _f$dy = Field('dy', _$dy);

  @override
  final MappableFields<MoveByIntent> fields = const {
    #dx: _f$dx,
    #dy: _f$dy,
  };

  static MoveByIntent _instantiate(DecodingData data) {
    return MoveByIntent(dx: data.dec(_f$dx), dy: data.dec(_f$dy));
  }

  @override
  final Function instantiate = _instantiate;

  static MoveByIntent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MoveByIntent>(map);
  }

  static MoveByIntent fromJson(String json) {
    return ensureInitialized().decodeJson<MoveByIntent>(json);
  }
}

mixin MoveByIntentMappable {
  String toJson() {
    return MoveByIntentMapper.ensureInitialized()
        .encodeJson<MoveByIntent>(this as MoveByIntent);
  }

  Map<String, dynamic> toMap() {
    return MoveByIntentMapper.ensureInitialized()
        .encodeMap<MoveByIntent>(this as MoveByIntent);
  }

  MoveByIntentCopyWith<MoveByIntent, MoveByIntent, MoveByIntent> get copyWith =>
      _MoveByIntentCopyWithImpl<MoveByIntent, MoveByIntent>(
          this as MoveByIntent, $identity, $identity);
  @override
  String toString() {
    return MoveByIntentMapper.ensureInitialized()
        .stringifyValue(this as MoveByIntent);
  }

  @override
  bool operator ==(Object other) {
    return MoveByIntentMapper.ensureInitialized()
        .equalsValue(this as MoveByIntent, other);
  }

  @override
  int get hashCode {
    return MoveByIntentMapper.ensureInitialized()
        .hashValue(this as MoveByIntent);
  }
}

extension MoveByIntentValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MoveByIntent, $Out> {
  MoveByIntentCopyWith<$R, MoveByIntent, $Out> get $asMoveByIntent =>
      $base.as((v, t, t2) => _MoveByIntentCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MoveByIntentCopyWith<$R, $In extends MoveByIntent, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({int? dx, int? dy});
  MoveByIntentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MoveByIntentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MoveByIntent, $Out>
    implements MoveByIntentCopyWith<$R, MoveByIntent, $Out> {
  _MoveByIntentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MoveByIntent> $mapper =
      MoveByIntentMapper.ensureInitialized();
  @override
  $R call({int? dx, int? dy}) => $apply(
      FieldCopyWithData({if (dx != null) #dx: dx, if (dy != null) #dy: dy}));
  @override
  MoveByIntent $make(CopyWithData data) => MoveByIntent(
      dx: data.get(#dx, or: $value.dx), dy: data.get(#dy, or: $value.dy));

  @override
  MoveByIntentCopyWith<$R2, MoveByIntent, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _MoveByIntentCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DidMoveMapper extends ClassMapperBase<DidMove> {
  DidMoveMapper._();

  static DidMoveMapper? _instance;
  static DidMoveMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DidMoveMapper._());
      LocalPositionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DidMove';

  static LocalPosition _$from(DidMove v) => v.from;
  static const Field<DidMove, LocalPosition> _f$from = Field('from', _$from);
  static LocalPosition _$to(DidMove v) => v.to;
  static const Field<DidMove, LocalPosition> _f$to = Field('to', _$to);

  @override
  final MappableFields<DidMove> fields = const {
    #from: _f$from,
    #to: _f$to,
  };

  static DidMove _instantiate(DecodingData data) {
    return DidMove(from: data.dec(_f$from), to: data.dec(_f$to));
  }

  @override
  final Function instantiate = _instantiate;

  static DidMove fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DidMove>(map);
  }

  static DidMove fromJson(String json) {
    return ensureInitialized().decodeJson<DidMove>(json);
  }
}

mixin DidMoveMappable {
  String toJson() {
    return DidMoveMapper.ensureInitialized()
        .encodeJson<DidMove>(this as DidMove);
  }

  Map<String, dynamic> toMap() {
    return DidMoveMapper.ensureInitialized()
        .encodeMap<DidMove>(this as DidMove);
  }

  DidMoveCopyWith<DidMove, DidMove, DidMove> get copyWith =>
      _DidMoveCopyWithImpl<DidMove, DidMove>(
          this as DidMove, $identity, $identity);
  @override
  String toString() {
    return DidMoveMapper.ensureInitialized().stringifyValue(this as DidMove);
  }

  @override
  bool operator ==(Object other) {
    return DidMoveMapper.ensureInitialized()
        .equalsValue(this as DidMove, other);
  }

  @override
  int get hashCode {
    return DidMoveMapper.ensureInitialized().hashValue(this as DidMove);
  }
}

extension DidMoveValueCopy<$R, $Out> on ObjectCopyWith<$R, DidMove, $Out> {
  DidMoveCopyWith<$R, DidMove, $Out> get $asDidMove =>
      $base.as((v, t, t2) => _DidMoveCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DidMoveCopyWith<$R, $In extends DidMove, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  LocalPositionCopyWith<$R, LocalPosition, LocalPosition> get from;
  LocalPositionCopyWith<$R, LocalPosition, LocalPosition> get to;
  $R call({LocalPosition? from, LocalPosition? to});
  DidMoveCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DidMoveCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DidMove, $Out>
    implements DidMoveCopyWith<$R, DidMove, $Out> {
  _DidMoveCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DidMove> $mapper =
      DidMoveMapper.ensureInitialized();
  @override
  LocalPositionCopyWith<$R, LocalPosition, LocalPosition> get from =>
      $value.from.copyWith.$chain((v) => call(from: v));
  @override
  LocalPositionCopyWith<$R, LocalPosition, LocalPosition> get to =>
      $value.to.copyWith.$chain((v) => call(to: v));
  @override
  $R call({LocalPosition? from, LocalPosition? to}) => $apply(FieldCopyWithData(
      {if (from != null) #from: from, if (to != null) #to: to}));
  @override
  DidMove $make(CopyWithData data) => DidMove(
      from: data.get(#from, or: $value.from), to: data.get(#to, or: $value.to));

  @override
  DidMoveCopyWith<$R2, DidMove, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _DidMoveCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class BlocksMovementMapper extends ClassMapperBase<BlocksMovement> {
  BlocksMovementMapper._();

  static BlocksMovementMapper? _instance;
  static BlocksMovementMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = BlocksMovementMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'BlocksMovement';

  @override
  final MappableFields<BlocksMovement> fields = const {};

  static BlocksMovement _instantiate(DecodingData data) {
    return BlocksMovement();
  }

  @override
  final Function instantiate = _instantiate;

  static BlocksMovement fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<BlocksMovement>(map);
  }

  static BlocksMovement fromJson(String json) {
    return ensureInitialized().decodeJson<BlocksMovement>(json);
  }
}

mixin BlocksMovementMappable {
  String toJson() {
    return BlocksMovementMapper.ensureInitialized()
        .encodeJson<BlocksMovement>(this as BlocksMovement);
  }

  Map<String, dynamic> toMap() {
    return BlocksMovementMapper.ensureInitialized()
        .encodeMap<BlocksMovement>(this as BlocksMovement);
  }

  BlocksMovementCopyWith<BlocksMovement, BlocksMovement, BlocksMovement>
      get copyWith =>
          _BlocksMovementCopyWithImpl<BlocksMovement, BlocksMovement>(
              this as BlocksMovement, $identity, $identity);
  @override
  String toString() {
    return BlocksMovementMapper.ensureInitialized()
        .stringifyValue(this as BlocksMovement);
  }

  @override
  bool operator ==(Object other) {
    return BlocksMovementMapper.ensureInitialized()
        .equalsValue(this as BlocksMovement, other);
  }

  @override
  int get hashCode {
    return BlocksMovementMapper.ensureInitialized()
        .hashValue(this as BlocksMovement);
  }
}

extension BlocksMovementValueCopy<$R, $Out>
    on ObjectCopyWith<$R, BlocksMovement, $Out> {
  BlocksMovementCopyWith<$R, BlocksMovement, $Out> get $asBlocksMovement =>
      $base.as((v, t, t2) => _BlocksMovementCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class BlocksMovementCopyWith<$R, $In extends BlocksMovement, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  BlocksMovementCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _BlocksMovementCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, BlocksMovement, $Out>
    implements BlocksMovementCopyWith<$R, BlocksMovement, $Out> {
  _BlocksMovementCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<BlocksMovement> $mapper =
      BlocksMovementMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  BlocksMovement $make(CopyWithData data) => BlocksMovement();

  @override
  BlocksMovementCopyWith<$R2, BlocksMovement, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _BlocksMovementCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class BlockedMoveMapper extends ClassMapperBase<BlockedMove> {
  BlockedMoveMapper._();

  static BlockedMoveMapper? _instance;
  static BlockedMoveMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = BlockedMoveMapper._());
      LocalPositionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'BlockedMove';

  static LocalPosition _$attempted(BlockedMove v) => v.attempted;
  static const Field<BlockedMove, LocalPosition> _f$attempted =
      Field('attempted', _$attempted);

  @override
  final MappableFields<BlockedMove> fields = const {
    #attempted: _f$attempted,
  };

  static BlockedMove _instantiate(DecodingData data) {
    return BlockedMove(data.dec(_f$attempted));
  }

  @override
  final Function instantiate = _instantiate;

  static BlockedMove fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<BlockedMove>(map);
  }

  static BlockedMove fromJson(String json) {
    return ensureInitialized().decodeJson<BlockedMove>(json);
  }
}

mixin BlockedMoveMappable {
  String toJson() {
    return BlockedMoveMapper.ensureInitialized()
        .encodeJson<BlockedMove>(this as BlockedMove);
  }

  Map<String, dynamic> toMap() {
    return BlockedMoveMapper.ensureInitialized()
        .encodeMap<BlockedMove>(this as BlockedMove);
  }

  BlockedMoveCopyWith<BlockedMove, BlockedMove, BlockedMove> get copyWith =>
      _BlockedMoveCopyWithImpl<BlockedMove, BlockedMove>(
          this as BlockedMove, $identity, $identity);
  @override
  String toString() {
    return BlockedMoveMapper.ensureInitialized()
        .stringifyValue(this as BlockedMove);
  }

  @override
  bool operator ==(Object other) {
    return BlockedMoveMapper.ensureInitialized()
        .equalsValue(this as BlockedMove, other);
  }

  @override
  int get hashCode {
    return BlockedMoveMapper.ensureInitialized().hashValue(this as BlockedMove);
  }
}

extension BlockedMoveValueCopy<$R, $Out>
    on ObjectCopyWith<$R, BlockedMove, $Out> {
  BlockedMoveCopyWith<$R, BlockedMove, $Out> get $asBlockedMove =>
      $base.as((v, t, t2) => _BlockedMoveCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class BlockedMoveCopyWith<$R, $In extends BlockedMove, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  LocalPositionCopyWith<$R, LocalPosition, LocalPosition> get attempted;
  $R call({LocalPosition? attempted});
  BlockedMoveCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _BlockedMoveCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, BlockedMove, $Out>
    implements BlockedMoveCopyWith<$R, BlockedMove, $Out> {
  _BlockedMoveCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<BlockedMove> $mapper =
      BlockedMoveMapper.ensureInitialized();
  @override
  LocalPositionCopyWith<$R, LocalPosition, LocalPosition> get attempted =>
      $value.attempted.copyWith.$chain((v) => call(attempted: v));
  @override
  $R call({LocalPosition? attempted}) =>
      $apply(FieldCopyWithData({if (attempted != null) #attempted: attempted}));
  @override
  BlockedMove $make(CopyWithData data) =>
      BlockedMove(data.get(#attempted, or: $value.attempted));

  @override
  BlockedMoveCopyWith<$R2, BlockedMove, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _BlockedMoveCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class PlayerControlledMapper extends ClassMapperBase<PlayerControlled> {
  PlayerControlledMapper._();

  static PlayerControlledMapper? _instance;
  static PlayerControlledMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PlayerControlledMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'PlayerControlled';

  @override
  final MappableFields<PlayerControlled> fields = const {};

  static PlayerControlled _instantiate(DecodingData data) {
    return PlayerControlled();
  }

  @override
  final Function instantiate = _instantiate;

  static PlayerControlled fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PlayerControlled>(map);
  }

  static PlayerControlled fromJson(String json) {
    return ensureInitialized().decodeJson<PlayerControlled>(json);
  }
}

mixin PlayerControlledMappable {
  String toJson() {
    return PlayerControlledMapper.ensureInitialized()
        .encodeJson<PlayerControlled>(this as PlayerControlled);
  }

  Map<String, dynamic> toMap() {
    return PlayerControlledMapper.ensureInitialized()
        .encodeMap<PlayerControlled>(this as PlayerControlled);
  }

  PlayerControlledCopyWith<PlayerControlled, PlayerControlled, PlayerControlled>
      get copyWith =>
          _PlayerControlledCopyWithImpl<PlayerControlled, PlayerControlled>(
              this as PlayerControlled, $identity, $identity);
  @override
  String toString() {
    return PlayerControlledMapper.ensureInitialized()
        .stringifyValue(this as PlayerControlled);
  }

  @override
  bool operator ==(Object other) {
    return PlayerControlledMapper.ensureInitialized()
        .equalsValue(this as PlayerControlled, other);
  }

  @override
  int get hashCode {
    return PlayerControlledMapper.ensureInitialized()
        .hashValue(this as PlayerControlled);
  }
}

extension PlayerControlledValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PlayerControlled, $Out> {
  PlayerControlledCopyWith<$R, PlayerControlled, $Out>
      get $asPlayerControlled => $base
          .as((v, t, t2) => _PlayerControlledCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PlayerControlledCopyWith<$R, $In extends PlayerControlled, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  PlayerControlledCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _PlayerControlledCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PlayerControlled, $Out>
    implements PlayerControlledCopyWith<$R, PlayerControlled, $Out> {
  _PlayerControlledCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PlayerControlled> $mapper =
      PlayerControlledMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  PlayerControlled $make(CopyWithData data) => PlayerControlled();

  @override
  PlayerControlledCopyWith<$R2, PlayerControlled, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _PlayerControlledCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class AiControlledMapper extends ClassMapperBase<AiControlled> {
  AiControlledMapper._();

  static AiControlledMapper? _instance;
  static AiControlledMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AiControlledMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'AiControlled';

  @override
  final MappableFields<AiControlled> fields = const {};

  static AiControlled _instantiate(DecodingData data) {
    return AiControlled();
  }

  @override
  final Function instantiate = _instantiate;

  static AiControlled fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AiControlled>(map);
  }

  static AiControlled fromJson(String json) {
    return ensureInitialized().decodeJson<AiControlled>(json);
  }
}

mixin AiControlledMappable {
  String toJson() {
    return AiControlledMapper.ensureInitialized()
        .encodeJson<AiControlled>(this as AiControlled);
  }

  Map<String, dynamic> toMap() {
    return AiControlledMapper.ensureInitialized()
        .encodeMap<AiControlled>(this as AiControlled);
  }

  AiControlledCopyWith<AiControlled, AiControlled, AiControlled> get copyWith =>
      _AiControlledCopyWithImpl<AiControlled, AiControlled>(
          this as AiControlled, $identity, $identity);
  @override
  String toString() {
    return AiControlledMapper.ensureInitialized()
        .stringifyValue(this as AiControlled);
  }

  @override
  bool operator ==(Object other) {
    return AiControlledMapper.ensureInitialized()
        .equalsValue(this as AiControlled, other);
  }

  @override
  int get hashCode {
    return AiControlledMapper.ensureInitialized()
        .hashValue(this as AiControlled);
  }
}

extension AiControlledValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AiControlled, $Out> {
  AiControlledCopyWith<$R, AiControlled, $Out> get $asAiControlled =>
      $base.as((v, t, t2) => _AiControlledCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AiControlledCopyWith<$R, $In extends AiControlled, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  AiControlledCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AiControlledCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AiControlled, $Out>
    implements AiControlledCopyWith<$R, AiControlled, $Out> {
  _AiControlledCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AiControlled> $mapper =
      AiControlledMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  AiControlled $make(CopyWithData data) => AiControlled();

  @override
  AiControlledCopyWith<$R2, AiControlled, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _AiControlledCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class RenderableMapper extends ClassMapperBase<Renderable> {
  RenderableMapper._();

  static RenderableMapper? _instance;
  static RenderableMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RenderableMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Renderable';

  static String _$svgAssetPath(Renderable v) => v.svgAssetPath;
  static const Field<Renderable, String> _f$svgAssetPath =
      Field('svgAssetPath', _$svgAssetPath);

  @override
  final MappableFields<Renderable> fields = const {
    #svgAssetPath: _f$svgAssetPath,
  };

  static Renderable _instantiate(DecodingData data) {
    return Renderable(data.dec(_f$svgAssetPath));
  }

  @override
  final Function instantiate = _instantiate;

  static Renderable fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Renderable>(map);
  }

  static Renderable fromJson(String json) {
    return ensureInitialized().decodeJson<Renderable>(json);
  }
}

mixin RenderableMappable {
  String toJson() {
    return RenderableMapper.ensureInitialized()
        .encodeJson<Renderable>(this as Renderable);
  }

  Map<String, dynamic> toMap() {
    return RenderableMapper.ensureInitialized()
        .encodeMap<Renderable>(this as Renderable);
  }

  RenderableCopyWith<Renderable, Renderable, Renderable> get copyWith =>
      _RenderableCopyWithImpl<Renderable, Renderable>(
          this as Renderable, $identity, $identity);
  @override
  String toString() {
    return RenderableMapper.ensureInitialized()
        .stringifyValue(this as Renderable);
  }

  @override
  bool operator ==(Object other) {
    return RenderableMapper.ensureInitialized()
        .equalsValue(this as Renderable, other);
  }

  @override
  int get hashCode {
    return RenderableMapper.ensureInitialized().hashValue(this as Renderable);
  }
}

extension RenderableValueCopy<$R, $Out>
    on ObjectCopyWith<$R, Renderable, $Out> {
  RenderableCopyWith<$R, Renderable, $Out> get $asRenderable =>
      $base.as((v, t, t2) => _RenderableCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class RenderableCopyWith<$R, $In extends Renderable, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? svgAssetPath});
  RenderableCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _RenderableCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Renderable, $Out>
    implements RenderableCopyWith<$R, Renderable, $Out> {
  _RenderableCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Renderable> $mapper =
      RenderableMapper.ensureInitialized();
  @override
  $R call({String? svgAssetPath}) => $apply(FieldCopyWithData(
      {if (svgAssetPath != null) #svgAssetPath: svgAssetPath}));
  @override
  Renderable $make(CopyWithData data) =>
      Renderable(data.get(#svgAssetPath, or: $value.svgAssetPath));

  @override
  RenderableCopyWith<$R2, Renderable, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _RenderableCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class HealthMapper extends ClassMapperBase<Health> {
  HealthMapper._();

  static HealthMapper? _instance;
  static HealthMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = HealthMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Health';

  static int _$current(Health v) => v.current;
  static const Field<Health, int> _f$current = Field('current', _$current);
  static int _$max(Health v) => v.max;
  static const Field<Health, int> _f$max = Field('max', _$max);

  @override
  final MappableFields<Health> fields = const {
    #current: _f$current,
    #max: _f$max,
  };

  static Health _instantiate(DecodingData data) {
    return Health(data.dec(_f$current), data.dec(_f$max));
  }

  @override
  final Function instantiate = _instantiate;

  static Health fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Health>(map);
  }

  static Health fromJson(String json) {
    return ensureInitialized().decodeJson<Health>(json);
  }
}

mixin HealthMappable {
  String toJson() {
    return HealthMapper.ensureInitialized().encodeJson<Health>(this as Health);
  }

  Map<String, dynamic> toMap() {
    return HealthMapper.ensureInitialized().encodeMap<Health>(this as Health);
  }

  HealthCopyWith<Health, Health, Health> get copyWith =>
      _HealthCopyWithImpl<Health, Health>(this as Health, $identity, $identity);
  @override
  String toString() {
    return HealthMapper.ensureInitialized().stringifyValue(this as Health);
  }

  @override
  bool operator ==(Object other) {
    return HealthMapper.ensureInitialized().equalsValue(this as Health, other);
  }

  @override
  int get hashCode {
    return HealthMapper.ensureInitialized().hashValue(this as Health);
  }
}

extension HealthValueCopy<$R, $Out> on ObjectCopyWith<$R, Health, $Out> {
  HealthCopyWith<$R, Health, $Out> get $asHealth =>
      $base.as((v, t, t2) => _HealthCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class HealthCopyWith<$R, $In extends Health, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({int? current, int? max});
  HealthCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _HealthCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Health, $Out>
    implements HealthCopyWith<$R, Health, $Out> {
  _HealthCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Health> $mapper = HealthMapper.ensureInitialized();
  @override
  $R call({int? current, int? max}) => $apply(FieldCopyWithData(
      {if (current != null) #current: current, if (max != null) #max: max}));
  @override
  Health $make(CopyWithData data) => Health(
      data.get(#current, or: $value.current), data.get(#max, or: $value.max));

  @override
  HealthCopyWith<$R2, Health, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _HealthCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class AttackIntentMapper extends ClassMapperBase<AttackIntent> {
  AttackIntentMapper._();

  static AttackIntentMapper? _instance;
  static AttackIntentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AttackIntentMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'AttackIntent';

  static int _$targetId(AttackIntent v) => v.targetId;
  static const Field<AttackIntent, int> _f$targetId =
      Field('targetId', _$targetId);

  @override
  final MappableFields<AttackIntent> fields = const {
    #targetId: _f$targetId,
  };

  static AttackIntent _instantiate(DecodingData data) {
    return AttackIntent(data.dec(_f$targetId));
  }

  @override
  final Function instantiate = _instantiate;

  static AttackIntent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AttackIntent>(map);
  }

  static AttackIntent fromJson(String json) {
    return ensureInitialized().decodeJson<AttackIntent>(json);
  }
}

mixin AttackIntentMappable {
  String toJson() {
    return AttackIntentMapper.ensureInitialized()
        .encodeJson<AttackIntent>(this as AttackIntent);
  }

  Map<String, dynamic> toMap() {
    return AttackIntentMapper.ensureInitialized()
        .encodeMap<AttackIntent>(this as AttackIntent);
  }

  AttackIntentCopyWith<AttackIntent, AttackIntent, AttackIntent> get copyWith =>
      _AttackIntentCopyWithImpl<AttackIntent, AttackIntent>(
          this as AttackIntent, $identity, $identity);
  @override
  String toString() {
    return AttackIntentMapper.ensureInitialized()
        .stringifyValue(this as AttackIntent);
  }

  @override
  bool operator ==(Object other) {
    return AttackIntentMapper.ensureInitialized()
        .equalsValue(this as AttackIntent, other);
  }

  @override
  int get hashCode {
    return AttackIntentMapper.ensureInitialized()
        .hashValue(this as AttackIntent);
  }
}

extension AttackIntentValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AttackIntent, $Out> {
  AttackIntentCopyWith<$R, AttackIntent, $Out> get $asAttackIntent =>
      $base.as((v, t, t2) => _AttackIntentCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AttackIntentCopyWith<$R, $In extends AttackIntent, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({int? targetId});
  AttackIntentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AttackIntentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AttackIntent, $Out>
    implements AttackIntentCopyWith<$R, AttackIntent, $Out> {
  _AttackIntentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AttackIntent> $mapper =
      AttackIntentMapper.ensureInitialized();
  @override
  $R call({int? targetId}) =>
      $apply(FieldCopyWithData({if (targetId != null) #targetId: targetId}));
  @override
  AttackIntent $make(CopyWithData data) =>
      AttackIntent(data.get(#targetId, or: $value.targetId));

  @override
  AttackIntentCopyWith<$R2, AttackIntent, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _AttackIntentCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DidAttackMapper extends ClassMapperBase<DidAttack> {
  DidAttackMapper._();

  static DidAttackMapper? _instance;
  static DidAttackMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DidAttackMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'DidAttack';

  static int _$targetId(DidAttack v) => v.targetId;
  static const Field<DidAttack, int> _f$targetId =
      Field('targetId', _$targetId);
  static int _$damage(DidAttack v) => v.damage;
  static const Field<DidAttack, int> _f$damage = Field('damage', _$damage);

  @override
  final MappableFields<DidAttack> fields = const {
    #targetId: _f$targetId,
    #damage: _f$damage,
  };

  static DidAttack _instantiate(DecodingData data) {
    return DidAttack(
        targetId: data.dec(_f$targetId), damage: data.dec(_f$damage));
  }

  @override
  final Function instantiate = _instantiate;

  static DidAttack fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DidAttack>(map);
  }

  static DidAttack fromJson(String json) {
    return ensureInitialized().decodeJson<DidAttack>(json);
  }
}

mixin DidAttackMappable {
  String toJson() {
    return DidAttackMapper.ensureInitialized()
        .encodeJson<DidAttack>(this as DidAttack);
  }

  Map<String, dynamic> toMap() {
    return DidAttackMapper.ensureInitialized()
        .encodeMap<DidAttack>(this as DidAttack);
  }

  DidAttackCopyWith<DidAttack, DidAttack, DidAttack> get copyWith =>
      _DidAttackCopyWithImpl<DidAttack, DidAttack>(
          this as DidAttack, $identity, $identity);
  @override
  String toString() {
    return DidAttackMapper.ensureInitialized()
        .stringifyValue(this as DidAttack);
  }

  @override
  bool operator ==(Object other) {
    return DidAttackMapper.ensureInitialized()
        .equalsValue(this as DidAttack, other);
  }

  @override
  int get hashCode {
    return DidAttackMapper.ensureInitialized().hashValue(this as DidAttack);
  }
}

extension DidAttackValueCopy<$R, $Out> on ObjectCopyWith<$R, DidAttack, $Out> {
  DidAttackCopyWith<$R, DidAttack, $Out> get $asDidAttack =>
      $base.as((v, t, t2) => _DidAttackCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DidAttackCopyWith<$R, $In extends DidAttack, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({int? targetId, int? damage});
  DidAttackCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DidAttackCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DidAttack, $Out>
    implements DidAttackCopyWith<$R, DidAttack, $Out> {
  _DidAttackCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DidAttack> $mapper =
      DidAttackMapper.ensureInitialized();
  @override
  $R call({int? targetId, int? damage}) => $apply(FieldCopyWithData({
        if (targetId != null) #targetId: targetId,
        if (damage != null) #damage: damage
      }));
  @override
  DidAttack $make(CopyWithData data) => DidAttack(
      targetId: data.get(#targetId, or: $value.targetId),
      damage: data.get(#damage, or: $value.damage));

  @override
  DidAttackCopyWith<$R2, DidAttack, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _DidAttackCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class WasAttackedMapper extends ClassMapperBase<WasAttacked> {
  WasAttackedMapper._();

  static WasAttackedMapper? _instance;
  static WasAttackedMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = WasAttackedMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'WasAttacked';

  static int _$sourceId(WasAttacked v) => v.sourceId;
  static const Field<WasAttacked, int> _f$sourceId =
      Field('sourceId', _$sourceId);
  static int _$damage(WasAttacked v) => v.damage;
  static const Field<WasAttacked, int> _f$damage = Field('damage', _$damage);

  @override
  final MappableFields<WasAttacked> fields = const {
    #sourceId: _f$sourceId,
    #damage: _f$damage,
  };

  static WasAttacked _instantiate(DecodingData data) {
    return WasAttacked(
        sourceId: data.dec(_f$sourceId), damage: data.dec(_f$damage));
  }

  @override
  final Function instantiate = _instantiate;

  static WasAttacked fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<WasAttacked>(map);
  }

  static WasAttacked fromJson(String json) {
    return ensureInitialized().decodeJson<WasAttacked>(json);
  }
}

mixin WasAttackedMappable {
  String toJson() {
    return WasAttackedMapper.ensureInitialized()
        .encodeJson<WasAttacked>(this as WasAttacked);
  }

  Map<String, dynamic> toMap() {
    return WasAttackedMapper.ensureInitialized()
        .encodeMap<WasAttacked>(this as WasAttacked);
  }

  WasAttackedCopyWith<WasAttacked, WasAttacked, WasAttacked> get copyWith =>
      _WasAttackedCopyWithImpl<WasAttacked, WasAttacked>(
          this as WasAttacked, $identity, $identity);
  @override
  String toString() {
    return WasAttackedMapper.ensureInitialized()
        .stringifyValue(this as WasAttacked);
  }

  @override
  bool operator ==(Object other) {
    return WasAttackedMapper.ensureInitialized()
        .equalsValue(this as WasAttacked, other);
  }

  @override
  int get hashCode {
    return WasAttackedMapper.ensureInitialized().hashValue(this as WasAttacked);
  }
}

extension WasAttackedValueCopy<$R, $Out>
    on ObjectCopyWith<$R, WasAttacked, $Out> {
  WasAttackedCopyWith<$R, WasAttacked, $Out> get $asWasAttacked =>
      $base.as((v, t, t2) => _WasAttackedCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class WasAttackedCopyWith<$R, $In extends WasAttacked, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({int? sourceId, int? damage});
  WasAttackedCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _WasAttackedCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, WasAttacked, $Out>
    implements WasAttackedCopyWith<$R, WasAttacked, $Out> {
  _WasAttackedCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<WasAttacked> $mapper =
      WasAttackedMapper.ensureInitialized();
  @override
  $R call({int? sourceId, int? damage}) => $apply(FieldCopyWithData({
        if (sourceId != null) #sourceId: sourceId,
        if (damage != null) #damage: damage
      }));
  @override
  WasAttacked $make(CopyWithData data) => WasAttacked(
      sourceId: data.get(#sourceId, or: $value.sourceId),
      damage: data.get(#damage, or: $value.damage));

  @override
  WasAttackedCopyWith<$R2, WasAttacked, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _WasAttackedCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DeadMapper extends ClassMapperBase<Dead> {
  DeadMapper._();

  static DeadMapper? _instance;
  static DeadMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DeadMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Dead';

  @override
  final MappableFields<Dead> fields = const {};

  static Dead _instantiate(DecodingData data) {
    return Dead();
  }

  @override
  final Function instantiate = _instantiate;

  static Dead fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Dead>(map);
  }

  static Dead fromJson(String json) {
    return ensureInitialized().decodeJson<Dead>(json);
  }
}

mixin DeadMappable {
  String toJson() {
    return DeadMapper.ensureInitialized().encodeJson<Dead>(this as Dead);
  }

  Map<String, dynamic> toMap() {
    return DeadMapper.ensureInitialized().encodeMap<Dead>(this as Dead);
  }

  DeadCopyWith<Dead, Dead, Dead> get copyWith =>
      _DeadCopyWithImpl<Dead, Dead>(this as Dead, $identity, $identity);
  @override
  String toString() {
    return DeadMapper.ensureInitialized().stringifyValue(this as Dead);
  }

  @override
  bool operator ==(Object other) {
    return DeadMapper.ensureInitialized().equalsValue(this as Dead, other);
  }

  @override
  int get hashCode {
    return DeadMapper.ensureInitialized().hashValue(this as Dead);
  }
}

extension DeadValueCopy<$R, $Out> on ObjectCopyWith<$R, Dead, $Out> {
  DeadCopyWith<$R, Dead, $Out> get $asDead =>
      $base.as((v, t, t2) => _DeadCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DeadCopyWith<$R, $In extends Dead, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  DeadCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DeadCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Dead, $Out>
    implements DeadCopyWith<$R, Dead, $Out> {
  _DeadCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Dead> $mapper = DeadMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  Dead $make(CopyWithData data) => Dead();

  @override
  DeadCopyWith<$R2, Dead, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _DeadCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class InventoryMapper extends ClassMapperBase<Inventory> {
  InventoryMapper._();

  static InventoryMapper? _instance;
  static InventoryMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = InventoryMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Inventory';

  static List<int> _$items(Inventory v) => v.items;
  static const Field<Inventory, List<int>> _f$items = Field('items', _$items);

  @override
  final MappableFields<Inventory> fields = const {
    #items: _f$items,
  };

  static Inventory _instantiate(DecodingData data) {
    return Inventory(data.dec(_f$items));
  }

  @override
  final Function instantiate = _instantiate;

  static Inventory fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Inventory>(map);
  }

  static Inventory fromJson(String json) {
    return ensureInitialized().decodeJson<Inventory>(json);
  }
}

mixin InventoryMappable {
  String toJson() {
    return InventoryMapper.ensureInitialized()
        .encodeJson<Inventory>(this as Inventory);
  }

  Map<String, dynamic> toMap() {
    return InventoryMapper.ensureInitialized()
        .encodeMap<Inventory>(this as Inventory);
  }

  InventoryCopyWith<Inventory, Inventory, Inventory> get copyWith =>
      _InventoryCopyWithImpl<Inventory, Inventory>(
          this as Inventory, $identity, $identity);
  @override
  String toString() {
    return InventoryMapper.ensureInitialized()
        .stringifyValue(this as Inventory);
  }

  @override
  bool operator ==(Object other) {
    return InventoryMapper.ensureInitialized()
        .equalsValue(this as Inventory, other);
  }

  @override
  int get hashCode {
    return InventoryMapper.ensureInitialized().hashValue(this as Inventory);
  }
}

extension InventoryValueCopy<$R, $Out> on ObjectCopyWith<$R, Inventory, $Out> {
  InventoryCopyWith<$R, Inventory, $Out> get $asInventory =>
      $base.as((v, t, t2) => _InventoryCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class InventoryCopyWith<$R, $In extends Inventory, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, int, ObjectCopyWith<$R, int, int>> get items;
  $R call({List<int>? items});
  InventoryCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _InventoryCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Inventory, $Out>
    implements InventoryCopyWith<$R, Inventory, $Out> {
  _InventoryCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Inventory> $mapper =
      InventoryMapper.ensureInitialized();
  @override
  ListCopyWith<$R, int, ObjectCopyWith<$R, int, int>> get items => ListCopyWith(
      $value.items,
      (v, t) => ObjectCopyWith(v, $identity, t),
      (v) => call(items: v));
  @override
  $R call({List<int>? items}) =>
      $apply(FieldCopyWithData({if (items != null) #items: items}));
  @override
  Inventory $make(CopyWithData data) =>
      Inventory(data.get(#items, or: $value.items));

  @override
  InventoryCopyWith<$R2, Inventory, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _InventoryCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class InventoryMaxCountMapper extends ClassMapperBase<InventoryMaxCount> {
  InventoryMaxCountMapper._();

  static InventoryMaxCountMapper? _instance;
  static InventoryMaxCountMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = InventoryMaxCountMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'InventoryMaxCount';

  static int _$maxAmount(InventoryMaxCount v) => v.maxAmount;
  static const Field<InventoryMaxCount, int> _f$maxAmount =
      Field('maxAmount', _$maxAmount);

  @override
  final MappableFields<InventoryMaxCount> fields = const {
    #maxAmount: _f$maxAmount,
  };

  static InventoryMaxCount _instantiate(DecodingData data) {
    return InventoryMaxCount(data.dec(_f$maxAmount));
  }

  @override
  final Function instantiate = _instantiate;

  static InventoryMaxCount fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<InventoryMaxCount>(map);
  }

  static InventoryMaxCount fromJson(String json) {
    return ensureInitialized().decodeJson<InventoryMaxCount>(json);
  }
}

mixin InventoryMaxCountMappable {
  String toJson() {
    return InventoryMaxCountMapper.ensureInitialized()
        .encodeJson<InventoryMaxCount>(this as InventoryMaxCount);
  }

  Map<String, dynamic> toMap() {
    return InventoryMaxCountMapper.ensureInitialized()
        .encodeMap<InventoryMaxCount>(this as InventoryMaxCount);
  }

  InventoryMaxCountCopyWith<InventoryMaxCount, InventoryMaxCount,
          InventoryMaxCount>
      get copyWith =>
          _InventoryMaxCountCopyWithImpl<InventoryMaxCount, InventoryMaxCount>(
              this as InventoryMaxCount, $identity, $identity);
  @override
  String toString() {
    return InventoryMaxCountMapper.ensureInitialized()
        .stringifyValue(this as InventoryMaxCount);
  }

  @override
  bool operator ==(Object other) {
    return InventoryMaxCountMapper.ensureInitialized()
        .equalsValue(this as InventoryMaxCount, other);
  }

  @override
  int get hashCode {
    return InventoryMaxCountMapper.ensureInitialized()
        .hashValue(this as InventoryMaxCount);
  }
}

extension InventoryMaxCountValueCopy<$R, $Out>
    on ObjectCopyWith<$R, InventoryMaxCount, $Out> {
  InventoryMaxCountCopyWith<$R, InventoryMaxCount, $Out>
      get $asInventoryMaxCount => $base
          .as((v, t, t2) => _InventoryMaxCountCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class InventoryMaxCountCopyWith<$R, $In extends InventoryMaxCount,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call({int? maxAmount});
  InventoryMaxCountCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _InventoryMaxCountCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, InventoryMaxCount, $Out>
    implements InventoryMaxCountCopyWith<$R, InventoryMaxCount, $Out> {
  _InventoryMaxCountCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<InventoryMaxCount> $mapper =
      InventoryMaxCountMapper.ensureInitialized();
  @override
  $R call({int? maxAmount}) =>
      $apply(FieldCopyWithData({if (maxAmount != null) #maxAmount: maxAmount}));
  @override
  InventoryMaxCount $make(CopyWithData data) =>
      InventoryMaxCount(data.get(#maxAmount, or: $value.maxAmount));

  @override
  InventoryMaxCountCopyWith<$R2, InventoryMaxCount, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _InventoryMaxCountCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class InventoryFullFailureMapper extends ClassMapperBase<InventoryFullFailure> {
  InventoryFullFailureMapper._();

  static InventoryFullFailureMapper? _instance;
  static InventoryFullFailureMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = InventoryFullFailureMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'InventoryFullFailure';

  static int _$targetEntityId(InventoryFullFailure v) => v.targetEntityId;
  static const Field<InventoryFullFailure, int> _f$targetEntityId =
      Field('targetEntityId', _$targetEntityId);

  @override
  final MappableFields<InventoryFullFailure> fields = const {
    #targetEntityId: _f$targetEntityId,
  };

  static InventoryFullFailure _instantiate(DecodingData data) {
    return InventoryFullFailure(data.dec(_f$targetEntityId));
  }

  @override
  final Function instantiate = _instantiate;

  static InventoryFullFailure fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<InventoryFullFailure>(map);
  }

  static InventoryFullFailure fromJson(String json) {
    return ensureInitialized().decodeJson<InventoryFullFailure>(json);
  }
}

mixin InventoryFullFailureMappable {
  String toJson() {
    return InventoryFullFailureMapper.ensureInitialized()
        .encodeJson<InventoryFullFailure>(this as InventoryFullFailure);
  }

  Map<String, dynamic> toMap() {
    return InventoryFullFailureMapper.ensureInitialized()
        .encodeMap<InventoryFullFailure>(this as InventoryFullFailure);
  }

  InventoryFullFailureCopyWith<InventoryFullFailure, InventoryFullFailure,
      InventoryFullFailure> get copyWith => _InventoryFullFailureCopyWithImpl<
          InventoryFullFailure, InventoryFullFailure>(
      this as InventoryFullFailure, $identity, $identity);
  @override
  String toString() {
    return InventoryFullFailureMapper.ensureInitialized()
        .stringifyValue(this as InventoryFullFailure);
  }

  @override
  bool operator ==(Object other) {
    return InventoryFullFailureMapper.ensureInitialized()
        .equalsValue(this as InventoryFullFailure, other);
  }

  @override
  int get hashCode {
    return InventoryFullFailureMapper.ensureInitialized()
        .hashValue(this as InventoryFullFailure);
  }
}

extension InventoryFullFailureValueCopy<$R, $Out>
    on ObjectCopyWith<$R, InventoryFullFailure, $Out> {
  InventoryFullFailureCopyWith<$R, InventoryFullFailure, $Out>
      get $asInventoryFullFailure => $base.as(
          (v, t, t2) => _InventoryFullFailureCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class InventoryFullFailureCopyWith<
    $R,
    $In extends InventoryFullFailure,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call({int? targetEntityId});
  InventoryFullFailureCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _InventoryFullFailureCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, InventoryFullFailure, $Out>
    implements InventoryFullFailureCopyWith<$R, InventoryFullFailure, $Out> {
  _InventoryFullFailureCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<InventoryFullFailure> $mapper =
      InventoryFullFailureMapper.ensureInitialized();
  @override
  $R call({int? targetEntityId}) => $apply(FieldCopyWithData(
      {if (targetEntityId != null) #targetEntityId: targetEntityId}));
  @override
  InventoryFullFailure $make(CopyWithData data) => InventoryFullFailure(
      data.get(#targetEntityId, or: $value.targetEntityId));

  @override
  InventoryFullFailureCopyWith<$R2, InventoryFullFailure, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _InventoryFullFailureCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class PickupableMapper extends ClassMapperBase<Pickupable> {
  PickupableMapper._();

  static PickupableMapper? _instance;
  static PickupableMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PickupableMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Pickupable';

  @override
  final MappableFields<Pickupable> fields = const {};

  static Pickupable _instantiate(DecodingData data) {
    return Pickupable();
  }

  @override
  final Function instantiate = _instantiate;

  static Pickupable fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Pickupable>(map);
  }

  static Pickupable fromJson(String json) {
    return ensureInitialized().decodeJson<Pickupable>(json);
  }
}

mixin PickupableMappable {
  String toJson() {
    return PickupableMapper.ensureInitialized()
        .encodeJson<Pickupable>(this as Pickupable);
  }

  Map<String, dynamic> toMap() {
    return PickupableMapper.ensureInitialized()
        .encodeMap<Pickupable>(this as Pickupable);
  }

  PickupableCopyWith<Pickupable, Pickupable, Pickupable> get copyWith =>
      _PickupableCopyWithImpl<Pickupable, Pickupable>(
          this as Pickupable, $identity, $identity);
  @override
  String toString() {
    return PickupableMapper.ensureInitialized()
        .stringifyValue(this as Pickupable);
  }

  @override
  bool operator ==(Object other) {
    return PickupableMapper.ensureInitialized()
        .equalsValue(this as Pickupable, other);
  }

  @override
  int get hashCode {
    return PickupableMapper.ensureInitialized().hashValue(this as Pickupable);
  }
}

extension PickupableValueCopy<$R, $Out>
    on ObjectCopyWith<$R, Pickupable, $Out> {
  PickupableCopyWith<$R, Pickupable, $Out> get $asPickupable =>
      $base.as((v, t, t2) => _PickupableCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PickupableCopyWith<$R, $In extends Pickupable, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  PickupableCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PickupableCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Pickupable, $Out>
    implements PickupableCopyWith<$R, Pickupable, $Out> {
  _PickupableCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Pickupable> $mapper =
      PickupableMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  Pickupable $make(CopyWithData data) => Pickupable();

  @override
  PickupableCopyWith<$R2, Pickupable, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _PickupableCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class PickupIntentMapper extends ClassMapperBase<PickupIntent> {
  PickupIntentMapper._();

  static PickupIntentMapper? _instance;
  static PickupIntentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PickupIntentMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'PickupIntent';

  static int _$targetEntityId(PickupIntent v) => v.targetEntityId;
  static const Field<PickupIntent, int> _f$targetEntityId =
      Field('targetEntityId', _$targetEntityId);

  @override
  final MappableFields<PickupIntent> fields = const {
    #targetEntityId: _f$targetEntityId,
  };

  static PickupIntent _instantiate(DecodingData data) {
    return PickupIntent(data.dec(_f$targetEntityId));
  }

  @override
  final Function instantiate = _instantiate;

  static PickupIntent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PickupIntent>(map);
  }

  static PickupIntent fromJson(String json) {
    return ensureInitialized().decodeJson<PickupIntent>(json);
  }
}

mixin PickupIntentMappable {
  String toJson() {
    return PickupIntentMapper.ensureInitialized()
        .encodeJson<PickupIntent>(this as PickupIntent);
  }

  Map<String, dynamic> toMap() {
    return PickupIntentMapper.ensureInitialized()
        .encodeMap<PickupIntent>(this as PickupIntent);
  }

  PickupIntentCopyWith<PickupIntent, PickupIntent, PickupIntent> get copyWith =>
      _PickupIntentCopyWithImpl<PickupIntent, PickupIntent>(
          this as PickupIntent, $identity, $identity);
  @override
  String toString() {
    return PickupIntentMapper.ensureInitialized()
        .stringifyValue(this as PickupIntent);
  }

  @override
  bool operator ==(Object other) {
    return PickupIntentMapper.ensureInitialized()
        .equalsValue(this as PickupIntent, other);
  }

  @override
  int get hashCode {
    return PickupIntentMapper.ensureInitialized()
        .hashValue(this as PickupIntent);
  }
}

extension PickupIntentValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PickupIntent, $Out> {
  PickupIntentCopyWith<$R, PickupIntent, $Out> get $asPickupIntent =>
      $base.as((v, t, t2) => _PickupIntentCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PickupIntentCopyWith<$R, $In extends PickupIntent, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({int? targetEntityId});
  PickupIntentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PickupIntentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PickupIntent, $Out>
    implements PickupIntentCopyWith<$R, PickupIntent, $Out> {
  _PickupIntentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PickupIntent> $mapper =
      PickupIntentMapper.ensureInitialized();
  @override
  $R call({int? targetEntityId}) => $apply(FieldCopyWithData(
      {if (targetEntityId != null) #targetEntityId: targetEntityId}));
  @override
  PickupIntent $make(CopyWithData data) =>
      PickupIntent(data.get(#targetEntityId, or: $value.targetEntityId));

  @override
  PickupIntentCopyWith<$R2, PickupIntent, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _PickupIntentCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class PickedUpMapper extends ClassMapperBase<PickedUp> {
  PickedUpMapper._();

  static PickedUpMapper? _instance;
  static PickedUpMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PickedUpMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'PickedUp';

  static int _$targetEntityId(PickedUp v) => v.targetEntityId;
  static const Field<PickedUp, int> _f$targetEntityId =
      Field('targetEntityId', _$targetEntityId);

  @override
  final MappableFields<PickedUp> fields = const {
    #targetEntityId: _f$targetEntityId,
  };

  static PickedUp _instantiate(DecodingData data) {
    return PickedUp(data.dec(_f$targetEntityId));
  }

  @override
  final Function instantiate = _instantiate;

  static PickedUp fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PickedUp>(map);
  }

  static PickedUp fromJson(String json) {
    return ensureInitialized().decodeJson<PickedUp>(json);
  }
}

mixin PickedUpMappable {
  String toJson() {
    return PickedUpMapper.ensureInitialized()
        .encodeJson<PickedUp>(this as PickedUp);
  }

  Map<String, dynamic> toMap() {
    return PickedUpMapper.ensureInitialized()
        .encodeMap<PickedUp>(this as PickedUp);
  }

  PickedUpCopyWith<PickedUp, PickedUp, PickedUp> get copyWith =>
      _PickedUpCopyWithImpl<PickedUp, PickedUp>(
          this as PickedUp, $identity, $identity);
  @override
  String toString() {
    return PickedUpMapper.ensureInitialized().stringifyValue(this as PickedUp);
  }

  @override
  bool operator ==(Object other) {
    return PickedUpMapper.ensureInitialized()
        .equalsValue(this as PickedUp, other);
  }

  @override
  int get hashCode {
    return PickedUpMapper.ensureInitialized().hashValue(this as PickedUp);
  }
}

extension PickedUpValueCopy<$R, $Out> on ObjectCopyWith<$R, PickedUp, $Out> {
  PickedUpCopyWith<$R, PickedUp, $Out> get $asPickedUp =>
      $base.as((v, t, t2) => _PickedUpCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PickedUpCopyWith<$R, $In extends PickedUp, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({int? targetEntityId});
  PickedUpCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PickedUpCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PickedUp, $Out>
    implements PickedUpCopyWith<$R, PickedUp, $Out> {
  _PickedUpCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PickedUp> $mapper =
      PickedUpMapper.ensureInitialized();
  @override
  $R call({int? targetEntityId}) => $apply(FieldCopyWithData(
      {if (targetEntityId != null) #targetEntityId: targetEntityId}));
  @override
  PickedUp $make(CopyWithData data) =>
      PickedUp(data.get(#targetEntityId, or: $value.targetEntityId));

  @override
  PickedUpCopyWith<$R2, PickedUp, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _PickedUpCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
