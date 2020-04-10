import 'dart:ui';
import 'package:flame/animation.dart';
import 'package:flutter/foundation.dart';

import 'package:xeonjia/src/screens/game/components/abstract_basic.dart';
import 'package:xeonjia/src/screens/game/utils/xeonjia_game.dart';

// Component with animation
class AnimatedComponent extends BasicComponent {
  Animation animation;
  bool destroyOnFinish;

  AnimatedComponent({
    @required String imagePath,
    @required int amount,
    @required double startX,
    @required double startY,
    double width,
    double height,
    int amountPerRow,
    double textureX = 0,
    double textureY = 0,
    double textureWidth = 16,
    double textureHeight = 16,
    double stepTime = 0.1,
    bool loop = true,
    this.destroyOnFinish = false,
  }) : super.withoutImage(startX, startY) {
    this.width = (width ?? componentSize);
    this.height = (height ?? componentSize);
    animation = Animation.sequenced(
      imagePath,
      amount,
      amountPerRow: amountPerRow,
      textureX: textureX,
      textureY: textureY,
      textureWidth: textureWidth,
      textureHeight: textureHeight,
      stepTime: stepTime,
      loop: loop,
    );
  }

  @override
  bool isSolid({otherComponent}) => false;

  @override
  bool isFlying() => true;

  @override
  int priority() => 10;

  @override
  bool loaded() => animation.loaded();

  @override
  bool destroy() => destroyOnFinish && animation.isLastFrame;

  @override
  void render(Canvas canvas) {
    prepareCanvas(canvas);
    animation.getSprite().render(canvas, width: width, height: height);
  }

  @override
  void update(double t) {
    animation.update(t);
  }
}
