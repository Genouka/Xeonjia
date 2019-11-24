import 'package:xeonjia/src/screens/game/components/abstract_basic.dart';
import 'package:xeonjia/src/screens/game/components/dynamic/character.dart';
import 'package:xeonjia/src/screens/game/game_page.dart';
import 'package:xeonjia/src/widgets/toast.dart';

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

  // Father is only used if another component generated this one
  BasicComponent father;

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
        super.fromTile(tile);

  // Constructor used for mine weapon shots
  ModifierComponent.mine(
      double _startX, double _startY, this.father, double _atk)
      : super(_startX, _startY, 'mine.png') {
    _lifePointsDiff = -_atk;
  }

  @override
  bool isSolid({BasicComponent otherComponent}) => false;

  @override
  void overlappedBy(BasicComponent componentAbove) {
    if (componentAbove is CharacterComponent) {
      componentAbove.lifePointsDifference(_lifePointsDiff,
          cause: father ?? this);
      componentAbove.atk += _atkDelta;
      componentAbove.def += _defDelta;
      componentAbove.poisonQuantity += _poisonDelta;
      componentAbove.earnedMoney += _moneyDelta;
      componentAbove.selectedWeapon.powerPoints += _powerPointsDelta;
      if (_moneyDelta != 0)
        Toast.show('+ $_moneyDelta \$', gameContext, duration: 1);
      if (_doorId != -1)
        componentAbove.doorKeyList.add(this._doorId);
      else if (_objectId != -1) {
        componentAbove.objectList.add(_objectId);
        Toast.show('I found a Gem!', gameContext, duration: 1);
      }
      componentDeleted();
    }
  }
}
