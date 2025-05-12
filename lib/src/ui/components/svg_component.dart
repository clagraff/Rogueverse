import 'package:flame/components.dart';
import 'package:flame_svg/flame_svg.dart';

class SvgTileComponent extends PositionComponent {
  late final SvgComponent _svg;

  final String svgAssetPath;

  SvgTileComponent({required this.svgAssetPath, Vector2? position, Vector2? size}) {
    this.position = position ?? Vector2.zero();
    this.size = size ?? Vector2.all(32); // Default tile size
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final svg = await Svg.load(svgAssetPath);

    _svg = SvgComponent(
      svg: svg,
      size: size,
    );

    add(_svg); // Adds it as a child
  }
}
