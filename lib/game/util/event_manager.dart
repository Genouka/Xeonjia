import 'dart:io';

import 'package:xeonjia/game/components/abstract_basic.dart';
import 'package:xeonjia/game/components/abstract_dynamic.dart';
import 'package:xeonjia/game/widgets_overlay/map_box.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/direction.dart';
import 'package:xeonjia/models/message.dart';
import 'package:xeonjia/util/little_scheme.dart';
import 'package:xeonjia/util/local_data_controller.dart';

// Set scheme's environment
Environment setEnvironment() {
  var env = Environment(null, null, null);
  var _ = (String name, int arity, IntrinsicBody fun) {
    env.defineSymbol(Sym(name), Intrinsic(name, arity, fun));
  };

  // Game procedures
  _('get-life', 0, (Cell x) => game.playerOne.lifePoints);
  _('set-life-diff', 1, (Cell x) => game.playerOne.lifePointsDifference(x.car));
  _('increase-life', 1, (Cell x) => game.playerOne.initialLifePoints += x.car);
  _('increase-atk', 1, (Cell x) => game.playerOne.atk += x.car);
  _('increase-def', 1, (Cell x) => game.playerOne.def += x.car);
  _('places-visited', 0, (Cell x) => mainCharacter.visitedRooms.length);
  _(
      'last-place',
      0,
      (Cell x) =>
          mainCharacter.visitedRooms[mainCharacter.visitedRooms.length - 2]);
  _(
      'move',
      1,
      (Cell x) => (env.lookForValue(Sym('actor')) as BasicComponent).x +=
          componentSize);
  _(
      'set-orientation',
      1,
      (Cell x) => (env.lookForValue(Sym('actor')) as DynamicComponent)
          .orientation = GetDirection.fromInt(x.car));
  _('event-change', 1, (Cell x) => (x.car as BasicComponent).executeAction());
  _('has-item', 1, (Cell x) => game.playerOne.itemList.contains(x.car));
  _('give-item', 1, (Cell x) => game.playerOne.addItem(x.car));
  _('take-item', 1, (Cell x) => game.playerOne.removeItem(x.car));
  _('story-dialog', 1, (Cell x) {
    game.setMessage(Message(stringify(x.car, false)), hideMap: true);
    return #NONE;
  });
  _('dialog', 1, (Cell x) {
    var it = (x.car as Cell).iterator;
    while (it.moveNext()) {
      game.setMessage((it.current as Cell).length == 1
          ? Message((it.current as Cell).car)
          : Message((it.current as Cell).cdr.car, (it.current as Cell).car));
    }
    return #NONE;
  });
  _(
    'get',
    1,
    (Cell x) => (game.currentEventLog.containsKey(x.car.toString()))
        ? game.currentEventLog[x.toString()]
        : false,
  );
  _('set', 2, (Cell x) {
    game.currentEventLog[x.car.toString()] = x.cdr.car;
    return #NONE;
  });
  _('map-name', 1, (Cell x) {
    game.addWidgetOverlay('mapBox', MapBox(stringify(x.car, false)));
    var _id = mainCharacter.visitedRooms.length;
    Future.delayed(const Duration(seconds: 3), () {
      if (_id == mainCharacter.visitedRooms.length) {
        game?.removeWidgetOverlay('mapBox');
      }
    });
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
  _('newline', 0, (Cell x) {
    stdout.writeln();
    return #NONE;
  });
  _('eof-object?', 1, (Cell x) => x.car == #EOF);
  _('symbol?', 1, (Cell x) => x.car is Sym);

  env.defineSymbol(callccSym, #CALLCC);
  env.defineSymbol(applySym, #APPLY);

  _('+', 2, (Cell x) => add(x.car, x.cdr.car));
  _('-', 2, (Cell x) => subtract(x.car, x.cdr.car));
  _('*', 2, (Cell x) => multiply(x.car, x.cdr.car));
  _('<', 2, (Cell x) => compare(x.car, x.cdr.car) < 0);
  _('>', 2, (Cell x) => compare(x.car, x.cdr.car) > 0);
  _('=', 2, (Cell x) => compare(x.car, x.cdr.car) == 0);
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
