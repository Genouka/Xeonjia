import 'package:flame/image_composition.dart';
import 'package:xeonjia/game/xeonjia.dart';

/// Vertical offset used to translate characters
mixin RenderOffset on BasicComponent {
  double get _offset =>
      -(componentSize * (gameRef.miniMapEnabled ? gameRef.miniMapZoom : 1) / 8)
          .gridAligned
          .toDouble();

  @override
  void render(Canvas canvas) => super.render(canvas..translate(0, _offset));
}
