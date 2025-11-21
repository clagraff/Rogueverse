import 'package:flutter_test/flutter_test.dart';
import 'package:rogueverse/src/ecs/ecs.barrel.dart';

void main() {
  initializeMappers();

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
  });
}