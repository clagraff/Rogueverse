
import 'package:flame/components.dart';
import 'package:flame/flame.dart';

class PngTileComponent extends PositionComponent with HasPaint {
  late final SpriteComponent _sprite;

  final String pngAssetPath;

  PngTileComponent(
      {required this.pngAssetPath, Vector2? position, Vector2? size}) {
    this.position = position ?? Vector2.zero();
    this.size = size ?? Vector2.all(32);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final png = await Flame.images.load(pngAssetPath);

    _sprite = SpriteComponent(
      sprite: Sprite(png),
      size: size,
    );

    add(_sprite); // Adds it as a child
  }
}
