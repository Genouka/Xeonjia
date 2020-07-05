import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:xeonjia/resources/weapon_details.dart';
import 'package:xeonjia/game/components/dynamic/character.dart';
import 'package:xeonjia/game/components/dynamic/snowball.dart';
import 'package:xeonjia/game/components/static/modifer.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

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
  double powerPoints = double.infinity;

  // Weapon details
  String get name => weaponDetails[id]['name'];
  String get description => weaponDetails[id]['description'];
  String get prize => weaponDetails[id]['prize'];

  Weapon(this.id);

  // Set max PP for this level
  void resetPp({double customValue}) {
    powerPoints = customValue ?? (10 + 5 * level).toDouble();
  }

  // Function used when a shoot input happens
  void shoot({@required CharacterComponent shooter}) {
    if (shooter == playerOne) game.refreshWeaponBar();
  }

  // Export weapon details as a Json
  Map<int, int> toJson() => {id: level};
}

// Punch
class PunchWeapon extends Weapon {
  @override
  final int level;

  PunchWeapon({@required this.level}) : super(0) {
    atk = level.toDouble();
  }

  @override
  void shoot({@required CharacterComponent shooter}) {
    Offset punch;
    switch (shooter.orientation) {
      case 1:
        punch = Offset(shooter.x, shooter.y + componentSize * 3 / 2);
        break;
      case 2:
        punch = Offset(shooter.x, shooter.y - componentSize / 2);
        break;
      case 3:
        punch = Offset(shooter.x + componentSize * 3 / 2, shooter.y);
        break;
      case 4:
        punch = Offset(shooter.x - componentSize / 2, shooter.y);
        break;
      default:
        break;
    }
    List.from(game.components).forEach((component) {
      if (component.toRect().contains(punch)) {
        component.lifePointsDifference(-atk, cause: shooter);
        return;
      }
    });
    shooter.animate([shooter.punchSprites[shooter.orientation]]);
  }
}

// Snowball
class SnowBallWeapon extends Weapon {
  @override
  final int level;

  SnowBallWeapon({@required this.level, double powerPoints}) : super(1) {
    resetPp(customValue: powerPoints);
    atk = (10 + level * 2).toDouble();
  }

  @override
  void shoot({@required CharacterComponent shooter}) {
    if (powerPoints > 0) {
      SnowballComponent(
          Point(shooter.x, shooter.y), shooter.orientation, shooter, atk);
      --powerPoints;
      super.shoot(shooter: shooter);
    }
  }
}

// Mine
class MineWeapon extends Weapon {
  @override
  final int level;

  MineWeapon({@required this.level, double powerPoints}) : super(2) {
    resetPp(customValue: powerPoints);
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
