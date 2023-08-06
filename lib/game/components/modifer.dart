import 'dart:math';

import 'package:xeonjia/game/xeonjia.dart';

/// Stats modifier component
/// It increases/decreases character stats
class ModifierComponent extends BasicComponent {
  ModifierComponent(tile, {this.father})
      : _moneyDelta = int.parse(tile.properties['moneyDelta'] ?? '0'),
        _atkDelta = int.parse(tile.properties['atkDelta'] ?? '0'),
        _defDelta = int.parse(tile.properties['defDelta'] ?? '0'),
        _hpDelta = double.parse(tile.properties['healthPointsDelta'] ?? '0'),
        _powerPointsDelta =
            int.parse(tile.properties['powerPointsDelta'] ?? '0'),
        _poisonDelta = double.parse(tile.properties['poisonDelta'] ?? '0'),
        _itemId = tile.properties['itemId'] ?? '0',
        _regenerable = (tile.properties['regenerable'] ?? 'false') == 'true',
        super.fromTile(tile);

  /// Constructor used for mine weapon shots
  ModifierComponent.mine(Point position, this.father, double atk)
      : atlasAsset = 'weapons.xfa',
        name = 'mine-${father!.teamId}',
        super(null,
            Point(position.x / componentSize, position.y / componentSize)) {
    _hpDelta = -atk;
    explosionOnDelete = true;
  }

  @override
  Future<void>? onLoad() {
    gameRef.reorderChildren();
    return super.onLoad();
  }

  @override
  String? atlasAsset;

  @override
  String? name;

  /// Stats difference caused by this component
  int _moneyDelta = 0;
  int _atkDelta = 0;
  int _defDelta = 0;
  double _hpDelta = 0;
  int _powerPointsDelta = 0;
  double _poisonDelta = 0;

  /// Item unique ID
  /// It is "0" if this is not an unique item (this can be taken multiple times)
  String _itemId = '0';

  @override
  BasicComponent? father;

  /// True if this is capable of being regenerated
  bool? _regenerable;

  /// True if this should show an explosion animation on destruction
  bool explosionOnDelete = false;

  @override
  int get priority => 50;

  @override
  bool isSolid({BasicComponent? otherComponent}) => false;

  @override
  void overlappedBy(BasicComponent componentAbove) {
    if (!isBeingDeleted &&
        (componentAbove is CharacterComponent ||
            (explosionOnDelete && componentAbove is SliderCpuComponent)) &&
        (gameRef.config.friendlyFire ||
            (father?.teamId ?? -99) != componentAbove.teamId)) {
      componentAbove.hpDifference(_hpDelta, cause: father ?? this);
      componentAbove.atk += _atkDelta;
      componentAbove.def += _defDelta;
      componentAbove.poisonQuantity += _poisonDelta;
      if (componentAbove is CharacterComponent) {
        componentAbove.moneyDifference(_moneyDelta);
        for (final weapon in componentAbove.weaponList) {
          weapon.powerPoints += _powerPointsDelta;
        }
        if (componentAbove.isUser) {
          if (_hpDelta != 0 && componentAbove.isUser) {
            gameRef.user!.showText('+ ${_hpDelta.round()} HP');
          } else if (_moneyDelta != 0 && componentAbove.isUser) {
            gameRef.user!.showText('+ $_moneyDelta ¤');
            gameRef.playSound(Sfx.money);
          }
          if (_itemId != '0' &&
              componentAbove.isUser &&
              gameRef.config.mode == GameMode.story) {
            gameRef.playerOne!.addItem(_itemId, sfx: _moneyDelta == 0);
          }
        }
      }
      if (_regenerable ?? false) gameRef.modifiersToBeRegenerated.add(this);
      if (explosionOnDelete) {
        if (componentAbove.hp <= 0) (componentAbove as Walker).stop();
        isBeingDeleted = true;
        gameRef.playSound(Sfx.explosion);
        animation = atlas.getAnimation('${name}_explosion')
          ..onComplete = delete;
      } else {
        delete();
      }
    }
  }
}
