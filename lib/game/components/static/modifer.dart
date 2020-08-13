import 'dart:math';

import 'package:flame/animation.dart';
import 'package:xeonjia/game/components/abstract_basic.dart';
import 'package:xeonjia/game/components/dynamic/character.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/sfx.dart';

// Stats modifier component
// It increases/decreases character stats
class ModifierComponent extends BasicComponent {
  // Stats difference caused by this component
  int _moneyDelta = 0;
  int _atkDelta = 0;
  int _defDelta = 0;
  double _lifePointsDiff = 0;
  int _powerPointsDelta = 0;
  double _poisonDelta = 0;

  // Item unique id
  // It is != 0 only if this is an unique item
  int _itemId = -1;

  // Door opened by this component
  // Door ID is equal to the next room ID
  // It is != 0 only if this is a key
  int _doorId = -1;

  @override
  BasicComponent father;

  // True if this is capable of being regenerated
  bool _regenerable;

  // True if this should show an explosion animation on destruction
  bool explosionOnDelete = false;

  ModifierComponent(tile, {this.father})
      : _moneyDelta = int.parse(tile.properties['moneyDelta'] ?? '0'),
        _atkDelta = int.parse(tile.properties['atkDelta'] ?? '0'),
        _defDelta = int.parse(tile.properties['defDelta'] ?? '0'),
        _lifePointsDiff =
            double.parse(tile.properties['lifePointsDelta'] ?? '0'),
        _powerPointsDelta =
            int.parse(tile.properties['powerPointsDelta'] ?? '0'),
        _poisonDelta = double.parse(tile.properties['poisonDelta'] ?? '0'),
        _doorId = int.parse(tile.properties['door'] ?? '-1'),
        _itemId = int.parse(tile.properties['itemId'] ?? '-1'),
        _regenerable = (tile.properties['regenerable'] ?? 'false') == 'true',
        super.fromTile(tile);

  // Constructor used for mine weapon shots
  ModifierComponent.mine(Point position, this.father, double _atk)
      : super(position, 'mine.png', imageY: father.teamId.toDouble()) {
    _lifePointsDiff = -_atk;
    explosionOnDelete = true;
  }

  @override
  int priority() => 300;

  @override
  bool isSolid({BasicComponent otherComponent}) => false;

  @override
  void overlappedBy(BasicComponent componentAbove) {
    if (!isBeingDeleted &&
        componentAbove is CharacterComponent &&
        (game.config.friendlyFire ||
            (father?.teamId ?? -99) != componentAbove.teamId)) {
      componentAbove.lifePointsDifference(_lifePointsDiff,
          cause: father ?? this);
      componentAbove.atk += _atkDelta;
      componentAbove.def += _defDelta;
      componentAbove.poisonQuantity += _poisonDelta;
      componentAbove.earnedMoney = _moneyDelta;
      componentAbove.selectedWeapon.powerPoints += _powerPointsDelta;
      if (_doorId != -1) {
        componentAbove.doorKeyList.add(_doorId);
      } else if (_itemId != -1) {
        componentAbove.addItem(_itemId);
      }
      if (_regenerable ?? false) game.modifiersToBeRegenerated.add(this);
      if (explosionOnDelete) {
        isBeingDeleted = true;
        game.playSound(Sfx.explosion);
        animation = Animation.sequenced(
          image,
          4,
          textureX: 16,
          textureY: 16.0 * father.teamId,
          textureWidth: 16,
          textureHeight: 16,
          stepTime: 0.05,
          loop: false,
        )..onCompleteAnimation = delete;
      } else {
        delete();
      }
    }
  }
}
