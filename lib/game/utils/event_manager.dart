import 'dart:math';

import 'package:flame/components.dart';
import 'package:xeonjia/game/xeonjia.dart';

/// Set scheme's environment
Environment setEnvironment(XeonjiaGame gameRef) {
  var env = Environment(gameRef, null, null, null);
  void _(String name, int arity, IntrinsicBody fun) {
    env.defineSymbol(Sym(name), Intrinsic(name, arity, fun));
  }

  env.defineSymbol(Sym('hero'), mainCharacter.name);

  // Return [actor, value] for Cells that have a default actor
  // e.g. (move 2) and (move '(0 93))
  // PlayerOne always has id -1. So if it is not the default actor use: '(0 -1)
  List getActorAndValue(Cell? x) => (x!.car is Cell)
      ? [
          gameRef.getComponentFromId(((x.car as Cell).cdr as Cell).car as int),
          (x.car as Cell).car
        ]
      : [
          (env.lookForValue(Sym('actor')) as Intrinsic).fun!(x)
              as BasicComponent,
          x.car
        ];

  // Game procedures
  _('define-symbol', 2, (Cell? x) {
    env.defineSymbol(Sym(x!.car as String), x.cdr.car);
    return #NONE;
  });
  _('get-HP', 0, (Cell? x) => gameRef.user!.hp);
  _('get-initial-HP', 0, (Cell? x) => gameRef.user!.maxHP);
  _('set-HP-diff', 1, (Cell? x) {
    gameRef.user!.hpDifference((x!.car as int).toDouble());
    return #NONE;
  });
  _('set-HP-to', 1, (Cell? x) {
    gameRef.user!.setStatus((x!.car as int).toDouble(), 0);
    return #NONE;
  });
  _('restore-HP', 0, (Cell? x) {
    gameRef.addCustomWidgetOverlay(
        'blackCurtain', BlackCurtain(gameRef, gameRef.user!.restoreStatus));
    return #NONE;
  });
  _('increase-HP', 1, (Cell? x) => gameRef.playerOne!.maxHP += x!.car as num);
  _('get-atk', 0, (Cell? x) => gameRef.user!.atk);
  _('increase-atk', 1, (Cell? x) => gameRef.playerOne!.atk += x!.car as num);
  _('get-def', 0, (Cell? x) => gameRef.user!.def);
  _('increase-def', 1, (Cell? x) => gameRef.playerOne!.def += x!.car as num);
  _('set-money-diff', 1, (Cell? x) {
    gameRef.playerOne!.moneyDifference(x!.car as int);
    return #NONE;
  });
  _('has-weapon', 1, (Cell? x) => gameRef.user!.hasWeaponId(x!.car as int));
  _('set-pp-snowballs', 1, (Cell? x) {
    if (gameRef.user!.hasWeaponId(1)) {
      gameRef.user!.getWeaponById(1).powerPoints = (x!.car as num).toDouble();
    }
    return #NONE;
  });
  _('max-pp-snowballs', 0, (Cell? x) {
    if (!gameRef.user!.hasWeaponId(1)) return false;
    var weapon = gameRef.user!.getWeaponById(1);
    var max = weapon.powerPoints >= weapon.maxPp;
    weapon.restorePp();
    return max;
  });
  _('give-weapon', 1, (Cell? x) {
    gameRef.playerOne!.weaponList.add(Weapon.fromId(x!.car as int));
    return #NONE;
  });
  _('places-visited', 0,
      (Cell? x) => mainCharacter.visitedRooms.toSet().length);
  _(
      'has-been-here',
      1,
      (Cell? x) =>
          mainCharacter.visitedRooms.any((e) => e.split('/').first == x!.car));
  _('last-place', 0, (Cell? x) {
    return mainCharacter.visitedRooms[mainCharacter.visitedRooms.length - 2];
  });
  _('first-time?', 0, (Cell? x) {
    return mainCharacter.visitedRooms.where((e) {
          return e.split('/').first ==
              mainCharacter.visitedRooms.last.split('/').first;
        }).length ==
        1;
  });
  _('set-team', 1, (Cell? x) {
    var actorAndValue = getActorAndValue(x);
    actorAndValue[0].teamId = actorAndValue[1];
    return #NONE;
  });
  _('add-to-players', 1, (Cell? x) {
    gameRef.players.add(gameRef.getComponentFromId(x!.car as int) as Walker);
    return #NONE;
  });
  _('place', 3, (Cell? x) {
    BasicComponent c = gameRef.getComponentFromId(x!.car as int) ??
        (env.lookForValue(Sym('self')) as Intrinsic).fun!(x) as BasicComponent;
    c.x = x.cdr.car / 16 * componentSize;
    c.y = x.cdr.cdr.car / 16 * componentSize;
    if (c.isUser) {
      gameRef.updateCamera(gameRef.user!.x, gameRef.user!.y);
    }
    return #NONE;
  });
  _('move', 1, (Cell? x) {
    var actorAndValue = getActorAndValue(x);
    Walker actor = actorAndValue[0];
    int direction = actorAndValue[1];
    actor.updateDirection(GetDirection.fromInt(direction), animated: false);
    return #NONE;
  });
  _('orientation', 0, (Cell? x) => gameRef.user!.orientation.index);
  _('set-orientation', 1, (Cell? x) {
    var actorAndValue = getActorAndValue(x);
    Walker actor = actorAndValue[0];
    int direction = actorAndValue[1];
    actor.updateOrientation(GetDirection.fromInt(direction));
    return #NONE;
  });
  _(
      'is-visible',
      1,
      (Cell? x) =>
          gameRef.getComponentFromId(x!.car as int)?.isVisible ?? false);
  _('show', 1, (Cell? x) {
    gameRef.getComponentFromId(x!.car as int)?.show();
    return #NONE;
  });
  _('show-me', 0, (Cell? x) {
    ((env.lookForValue(Sym('self')) as Intrinsic).fun!(x) as BasicComponent)
        .show();
    return #NONE;
  });
  _('hide', 1, (Cell? x) {
    gameRef.getComponentFromId(x!.car as int)?.hide();
    return #NONE;
  });
  _('invert-visibility', 1, (Cell? x) {
    gameRef.getComponentFromId(x!.car as int)!.invertVisibility();
    return #NONE;
  });
  _('delete-me-animated', 0, (Cell? x) {
    BasicComponent self =
        (env.lookForValue(Sym('self')) as Intrinsic).fun!(x) as BasicComponent;
    self.delete();
    return #NONE;
  });
  _('delete-me', 0, (Cell? x) {
    BasicComponent self =
        (env.lookForValue(Sym('self')) as Intrinsic).fun!(x) as BasicComponent;
    self.delete(silently: true);
    return #NONE;
  });
  _('delete-animated', 1, (Cell? x) {
    gameRef.getComponentFromId(x!.car as int)?.delete();
    return #NONE;
  });
  _('delete', 1, (Cell? x) {
    gameRef.getComponentFromId(x!.car as int)?.delete(silently: true);
    return #NONE;
  });
  _('delete-all', 1, (Cell? x) {
    var it = (x!.car as Cell).iterator;
    while (it.moveNext()) {
      gameRef.getComponentFromId(it.current as int)?.delete(silently: true);
    }
    return #NONE;
  });
  _('respawn', 1, (Cell? x) {
    gameRef.getDeletedComponentFromId(x!.car as int).respawn(gameRef);
    return #NONE;
  });
  _('leave', 0, (Cell? x) {
    BasicComponent self =
        (env.lookForValue(Sym('self')) as Intrinsic).fun!(x) as BasicComponent;
    gameRef.addCustomWidgetOverlay('blackCurtain',
        BlackCurtain(gameRef, () => self.delete(silently: true)));
    return #NONE;
  });
  _('leave-npc', 1, (Cell? x) {
    gameRef.addCustomWidgetOverlay(
        'blackCurtain',
        BlackCurtain(
            gameRef,
            () => gameRef
                .getComponentFromId(x!.car as int)
                ?.delete(silently: true)));
    return #NONE;
  });
  _('leave-all', 1, (Cell? x) {
    gameRef.addCustomWidgetOverlay(
        'blackCurtain',
        BlackCurtain(gameRef, () {
          var it = (x!.car as Cell).iterator;
          while (it.moveNext()) {
            gameRef
                .getComponentFromId(it.current as int)
                ?.delete(silently: true);
          }
        }));
    return #NONE;
  });
  _('is-friendly', 1, (Cell? x) {
    return (gameRef.getComponentFromId(x!.car as int) as CharacterComponent)
        .friendly;
  });
  _('friendly', 1, (Cell? x) {
    var actorAndValue = getActorAndValue(x);
    CharacterComponent actor = actorAndValue[0];
    bool friendly = actorAndValue[1];
    actor.friendly = friendly;
    return #NONE;
  });
  _('quiet', 1, (Cell? x) {
    var actorAndValue = getActorAndValue(x);
    CharacterComponent actor = actorAndValue[0];
    bool quiet = actorAndValue[1];
    actor.quiet = quiet;
    return #NONE;
  });
  _('enemies-count', 0, (Cell? x) => gameRef.enemies);
  _('fire-event', 1, (Cell? x) {
    (x!.car as BasicComponent).executeAction();
    return #NONE;
  });
  _('fire-global-event', 0, (Cell? x) {
    for (final c in gameRef.children) {
      if (c is BasicComponent) c.executeAction();
    }
    return #NONE;
  });
  _('gem-count', 0, (Cell? x) => gameRef.playerOne!.gemCount);
  _('has-item', 1, (Cell? x) {
    return (gameRef.playerOne == null || gameRef.playerOne!.itemList.isEmpty
            ? mainCharacter.itemList
            : gameRef.playerOne!.itemList)
        .contains(x!.car);
  });
  _('give-item', 1, (Cell? x) {
    gameRef.playerOne!.addItem(x!.car as String);
    return #NONE;
  });
  _('find-item', 1, (Cell? x) {
    gameRef.playerOne!.addItem(x!.car as String);
    return #NONE;
  });
  _('take-item', 1, (Cell? x) {
    gameRef.playerOne!.removeItem(x!.car as String, used: false);
    return #NONE;
  });
  _('use-item', 1, (Cell? x) {
    gameRef.playerOne!.removeItem(x!.car as String);
    return #NONE;
  });
  _('story-dialog', 1, (Cell? x) {
    gameRef.setMessage(Message(gameRef, stringify(x!.car, false)),
        hideMap: true);
    return #NONE;
  });
  _('dialog', 1, (Cell? x) {
    var it = (x!.car as Cell).iterator;
    while (it.moveNext()) {
      gameRef.setMessage((it.current as Cell).length == 1
          ? Message(gameRef, (it.current as Cell).car as String,
              component: (env.lookForValue(Sym('actor')) as Intrinsic).fun!(x)
                  as BasicComponent)
          : Message(gameRef, (it.current as Cell).cdr.car,
              component: (env.lookForValue(Sym('actor')) as Intrinsic).fun!(x)
                  as BasicComponent,
              author: (it.current as Cell).car as String));
    }
    return #NONE;
  });
  _('dialog-kobi', 1, (Cell? x) {
    var it = (x!.car as Cell).iterator;
    while (it.moveNext()) {
      gameRef.setMessage((it.current as Cell).length == 1
          ? Message(
              gameRef,
              (it.current as Cell).car as String,
              component: (env.lookForValue(Sym('actor')) as Intrinsic).fun!(x)
                  as BasicComponent,
              font: 'kobi',
              translate: settings.defaultFont, // transliterate?
            )
          : Message(
              gameRef,
              (it.current as Cell).cdr.car,
              component: (env.lookForValue(Sym('actor')) as Intrinsic).fun!(x)
                  as BasicComponent,
              author: (it.current as Cell).car as String,
              font: 'kobi',
              translate: settings.defaultFont, // transliterate?
            ));
    }
    return #NONE;
  });
  _('answer', 2, (Cell? x) {
    var it = (x!.cdr.car as Cell).iterator;
    while (it.moveNext()) {
      gameRef.messageManager.answers.add(Answer(x.car.toString(),
          (it.current as Cell).car.toString(), (it.current as Cell).cdr));
    }
    return #NONE;
  });
  _('shop', 1, (Cell? x) {
    var items = <Item>[];
    var it = (x!.car as Cell).iterator;
    while (it.moveNext()) {
      items.add(Item({
        'id': (it.current as Cell).car as String,
        'name': itemData[(it.current as Cell).car as String]!.rawName,
        'description':
            itemData[(it.current as Cell).car as String]!.description,
        'price': (it.current as Cell).cdr.car as int,
        'action': (it.current as Cell).cdr.cdr.car,
      }));
    }
    gameRef.pause(stopMusic: false);
    gameRef.overlays.remove('dialogBox');
    gameRef.shopMenu = ShopMenu(gameRef, items);
    gameRef.addCustomWidgetOverlay('shopMenu', gameRef.shopMenu!);
    gameRef.overlays.add('dialogBox');
    return #NONE;
  });
  _('black-curtain', 0, (Cell? x) {
    gameRef.addCustomWidgetOverlay('blackCurtain', BlackCurtain(gameRef));
    return #NONE;
  });
  _('remove-overlay', 1, (Cell? x) {
    gameRef.overlays.remove(x!.car as String);
    return #NONE;
  });
  _('teleport', 1, (Cell? x) {
    gameRef.worldMap(enable: false);
    gameRef.miniMap(enable: false);
    gameRef.changeRoom((x!.car as String) + '/teleport');
    return #NONE;
  });
  _('teleport-multi', 2, (Cell? x) {
    mainCharacter.visitedRooms.add(x!.car as String);
    gameRef.changeRoom(x.cdr.car as String);
    return #NONE;
  });
  _('start-battle', 0, (Cell? x) {
    // this procedure MUST be used if map.startBattle == true
    gameRef.startBattle();
    return #NONE;
  });
  _('battle-rules', 0, (Cell? x) {
    gameRef.battleRules();
    return #NONE;
  });
  _('animate', 2, (Cell? x) {
    var actorAndValue = getActorAndValue(x!.cdr as Cell);
    Walker actor = actorAndValue[0];
    int direction = actorAndValue[1];
    String animation = x.car as String;
    actor.animation =
        actor.atlas.getAnimation('${actor.name}-$direction-$animation');
    return #NONE;
  });
  _('milla-in-noleaf', 0, (Cell? x) async {
    var atlas =
        await gameRef.loadCustomAtlas('images/metadata/hero-and-milla.xfa');
    gameRef.playerOne!.renderHeight = 2;
    gameRef.playerOne!.renderTranslateY = 1;
    gameRef.playerOne!.animation = atlas.getAnimation('milla-in-noleaf');
    gameRef.playerOne!.sprite = atlas.getSprite('hero-and-milla');
    return #NONE;
  });
  _('milla-in', 0, (Cell? x) async {
    var atlas =
        await gameRef.loadCustomAtlas('images/metadata/hero-and-milla.xfa');
    gameRef.playerOne!.renderHeight = 2;
    gameRef.playerOne!.renderTranslateY = 1;
    gameRef.playerOne!.animation = atlas.getAnimation('milla-in');
    gameRef.playerOne!.sprite = atlas.getSprite('hero-and-milla');
    return #NONE;
  });
  _('milla-out', 0, (Cell? x) async {
    var atlas =
        await gameRef.loadCustomAtlas('images/metadata/hero-and-milla.xfa');
    gameRef.playerOne!.animation = atlas.getAnimation('milla-out');
    gameRef.playerOne!.animation!.onComplete = () {
      gameRef.playerOne!.renderHeight = 1;
      gameRef.playerOne!.renderTranslateY = 0;
      gameRef.playerOne!.updateOrientation();
    };
    return #NONE;
  });
  _('random-milla-dialog', 0, (Cell? x) {
    if (gameRef.map.milla == null) {
      var dialogs = [
        [
          'Mitsu Forest used to be bigger, it was deforested to build Melhopolis.'
              .i18n
        ],
        ['The Xeonjia Tower is the tallest building in the Kingdom.'.i18n],
        ['There are 3 regions in the Kingdom.'.i18n],
        [
          'If you click on a point on the world map you can travel to places you have already been.'
              .i18n
        ],
        ['Zzz…', 'sleepy'],
        ['The world is big.'.i18n],
        ['What time is it?'.i18n],
        ["If we walk around long enough, we're sure to arrive somewhere!".i18n],
        ['How are you?'.i18n],
        ["It's cold here.".i18n],
        ['How are you?'.i18n],
        [
          "'Green! Green!\nGreen is the answer, but I don't remember the question.'"
              .i18n
        ],
        [
          "Ours is a strange world, it's cold here but a little warmer there."
              .i18n
        ],
        ['I have to stop eating ice cream before bed.'.i18n],
        ['I know many languages.'.i18n + ' Lo sai?'],
        ['I know many languages.'.i18n + ' ¿Lo sabes?'],
        ['I know many languages.'.i18n + ' Sa tead seda?'],
        ['Hey!'.i18n],
        ['Here I am.'.i18n],
        ['Leave me alone.'.i18n],
        ['Do you believe in fairies??'.i18n],
        ['What do piglets dream about?'.i18n],
        ['I am hungryyy.'.i18n],
      ];
      var dialog = dialogs[Random().nextInt(dialogs.length)];
      var mood = dialog.length > 1 ? '_${dialog.last}' : '';
      gameRef.setMessage(Message(
        gameRef,
        dialog.first,
        author: '/milla$mood',
        translate: false,
      ));
    } else {
      gameRef.executeAction(
          action:
              gameRef.map.milla![Random().nextInt(gameRef.map.milla!.length)]);
    }
    return #NONE;
  });
  _(
    'get',
    1,
    (Cell? x) => (gameRef.currentEventLog.containsKey(x!.car.toString()))
        ? gameRef.currentEventLog[x.car.toString()]
        : false,
  );
  _(
    '!get', // only for boolean
    1,
    (Cell? x) => (gameRef.currentEventLog.containsKey(x!.car.toString()))
        ? !gameRef.currentEventLog[x.car.toString()]
        : true,
  );
  _('set', 2, (Cell? x) {
    gameRef.currentEventLog[x!.car.toString()] = x.cdr.car;
    return #NONE;
  });
  _('map-name', 1, (Cell? x) {
    gameRef.map.name = stringify(x!.car, false);
    gameRef.addCustomWidgetOverlay(
        'mapNameBox', MapNameBox(gameRef, below: true));
    gameRef.add(TimerComponent(
      period: 3,
      removeOnFinish: true,
      onTick: () {
        if (!gameRef.miniMapEnabled) gameRef.overlays.remove('mapNameBox');
      },
    ));
    return #NONE;
  });
  _('music', 1, (Cell? x) {
    if (settings.backgroundMusic) {
      gameRef.playBackgroundMusic(custom: x!.car as String);
    }
    return #NONE;
  });
  _('give-leaf', 0, (Cell? x) {
    gameRef.overlays.remove('leafButton');
    gameRef.overlays.add('leafButton');
    return #NONE;
  });

  // Built-in procedures
  _('car', 1, (Cell? x) => (x!.car as Cell).car!);
  _('cdr', 1, (Cell? x) => (x!.car as Cell).cdr);
  _('cons', 2, (Cell? x) => Cell(x!.car, x.cdr.car));
  _('eq?', 2, (Cell? x) => identical(x!.car, x.cdr.car));
  _('==', 2, (Cell? x) => (x!.car as String) == (x.cdr.car as String));
  _('pair?', 1, (Cell? x) => x!.car is Cell);
  _('null?', 1, (Cell? x) => x!.car == null);
  _('not', 1, (Cell? x) => x!.car == false);
  _('!', 1, (Cell? x) => x!.car == false);
  _('list', -1, (Cell? x) => x!);
  _('eof-object?', 1, (Cell? x) => x!.car == #EOF);
  _('symbol?', 1, (Cell? x) => x!.car is Sym);

  env.defineSymbol(callccSym, #CALLCC);
  env.defineSymbol(applySym, #APPLY);

  _('and', 2, (Cell? x) => (x!.car as bool) && x.cdr.car);
  _('or', 2, (Cell? x) => (x!.car as bool) || x.cdr.car);
  _('+', 2, (Cell? x) => add(x!.car!, x.cdr.car));
  _('-', 2, (Cell? x) => subtract(x!.car!, x.cdr.car));
  _('*', 2, (Cell? x) => multiply(x!.car!, x.cdr.car));
  _('<', 2, (Cell? x) => compare(x!.car!, x.cdr.car) < 0);
  _('>', 2, (Cell? x) => compare(x!.car!, x.cdr.car) > 0);
  _('=', 2, (Cell? x) => compare(x!.car!, x.cdr.car) == 0);
  _('<=', 2, (Cell? x) => compare(x!.car!, x.cdr.car) <= 0);
  _('>=', 2, (Cell? x) => compare(x!.car!, x.cdr.car) >= 0);
  _('number?', 1, (Cell? x) => isNumber(x!.car!));
  _('error', 2, (Cell? x) => throw ErrorException(x!.car!, x.cdr.car));
  _('globals', 0, (Cell? x) {
    late Cell j;
    for (final symbol in gameRef.environment.names) {
      j = Cell(symbol, j);
    }
    return j;
  });
  return env;
}
