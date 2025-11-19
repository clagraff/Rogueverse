import 'package:dart_mappable/dart_mappable.dart';
import 'components.dart';
import 'package:xml/xml.dart';

XmlElement mapToXmlElement(String tag, Map<String, dynamic> map) {
  return XmlElement(
    XmlName(tag),
    [
      for (final e in map.entries)
        XmlAttribute(XmlName(e.key), e.value.toString()),
    ],
  );
}

Map<String, String> xmlElementToStringMap(XmlElement element) {
  return {
    for (final a in element.attributes)
      a.name.local: a.value,
  };
}

XmlElement toXml<T extends Comp>(T value) {
  final map = MapperContainer.globals.toMap(value) as Map<String, dynamic>;

  // If mapper encoded a __type discriminator, prefer that as the tag.
  String tag;
  if (map.containsKey('__type')) {
    tag = map['__type'] as String;
    map.remove('__type'); // don’t emit it as an attribute
  } else {
    // Fallback: use runtimeType name, stripping nullable suffix
    final s = value.runtimeType.toString();
    tag = s.endsWith('?') ? s.substring(0, s.length - 1) : s;
  }

  return XmlElement(
    XmlName(tag),
    [
      for (final e in map.entries)
        XmlAttribute(XmlName(e.key), e.value.toString()),
    ],
  );
}

dynamic fromXml(XmlElement element) {
  final stringMap = xmlElementToStringMap(element);
  stringMap['__type'] = element.name.local;
  // Here we just hand the stringMap directly to the mapper and let
  // custom mappers do the heavy lifting if needed:
  return MapperContainer.globals.fromMap(stringMap); // returns a _Map
}