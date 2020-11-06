import 'dart:math';
import 'package:flutter/material.dart';

import 'package:xeonjia/game/components/dynamic/character.dart';
import 'package:xeonjia/game/components/dynamic/snowball.dart';
import 'package:xeonjia/game/components/static/modifer.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/sfx.dart';
import 'package:xeonjia/resources/weapon_details.dart';

// Abstract class used to manage weapons inside game
// It defines what happens if someone use a weapon
abstract class Weapon {
  // Weapon id
  final int id;

  // Weapon level
  int level;

  // Weapon attack value
  double atk;

  // Number of times a weapon can be used
  double _powerPoints = 0;
  double maxPp;
  double get ppPercentage => _powerPoints / maxPp;
  double get powerPoints => _powerPoints;
  set powerPoints(double powerPoints) {
    _powerPoints = powerPoints;
    if (_powerPoints > maxPp) restorePp();
  }

  // Weapon details
  String get name => weaponDetails[id]['name'];
  String get description => weaponDetails[id]['description'];

  Weapon(this.id, this.maxPp) {
    maxPp ??= ((10 + 5 * level).toDouble());
    _powerPoints = maxPp;
  }

  // Restore PP
  void restorePp() {
    powerPoints = maxPp;
  }

  // Function used when a shoot input happens
  @mustCallSuper
  void shoot({@required CharacterComponent shooter}) {
    if (shooter.isPlayerOne) game.refreshWeaponButtons();
  }

  // Export weapon details as a Json
  Map<int, int> toJson() => {id: level};

  // Return a new weapon
  static Weapon fromId(int id) {
    if (id == 1) return SnowBallWeapon(level: 0);
    if (id == 2) return MineWeapon(level: 0);
    return PunchWeapon(level: 0);
  }
}

// Punch
class PunchWeapon extends Weapon {
  @override
  final int level;

  PunchWeapon({@required this.level}) : super(0, double.infinity) {
    atk = level.toDouble();
  }

  @override
  void shoot({@required CharacterComponent shooter}) {
    shooter.componentInFront()?.lifePointsDifference(-atk, cause: shooter);
    shooter.animate([shooter.punchSprites[shooter.orientation]]);
    if (shooter.isPlayerOne) game.playSound(Sfx.punch);
    super.shoot(shooter: shooter);
  }
}

// Snowball
class SnowBallWeapon extends Weapon {
  @override
  final int level;

  SnowBallWeapon({@required this.level, double powerPoints})
      : super(1, powerPoints) {
    atk = (10 + level * 2).toDouble();
  }

  @override
  void shoot({@required CharacterComponent shooter}) {
    if (powerPoints > 0) {
      SnowballComponent(
          Point(shooter.x, shooter.y), shooter, shooter.orientation, atk);
      --powerPoints;
      super.shoot(shooter: shooter);
      shooter.animate([shooter.punchSprites[shooter.orientation]]);
    }
  }
}

// Mine
class MineWeapon extends Weapon {
  @override
  final int level;

  MineWeapon({@required this.level, double powerPoints})
      : super(2, powerPoints) {
    atk = (10 + level * 2).toDouble();
  }

  @override
  void shoot({@required CharacterComponent shooter}) {
    if (powerPoints > 0) {
      ModifierComponent.mine(Point(shooter.x, shooter.y), shooter, atk);
      --powerPoints;
      super.shoot(shooter: shooter);
    }
  }
}
