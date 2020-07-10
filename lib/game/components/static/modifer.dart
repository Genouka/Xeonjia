import 'dart:math';

import 'package:xeonjia/game/components/abstract_basic.dart';
import 'package:xeonjia/game/components/animated_component.dart';
import 'package:xeonjia/game/components/dynamic/character.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

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

  // Object unique id
  // It is != 0 only if this is an unique object
  int _objectId = -1;

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
        _objectId = int.parse(tile.properties['objectId'] ?? '-1'),
        _regenerable = (tile.properties['regenerable'] ?? 'false') == 'true',
        super.fromTile(tile);

  // Constructor used for mine weapon shots
  ModifierComponent.mine(Point position, this.father, double _atk)
      : super(position, 'mine.png', imageRow: father.teamId) {
    _lifePointsDiff = -_atk;
    explosionOnDelete = true;
  }

  @override
  bool isSolid({BasicComponent otherComponent}) => false;

  @override
  void overlappedBy(BasicComponent componentAbove) {
    if (componentAbove is CharacterComponent &&
        (game.friendlyFire ||
            (father?.teamId ?? -99) != componentAbove.teamId)) {
      componentAbove.lifePointsDifference(_lifePointsDiff,
          cause: father ?? this);
      componentAbove.atk += _atkDelta;
      componentAbove.def += _defDelta;
      componentAbove.poisonQuantity += _poisonDelta;
      componentAbove.earnedMoney += _moneyDelta;
      componentAbove.selectedWeapon.powerPoints += _powerPointsDelta;
      if (_powerPointsDelta != 0) game.refreshWeaponBar();
      if (_moneyDelta != 0 && componentAbove == playerOne) {
        game.messageBox.state.message = '+ $_moneyDelta \$';
      }
      if (_doorId != -1) {
        componentAbove.doorKeyList.add(_doorId);
      } else if (_objectId != -1) {
        componentAbove.objectList.add(_objectId);
        game.messageBox.state.message = 'I found a Gem!';
      }
      if (_regenerable ?? false) game.modifiersToBeRegenerated.add(this);
      if (explosionOnDelete) {
        Explosion(this,
            textureX: 16, textureY: 16.0 * father.teamId, amount: 4);
      }
      delete();
    }
  }
}
