import 'dart:math';

import 'package:xeonjia/game/components/common/walker.dart';
import 'package:xeonjia/game/components/modifer.dart';
import 'package:xeonjia/game/components/snowball.dart';
import 'package:xeonjia/game/utils/sfx.dart';
import 'package:xeonjia/utils/game_properties.dart';

enum Weapons {
  punch(0),
  snowball(1),
  mine(2);

  const Weapons(this.id);
  final int id;
}

// Abstract class used to manage weapons inside game
// It defines what happens if someone use a weapon
abstract class Weapon {
  Weapon(this.id, double? maxPp) {
    this.maxPp = maxPp ?? 10 + level * 5.0;
    _powerPoints = this.maxPp;
  }

  // Weapon id
  final int id;

  // Weapon level
  late int level;

  // Weapon attack value
  late double atk;

  // Number of times a weapon can be used
  double _powerPoints = 0;
  late double maxPp;
  double get ppPercentage => _powerPoints / maxPp;
  double get powerPoints => _powerPoints;
  set powerPoints(double? powerPoints) {
    _powerPoints = powerPoints ?? double.infinity;
    if (_powerPoints > maxPp) restorePp();
  }

  // Restore PP
  void restorePp() {
    powerPoints = maxPp;
  }

  // Function used when a shoot input happens
  void shoot({required Walker shooter});

  // Export / Import weapon details
  Map<String, dynamic> toJson() =>
      {'id': id, 'lv': level, 'pp': powerPoints.isFinite ? maxPp : null};
  static Weapon fromJson(Map<String, dynamic> json) =>
      (Weapon.fromId(json['id'], json['lv'])
        ..powerPoints = (json['pp'] ?? double.infinity));

  // Return a new weapon
  static Weapon fromId(int id, [int level = 0]) {
    if (id == 1) return SnowBallWeapon(level: level);
    if (id == 2) return MineWeapon(level: level);
    return PunchWeapon(level: 0);
  }
}

// Punch
class PunchWeapon extends Weapon {
  PunchWeapon({required this.level})
      : super(Weapons.punch.id, double.infinity) {
    atk = level + 1.0;
  }

  @override
  final int level;

  @override
  void shoot({required Walker shooter}) {
    var componentInFront = shooter.componentInFront();
    componentInFront?.hpDifference(-atk, cause: shooter);
    shooter.animation = shooter.atlas
        .getAnimation('${shooter.name}-${shooter.orientation.index}-punching');
    if (shooter.isPlayerOne) shooter.gameRef.playSound(Sfx.punch);
  }
}

// Snowball
class SnowBallWeapon extends Weapon {
  SnowBallWeapon({required this.level, double? powerPoints})
      : super(Weapons.snowball.id, powerPoints) {
    atk = 10 + level * 2.0;
  }

  @override
  final int level;

  @override
  void shoot({required Walker shooter}) {
    if (powerPoints > 0) {
      shooter.gameRef.add(SnowballComponent(
          Point(shooter.x, shooter.y), shooter, shooter.orientation, atk));
      --powerPoints;
      if (shooter == shooter.gameRef.playerOne ||
          shooter.gameRef.config.mode != GameMode.story) {
        shooter.animation = shooter.atlas.getAnimation(
            '${shooter.name}-${shooter.orientation.index}-punching');
      }
    }
  }
}

// Mine
class MineWeapon extends Weapon {
  MineWeapon({required this.level, double? powerPoints})
      : super(Weapons.mine.id, powerPoints) {
    atk = 10 + level * 2.0;
  }

  @override
  final int level;

  @override
  void shoot({required Walker shooter}) {
    if (powerPoints > 0) {
      shooter.gameRef.add(
          ModifierComponent.mine(Point(shooter.x, shooter.y), shooter, atk));
      --powerPoints;
    }
  }
}
