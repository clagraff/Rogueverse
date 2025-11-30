import 'package:flutter_test/flutter_test.dart';
import 'package:rogueverse/src/ecs/ecs.barrel.dart';

void main() {
  initializeMappers(); // required for the Mappers to work.

  group("XmlSerializer", () {
    test('Serialize list', () {
      var components = [
        Health(5, 10),
        LocalPosition(x: 0, y: 2),
      ];
      var r = XmlSerializer.serialize(components);
      expect(r.localName, "List");
      expect(r.children.length, components.length);
    });

    test('Serialize map', () {
      var components = {
        "Health": Health(5, 10),
        "LocalPosition": LocalPosition(x: 0, y: 2),
      };
      var r = XmlSerializer.serialize(components);
      expect(r.localName, "Map");
      expect(r.children.length, components.length);
    });

    test('Serialize component', () {
      var r = XmlSerializer.serialize(AiControlled());
      expect(r.localName, "AiControlled");
    });

    test('Serialize component attributes', () {
      var r = XmlSerializer.serialize(Health(5, 10));
      expect(r.getAttributeNode("current")?.value, "5");
      expect(r.getAttributeNode("max")?.value, "10");
    });

    test('Serialize nested component', () {
      var loot = Loot(components: [
        Name(name: "Item")
      ]);
      var r = JsonSerializer.serialize(loot);
      print(r);
    });
  });
}