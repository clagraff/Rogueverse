import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import 'package:rogueverse/game/components/visual_component.dart';

class PngVisualComponent extends VisualComponent {
  late final SpriteComponent _sprite;

  final String pngAssetPath;

  PngVisualComponent({
    required this.pngAssetPath,
    super.position,
    super.size,
    super.flipHorizontal,
    super.flipVertical,
    super.rotationDegrees,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final png = await Flame.images.load(pngAssetPath);

    _sprite = SpriteComponent(
      sprite: Sprite(png),
      size: size,
    );

    add(_sprite); // Adds it as a child
  }
}
