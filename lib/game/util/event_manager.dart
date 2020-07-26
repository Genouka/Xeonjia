import 'dart:io';

import 'package:xeonjia/game/components/abstract_basic.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/message.dart';
import 'package:xeonjia/util/little_scheme.dart';

// Scheme's global environment
Environment globalEnv = (() {
  var env = Environment(null, null, null);
  var _ = (String name, int arity, IntrinsicBody fun) {
    env.defineSymbol(Sym(name), Intrinsic(name, arity, fun));
  };

  // Game procedures
  _('life', 0, (Cell x) => playerOne.lifePoints);
  _('move', 1, (Cell x) => (x.car as BasicComponent).x += componentSize);
  _('event-change', 1, (Cell x) => (x.car as BasicComponent).eventChanged());
  _('has-object', 1, (Cell x) => playerOne.objectList.contains(x.car));
  _('give-object', 1, (Cell x) => playerOne.addObject(x.car));
  _('take-object', 1, (Cell x) => playerOne.removeObject(x.car));
  _('dialog', 1, (Cell x) {
    game.setMessage(Message(stringify(x.car, false)));
    return #NONE;
  });
  _('dialogs', 1, (Cell x) {
    var it = (x.car as Cell).iterator;
    while (it.moveNext()) {
      game.setMessage(
          Message((it.current as Cell).cdr.car, (it.current as Cell).car));
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
  _('=', 2, (Cell x) => compare(x.car, x.cdr.car) == 0);
  _('number?', 1, (Cell x) => isNumber(x.car));
  _('error', 2, (Cell x) => throw ErrorException(x.car, x.cdr.car));
  _('globals', 0, (Cell x) {
    Cell j;
    for (var symbol in globalEnv.names) {
      j = Cell(symbol, j);
    }
    return j;
  });
  return env;
})();
