import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:xeonjia/src/resources/weapon_details.dart';
import 'package:xeonjia/src/screens/game/components/dynamic/character.dart';
import 'package:xeonjia/src/screens/game/components/dynamic/snowball.dart';
import 'package:xeonjia/src/screens/game/components/static/modifer.dart';
import 'package:xeonjia/src/screens/game/game_page.dart';
import 'package:xeonjia/src/screens/game/utils/xeonjia_game.dart';
import 'package:xeonjia/src/widgets/toast.dart';

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

  Weapon(this.id);

  // Function used when a shoot input happens
  void shoot({@required CharacterComponent shooter}) {
    if (shooter == player) {
      // Update bottom weapon bar
      weaponBar.state.refresh(
          percent: player?.selectedWeapon?.powerPoints != double.infinity
              ? (player?.selectedWeapon?.powerPoints ?? 100) /
                  // should use max PP...
                  (10 + 5 * player?.selectedWeapon?.level)
              : 1,
          text: (weaponDetails[player?.selectedWeapon?.id]['name'] ?? '') +
              (player?.selectedWeapon?.powerPoints?.isFinite ?? false
                  ? ' (${player?.selectedWeapon?.powerPoints?.round().toString()})'
                  : ''));
    }
  }

  // Export weapon details as a Json
  Map<int, int> toJson() => {id: level};
}

// Punch
class PunchWeapon extends Weapon {
  final int level;

  PunchWeapon({@required this.level}) : super(0) {
    atk = (level + 1).toDouble();
  }

  @override
  void shoot({@required CharacterComponent shooter}) {
    Offset punch = Offset.zero;
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
    Toast.show('~ Punch! ~', gameContext, duration: 1);
  }
}

// Snowball
class SnowBallWeapon extends Weapon {
  final int level;

  SnowBallWeapon({@required this.level}) : super(1) {
    powerPoints = (10 + 5 * level).toDouble();
    atk = (10 + level * 2).toDouble();
  }

  @override
  void shoot({@required CharacterComponent shooter}) {
    if (powerPoints > 0) {
      SnowballComponent(
          shooter.x, shooter.y, shooter.orientation, shooter, atk);
      --powerPoints;
      super.shoot(shooter: shooter);
    }
  }
}

// Mine
class MineWeapon extends Weapon {
  final int level;

  MineWeapon({@required this.level}) : super(2) {
    powerPoints = (10 + 5 * level).toDouble();
    atk = (10 + level * 2).toDouble();
  }

  @override
  void shoot({@required CharacterComponent shooter}) {
    if (powerPoints > 0) {
      ModifierComponent.mine(shooter.x, shooter.y, shooter, atk);
      --powerPoints;
      super.shoot(shooter: shooter);
    }
  }
}
