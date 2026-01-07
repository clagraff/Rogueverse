import 'package:flame/components.dart';
import 'package:flame_svg/flame_svg.dart';

import 'package:rogueverse/game/components/visual_component.dart';

class SvgVisualComponent extends VisualComponent {
  late final SvgComponent _svg;

  final String svgAssetPath;

  SvgVisualComponent(
      {required this.svgAssetPath, Vector2? position, Vector2? size})
      : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final svg = await Svg.load(svgAssetPath);

    _svg = SvgComponent(svg: svg, size: size, paint: paint);

    add(_svg); // Adds it as a child
  }
}
