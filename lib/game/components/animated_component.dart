import 'dart:math';
import 'dart:ui';
import 'package:flame/animation.dart';
import 'package:flutter/foundation.dart';

import 'package:xeonjia/game/components/abstract_basic.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/direction.dart';

// Animated explosion
class Explosion extends AnimatedComponent {
  Explosion(
    BasicComponent component, {
    double textureX = 0,
    double textureY = 0,
    int amount = 5,
    stepTime = 0.05,
  }) : super(
          position: Point(
              component.x + component.direction.dx * componentSize / 2,
              component.y + component.direction.dy * componentSize / 2),
          imagePath: component.image,
          textureX: textureX,
          textureY: textureY,
          amount: amount,
          stepTime: stepTime,
          destroyOnFinish: true,
        );
}

// Component with animation
class AnimatedComponent extends BasicComponent {
  Animation animation;
  bool destroyOnFinish;

  AnimatedComponent({
    @required String imagePath,
    @required int amount,
    @required Point position,
    double width,
    double height,
    int amountPerRow,
    double textureX = 0,
    double textureY = 0,
    double textureWidth = 16,
    double textureHeight = 16,
    double stepTime = 0.05,
    bool loop = false,
    this.destroyOnFinish = false,
  }) : super.withoutImage(position) {
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
  int priority() => super.priority() + 10;

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
    super.update(t);
  }
}
