import 'package:flame/components/timer_component.dart';
import 'package:flame/time.dart';

import 'package:xeonjia/game/components/abstract_basic.dart';
import 'package:xeonjia/game/components/abstract_dynamic.dart';
import 'package:xeonjia/game/components/dynamic/character.dart';
import 'package:xeonjia/game/util/little_scheme.dart';
import 'package:xeonjia/game/util/weapon.dart';
import 'package:xeonjia/game/widgets/black_curtain.dart';
import 'package:xeonjia/game/widgets/map_name_box.dart';
import 'package:xeonjia/game/widgets/shop_menu.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/direction.dart';
import 'package:xeonjia/models/message.dart';
import 'package:xeonjia/models/shop_item.dart';
import 'package:xeonjia/util/local_data_controller.dart';

// Set scheme's environment
Environment setEnvironment() {
  var env = Environment(null, null, null);
  var _ = (String name, int arity, IntrinsicBody fun) {
    env.defineSymbol(Sym(name), Intrinsic(name, arity, fun));
  };
  env.defineSymbol(Sym('hero'), mainCharacter.name);

  // Return [actor, value] for Cells that have a default actor
  // e.g. (move 2) and (move '(0 93))
  List getActorAndValue(Cell x) => (x.car is Cell)
      ? [
          game.getComponentFromId(((x.car as Cell).cdr as Cell).car),
          (x.car as Cell).car
        ]
      : [env.lookForValue(Sym('actor')), x.car];

  // Game procedures
  _('get-life', 0, (Cell x) => game.playerOne.lifePoints);
  _('get-initial-life', 0, (Cell x) => game.playerOne.maxLifePoints);
  _(
      'set-life-diff',
      1,
      (Cell x) =>
          game.playerOne.lifePointsDifference((x.car as int).toDouble()));
  _('set-life-to', 1,
      (Cell x) => game.playerOne.setStatus((x.car as int).toDouble(), 0));
  _('restore-life', 0, (Cell x) {
    game.addWidgetOverlay(
        'blackCurtain', BlackCurtain(game.playerOne.restoreStatus));
    return #NONE;
  });
  _('increase-life', 1, (Cell x) => game.playerOne.maxLifePoints += x.car);
  _('get-atk', 0, (Cell x) => game.playerOne.atk);
  _('increase-atk', 1, (Cell x) => game.playerOne.atk += x.car);
  _('get-def', 0, (Cell x) => game.playerOne.def);
  _('increase-def', 1, (Cell x) => game.playerOne.def += x.car);
  _('set-money-diff', 1,
      (Cell x) => game.playerOne.moneyDifference((x.car as int), popup: false));
  _('has-weapon', 1, (Cell x) => game.playerOne.hasWeaponId(x.car));
  _('max-pp-snowballs', 0, (Cell x) {
    if (!game.playerOne.hasWeaponId(1)) return false;
    var weapon = game.playerOne.getWeaponById(1);
    var max = weapon.powerPoints >= weapon.maxPp;
    weapon.restorePp();
    game.refreshWeaponButtons();
    return max;
  });
  _('give-weapon', 1, (Cell x) {
    game.playerOne.weaponList.add(Weapon.fromId((x.car as int)));
    game.refreshWeaponButtons();
    return #NONE;
  });
  _('places-visited', 0, (Cell x) => mainCharacter.visitedRooms.toSet().length);
  _(
      'last-place',
      0,
      (Cell x) =>
          mainCharacter.visitedRooms[mainCharacter.visitedRooms.length - 2]);
  _(
      'first-time?',
      0,
      (Cell x) =>
          mainCharacter.visitedRooms
              .where((e) =>
                  e.split('/').first ==
                  mainCharacter.visitedRooms.last.split('/').first)
              .length ==
          1);
  _('place', 3, (Cell x) {
    var c = game.getComponentFromId(x.car);
    c.x = x.cdr.car / 16 * componentSize;
    c.y = x.cdr.cdr.car / 16 * componentSize;
    if (c.isPlayerOne) game.updateCamera(game.playerOne.x, game.playerOne.y);
    return #NONE;
  });
  _('move', 1, (Cell x) {
    var actorAndValue = getActorAndValue(x);
    DynamicComponent actor = actorAndValue[0];
    int direction = actorAndValue[1];
    actor.updateDirection(GetDirection.fromInt(direction), animated: false);
    return #NONE;
  });
  _('orientation', 0, (Cell x) => game.playerOne.orientation.index);
  _('set-orientation', 1, (Cell x) {
    var actorAndValue = getActorAndValue(x);
    DynamicComponent actor = actorAndValue[0];
    int direction = actorAndValue[1];
    actor.orientation = GetDirection.fromInt(direction);
    return #NONE;
  });
  _('delete-me', 0, (Cell x) {
    BasicComponent self = (env.lookForValue(Sym('self')) as Intrinsic).fun(x);
    self.delete();
    return #NONE;
  });
  _('delete', 1, (Cell x) => game.getComponentFromId(x.car).delete());
  _('respawn', 1, (Cell x) => game.getDeletedComponentFromId(x.car).respawn());
  _('leave', 0, (Cell x) {
    BasicComponent self = (env.lookForValue(Sym('self')) as Intrinsic).fun(x);
    game.addWidgetOverlay('blackCurtain', BlackCurtain(self.delete));
    return #NONE;
  });
  _('friendly', 1, (Cell x) {
    var actorAndValue = getActorAndValue(x);
    CharacterComponent actor = actorAndValue[0];
    bool friendly = actorAndValue[1];
    actor.friendly = friendly;
    return #NONE;
  });
  _('quiet', 1, (Cell x) {
    var actorAndValue = getActorAndValue(x);
    CharacterComponent actor = actorAndValue[0];
    bool quiet = actorAndValue[1];
    actor.quiet = quiet;
    return #NONE;
  });
  _('enemies-count', 0, (Cell x) => game.enemies);
  _('fire-event', 1, (Cell x) => (x.car as BasicComponent).executeAction());
  _(
      'fire-global-event',
      0,
      (Cell x) => game.components.forEach((c) {
            if (c is BasicComponent) c.executeAction();
          }));
  _(
      'has-item',
      1,
      (Cell x) =>
          (game.playerOne?.itemList ?? mainCharacter.itemList).contains(x.car));
  _('give-item', 1, (Cell x) => game.playerOne.addItem(x.car));
  _('find-item', 1, (Cell x) => game.playerOne.addItem(x.car));
  _('take-item', 1, (Cell x) => game.playerOne.removeItem(x.car));
  _('story-dialog', 1, (Cell x) {
    game.setMessage(Message(stringify(x.car, false)), hideMap: true);
    return #NONE;
  });
  _('dialog', 1, (Cell x) {
    var it = (x.car as Cell).iterator;
    while (it.moveNext()) {
      game.setMessage((it.current as Cell).length == 1
          ? Message((it.current as Cell).car,
              component: (env.lookForValue(Sym('actor')) as BasicComponent))
          : Message((it.current as Cell).cdr.car,
              component: (env.lookForValue(Sym('actor')) as BasicComponent),
              author: (it.current as Cell).car));
    }
    return #NONE;
  });
  _('dialog-kobi', 1, (Cell x) {
    var it = (x.car as Cell).iterator;
    while (it.moveNext()) {
      game.setMessage((it.current as Cell).length == 1
          ? Message((it.current as Cell).car,
              component: (env.lookForValue(Sym('actor')) as BasicComponent),
              translate: false,
              font: 'kobi')
          : Message(
              (it.current as Cell).cdr.car,
              component: (env.lookForValue(Sym('actor')) as BasicComponent),
              author: (it.current as Cell).car,
              translate: false,
              font: 'kobi',
            ));
    }
    return #NONE;
  });
  _('answer', 2, (Cell x) {
    var it = (x.cdr.car as Cell).iterator;
    while (it.moveNext()) {
      game.messageManager.answers.add(Answer(x.car.toString(),
          (it.current as Cell).car.toString(), (it.current as Cell).cdr));
    }
    return #NONE;
  });
  _('shop', 1, (Cell x) {
    var itemList = <ShopItem>[];
    var it = (x.car as Cell).iterator;
    while (it.moveNext()) {
      itemList.add(ShopItem(
        name: (it.current as Cell).car,
        price: (it.current as Cell).cdr.car as int,
        action: (it.current as Cell).cdr.cdr.car,
      ));
    }
    ;
    game.addWidgetOverlay('shop', ShopMenu(itemList));
    return #NONE;
  });
  _('black-curtain', 0,
      (Cell x) => game.addWidgetOverlay('blackCurtain', BlackCurtain()));
  _('teleport', 2,
      (Cell x) => game.changeRoom(x.car, enterNextRoom: x.cdr.car));
  _(
    'get',
    1,
    (Cell x) => (game.currentEventLog.containsKey(x.car.toString()))
        ? game.currentEventLog[x.car.toString()]
        : false,
  );
  _(
    '!get', // only for boolean
    1,
    (Cell x) => (game.currentEventLog.containsKey(x.car.toString()))
        ? !game.currentEventLog[x.car.toString()]
        : true,
  );
  _('set', 2, (Cell x) {
    game.currentEventLog[x.car.toString()] = x.cdr.car;
    return #NONE;
  });
  _('map-name', 1, (Cell x) {
    game.map.name = stringify(x.car, false);
    game.addWidgetOverlay('mapNameBox', MapNameBox());
    var _id = mainCharacter.visitedRooms.length;
    game.addLater(TimerComponent(Timer(
      3,
      callback: () {
        if (_id == mainCharacter.visitedRooms.length &&
            !(game?.miniMapEnabled ?? true)) {
          game?.removeWidgetOverlay('mapNameBox');
        }
      },
      repeat: false,
    )..start()));
    return #NONE;
  });

  // Built-in procedures
  _('car', 1, (Cell x) => (x.car as Cell).car);
  _('cdr', 1, (Cell x) => (x.car as Cell).cdr);
  _('cons', 2, (Cell x) => Cell(x.car, x.cdr.car));
  _('eq?', 2, (Cell x) => identical(x.car, x.cdr.car));
  _('pair?', 1, (Cell x) => x.car is Cell);
  _('null?', 1, (Cell x) => x.car == null);
  _('not', 1, (Cell x) => x.car == false);
  _('!', 1, (Cell x) => x.car == false);
  _('list', -1, (Cell x) => x);
  _('eof-object?', 1, (Cell x) => x.car == #EOF);
  _('symbol?', 1, (Cell x) => x.car is Sym);

  env.defineSymbol(callccSym, #CALLCC);
  env.defineSymbol(applySym, #APPLY);

  _('and', 2, (Cell x) => x.car && x.cdr.car);
  _('or', 2, (Cell x) => x.car || x.cdr.car);
  _('+', 2, (Cell x) => add(x.car, x.cdr.car));
  _('-', 2, (Cell x) => subtract(x.car, x.cdr.car));
  _('*', 2, (Cell x) => multiply(x.car, x.cdr.car));
  _('<', 2, (Cell x) => compare(x.car, x.cdr.car) < 0);
  _('>', 2, (Cell x) => compare(x.car, x.cdr.car) > 0);
  _('=', 2, (Cell x) => compare(x.car, x.cdr.car) == 0);
  _('<=', 2, (Cell x) => compare(x.car, x.cdr.car) <= 0);
  _('>=', 2, (Cell x) => compare(x.car, x.cdr.car) >= 0);
  _('number?', 1, (Cell x) => isNumber(x.car));
  _('error', 2, (Cell x) => throw ErrorException(x.car, x.cdr.car));
  _('globals', 0, (Cell x) {
    Cell j;
    for (var symbol in game.environment.names) {
      j = Cell(symbol, j);
    }
    return j;
  });
  return env;
}
