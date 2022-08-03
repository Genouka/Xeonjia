import 'package:flame/image_composition.dart';
import 'package:xeonjia/game/components/common/basic.dart';
import 'package:xeonjia/game/utils/extensions.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

// Vertical offset used to translate characters
mixin RenderOffset on BasicComponent {
  double get _offset =>
      -(componentSize * (gameRef.miniMapEnabled ? gameRef.camera.zoom : 1) / 8)
          .gridAligned
          .toDouble();

  @override
  void render(Canvas canvas) => super.render(canvas..translate(0, _offset));
}
