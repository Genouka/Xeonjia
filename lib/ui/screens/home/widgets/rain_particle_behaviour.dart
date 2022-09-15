import 'dart:math';

import 'package:animated_background/animated_background.dart';

class RainParticleBehaviour extends RandomParticleBehaviour {
  RainParticleBehaviour(ParticleOptions options) : super(options: options);
  static final Random random = Random();

  @override
  void initPosition(Particle p) {
    p.cx = random.nextDouble() * size!.width;
    p.cy = p.cy == 0.0
        ? random.nextDouble() * size!.height
        : random.nextDouble() * size!.width * 0.2;
  }

  @override
  void initDirection(Particle p, double speed) {
    double dirX = random.nextDouble() - 0.5;
    double dirY = random.nextDouble() * 0.5 + 0.5;
    double magSq = dirX * dirX + dirY * dirY;
    double mag = magSq <= 0 ? 1 : sqrt(magSq);

    p.dx = dirX / mag * speed;
    p.dy = dirY / mag * speed;
  }
}
