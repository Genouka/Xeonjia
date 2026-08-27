import 'dart:convert';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/sprite.dart';
import 'package:flame_noise/flame_noise.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xeonjia/game/xeonjia.dart';
import 'package:xeonjia/utils/config.dart';

/// Set scheme's environment
Environment setEnvironment(XeonjiaGame game) {
  var env = Environment(game, null, null, null);
  void x(String name, int arity, IntrinsicBody fun) {
    env.defineSymbol(Sym(name), Intrinsic(name, arity, fun));
  }

  env.defineSymbol(Sym('hero'), mainCharacter.name);

  // Return [actor, value] for Cells that have a default actor
  // e.g. (move 2) and (move '(0 93))
  // PlayerOne always has id -1. So if it is not the default actor use: '(0 -1)
  List getActorAndValue(Cell? x) => (x!.car is Cell)
      ? [
          game.getComponentFromId(((x.car as Cell).cdr as Cell).car as int),
          (x.car as Cell).car,
        ]
      : [
          (env.lookForValue(Sym('actor')) as Intrinsic).fun!(x)
              as BasicComponent,
          x.car,
        ];

  // Game procedures
  x('define-symbol', 2, (Cell? x) {
    env.defineSymbol(Sym(x!.car as String), x.cdr.car);
    return #NONE;
  });
  x('get-HP', 0, (Cell? x) => game.user!.hp);
  x('get-initial-HP', 0, (Cell? x) => game.user!.maxHP);
  x('set-HP-diff', 1, (Cell? x) {
    game.user!.hpDifference((x!.car as int).toDouble());
    return #NONE;
  });
  x('set-HP-to', 1, (Cell? x) {
    game.user!.setStatus((x!.car as int).toDouble(), 0);
    return #NONE;
  });
  x('restore-HP', 0, (Cell? x) {
    game.addCustomWidgetOverlay(
      'blackCurtain',
      BlackCurtain(game, game.user!.restoreStatus),
    );
    return #NONE;
  });
  x('increase-HP', 1, (Cell? x) => game.playerOne!.maxHP += x!.car as num);
  x('get-atk', 0, (Cell? x) => game.user!.atk);
  x('increase-atk', 1, (Cell? x) => game.playerOne!.atk += x!.car as num);
  x('get-def', 0, (Cell? x) => game.user!.def);
  x('increase-def', 1, (Cell? x) => game.playerOne!.def += x!.car as num);
  x('set-money-diff', 1, (Cell? x) {
    game.playerOne!.moneyDifference(x!.car as int);
    return #NONE;
  });
  x('has-weapon', 1, (Cell? x) => game.user!.hasWeaponId(x!.car as int));
  x('set-pp-snowballs', 1, (Cell? x) {
    if (game.user!.hasWeaponId(1)) {
      game.user!.getWeaponById(1).powerPoints = (x!.car as num).toDouble();
    }
    return #NONE;
  });
  x('max-pp-snowballs', 0, (Cell? x) {
    if (!game.user!.hasWeaponId(1)) return false;
    var weapon = game.user!.getWeaponById(1);
    var max = weapon.powerPoints >= weapon.maxPp;
    weapon.restorePp();
    return max;
  });
  x('give-weapon', 1, (Cell? x) {
    game.playerOne!.weaponList.add(Weapon.fromId(x!.car as int));
    return #NONE;
  });
  x('visited-rooms', 0, (Cell? x) => mainCharacter.visitedRooms.toSet().length);
  x(
    'visited-room',
    1,
    (Cell? x) =>
        mainCharacter.visitedRooms.any((e) => e.split('/').first == x!.car),
  );
  x('last-place', 0, (Cell? x) {
    return mainCharacter.visitedRooms[mainCharacter.visitedRooms.length - 2];
  });
  x('first-time?', 0, (Cell? x) {
    return mainCharacter.visitedRooms.where((e) {
          return e.split('/').first ==
              mainCharacter.visitedRooms.last.split('/').first;
        }).length ==
        1;
  });
  x('set-team', 1, (Cell? x) {
    var actorAndValue = getActorAndValue(x);
    actorAndValue[0].teamId = actorAndValue[1];
    return #NONE;
  });
  x('add-to-players', 1, (Cell? x) {
    game.players.add(game.getComponentFromId(x!.car as int) as Walker);
    return #NONE;
  });
  x('place', 3, (Cell? x) {
    BasicComponent c =
        game.getComponentFromId(x!.car as int) ??
        (env.lookForValue(Sym('self')) as Intrinsic).fun!(x) as BasicComponent;
    c.x = x.cdr.car / 16 * componentSize;
    c.y = x.cdr.cdr.car / 16 * componentSize;
    if (c.isUser) {
      game.updateCamera(game.user!.x, game.user!.y);
    }
    return #NONE;
  });
  x('move', 1, (Cell? x) {
    var actorAndValue = getActorAndValue(x);
    Walker actor = actorAndValue[0];
    int direction = actorAndValue[1];
    actor.updateDirection(GetDirection.fromInt(direction), animated: false);
    return #NONE;
  });
  x('orientation', 0, (Cell? x) => game.user!.orientation.index);
  x(
    'opposite-orientation',
    0,
    (Cell? x) => game.user!.orientation.opposite.index,
  );
  x('set-orientation', 1, (Cell? x) {
    var actorAndValue = getActorAndValue(x);
    Walker actor = actorAndValue[0];
    int direction = actorAndValue[1];
    actor.updateOrientation(GetDirection.fromInt(direction));
    return #NONE;
  });
  x(
    'is-visible',
    1,
    (Cell? x) => game.getComponentFromId(x!.car as int)?.isVisible ?? false,
  );
  x('show', 1, (Cell? x) {
    game.getComponentFromId(x!.car as int)?.show();
    return #NONE;
  });
  x('show-me', 0, (Cell? x) {
    ((env.lookForValue(Sym('self')) as Intrinsic).fun!(x) as BasicComponent)
        .show();
    return #NONE;
  });
  x('hide', 1, (Cell? x) {
    game.getComponentFromId(x!.car as int)?.hide();
    return #NONE;
  });
  x('invert-visibility', 1, (Cell? x) {
    game.getComponentFromId(x!.car as int)!.invertVisibility();
    return #NONE;
  });
  x('delete-me-animated', 0, (Cell? x) {
    BasicComponent self =
        (env.lookForValue(Sym('self')) as Intrinsic).fun!(x) as BasicComponent;
    self.delete();
    return #NONE;
  });
  x('delete-me', 0, (Cell? x) {
    BasicComponent self =
        (env.lookForValue(Sym('self')) as Intrinsic).fun!(x) as BasicComponent;
    self.delete(silently: true);
    return #NONE;
  });
  x('delete-animated', 1, (Cell? x) {
    game.getComponentFromId(x!.car as int)?.delete();
    return #NONE;
  });
  x('delete', 1, (Cell? x) {
    game.getComponentFromId(x!.car as int)?.delete(silently: true);
    return #NONE;
  });
  x('delete-all', 1, (Cell? x) {
    var it = (x!.car as Cell).iterator;
    while (it.moveNext()) {
      game.getComponentFromId(it.current as int)?.delete(silently: true);
    }
    return #NONE;
  });
  x('respawn', 1, (Cell? x) {
    game.getComponentFromId(x!.car as int)?.respawn(game);
    return #NONE;
  });
  x('leave', 0, (Cell? x) {
    BasicComponent self =
        (env.lookForValue(Sym('self')) as Intrinsic).fun!(x) as BasicComponent;
    game.addCustomWidgetOverlay(
      'blackCurtain',
      BlackCurtain(game, () => self.delete(silently: true)),
    );
    return #NONE;
  });
  x('leave-npc', 1, (Cell? x) {
    game.addCustomWidgetOverlay(
      'blackCurtain',
      BlackCurtain(
        game,
        () => game.getComponentFromId(x!.car as int)?.delete(silently: true),
      ),
    );
    return #NONE;
  });
  x('leave-all', 1, (Cell? x) {
    game.addCustomWidgetOverlay(
      'blackCurtain',
      BlackCurtain(game, () {
        var it = (x!.car as Cell).iterator;
        while (it.moveNext()) {
          game.getComponentFromId(it.current as int)?.delete(silently: true);
        }
      }),
    );
    return #NONE;
  });
  x('is-friendly', 1, (Cell? x) {
    return (game.getComponentFromId(
      x!.car as int,
    ) as CharacterComponent).friendly;
  });
  x('friendly', 1, (Cell? x) {
    var actorAndValue = getActorAndValue(x);
    CharacterComponent actor = actorAndValue[0];
    bool friendly = actorAndValue[1];
    actor.friendly = friendly;
    return #NONE;
  });
  x('quiet', 1, (Cell? x) {
    var actorAndValue = getActorAndValue(x);
    CharacterComponent actor = actorAndValue[0];
    bool quiet = actorAndValue[1];
    actor.quiet = quiet;
    return #NONE;
  });
  x('enemies-count', 0, (Cell? x) => game.enemies);
  x('fire-event', 1, (Cell? x) {
    (x!.car as BasicComponent).executeAction();
    return #NONE;
  });
  x('fire-global-event', 0, (Cell? x) {
    for (final c in game.world.children) {
      if (c is BasicComponent) c.executeAction();
    }
    return #NONE;
  });
  x('gem-count', 0, (Cell? x) => game.playerOne!.gemCount);
  x('has-item', 1, (Cell? x) {
    return (game.playerOne == null || game.playerOne!.itemList.isEmpty
            ? mainCharacter.itemList
            : game.playerOne!.itemList)
        .contains(x!.car);
  });
  x('give-item', 1, (Cell? x) {
    game.playerOne!.addItem(x!.car as String);
    return #NONE;
  });
  x('find-item', 1, (Cell? x) {
    game.playerOne!.addItem(x!.car as String);
    return #NONE;
  });
  x('take-item', 1, (Cell? x) {
    game.playerOne!.removeItem(x!.car as String, used: false);
    return #NONE;
  });
  x('use-item', 1, (Cell? x) {
    game.playerOne!.removeItem(x!.car as String);
    return #NONE;
  });
  x('story-dialog', 1, (Cell? x) {
    game.setMessage(Message(game, stringify(x!.car, false)), hideMap: true);
    return #NONE;
  });
  x('dialog', 1, (Cell? x) {
    var it = (x!.car as Cell).iterator;
    while (it.moveNext()) {
      game.setMessage(
        (it.current as Cell).length == 1
            ? Message(
                game,
                (it.current as Cell).car as String,
                component: (env.lookForValue(Sym('actor')) as Intrinsic).fun!(
                  x,
                ) as BasicComponent,
              )
            : Message(
                game,
                (it.current as Cell).cdr.car,
                component: (env.lookForValue(Sym('actor')) as Intrinsic).fun!(
                  x,
                ) as BasicComponent,
                author: (it.current as Cell).car as String,
              ),
      );
    }
    return #NONE;
  });
  x('dialog-hide-map', 1, (Cell? x) {
    var it = (x!.car as Cell).iterator;
    while (it.moveNext()) {
      game.setMessage(
        (it.current as Cell).length == 1
            ? Message(
                game,
                (it.current as Cell).car as String,
                component: (env.lookForValue(Sym('actor')) as Intrinsic).fun!(
                  x,
                ) as BasicComponent,
              )
            : Message(
                game,
                (it.current as Cell).cdr.car,
                component: (env.lookForValue(Sym('actor')) as Intrinsic).fun!(
                  x,
                ) as BasicComponent,
                author: (it.current as Cell).car as String,
              ),
        hideMap: true,
      );
    }
    return #NONE;
  });
  x('dialog-hide-map-then-close', 1, (Cell? x) {
    var it = (x!.car as Cell).iterator;
    while (it.moveNext()) {
      game.setMessage(
        (it.current as Cell).length == 1
            ? Message(
                game,
                (it.current as Cell).car as String,
                component: (env.lookForValue(Sym('actor')) as Intrinsic).fun!(
                  x,
                ) as BasicComponent,
              )
            : Message(
                game,
                (it.current as Cell).cdr.car,
                component: (env.lookForValue(Sym('actor')) as Intrinsic).fun!(
                  x,
                ) as BasicComponent,
                author: (it.current as Cell).car as String,
              ),
        hideMap: true,
        callback: () => Navigator.pop(game.buildContext!),
      );
    }
    return #NONE;
  });
  x('dialog-kobi', 1, (Cell? x) {
    var it = (x!.car as Cell).iterator;
    while (it.moveNext()) {
      game.setMessage(
        (it.current as Cell).length == 1
            ? Message(
                game,
                (it.current as Cell).car as String,
                component: (env.lookForValue(Sym('actor')) as Intrinsic).fun!(
                  x,
                ) as BasicComponent,
                font: 'kobi',
                translate: settings.defaultFont, // transliterate?
              )
            : Message(
                game,
                (it.current as Cell).cdr.car,
                component: (env.lookForValue(Sym('actor')) as Intrinsic).fun!(
                  x,
                ) as BasicComponent,
                author: (it.current as Cell).car as String,
                font: 'kobi',
                translate: settings.defaultFont, // transliterate?
              ),
      );
    }
    return #NONE;
  });
  x('answer', 2, (Cell? x) {
    var it = (x!.cdr.car as Cell).iterator;
    while (it.moveNext()) {
      game.messageManager.answers.add(
        Answer(
          x.car.toString(),
          (it.current as Cell).car.toString(),
          (it.current as Cell).cdr,
        ),
      );
    }
    return #NONE;
  });
  x('shop', 1, (Cell? x) {
    var items = <Item>[];
    var it = (x!.car as Cell).iterator;
    while (it.moveNext()) {
      items.add(
        Item({
          'id': (it.current as Cell).car as String,
          'name': itemData[(it.current as Cell).car as String]!.rawName,
          'description':
              itemData[(it.current as Cell).car as String]!.description,
          'price': (it.current as Cell).cdr.car as int,
          'action': (it.current as Cell).cdr.cdr.car,
        }),
      );
    }
    game.pause(stopMusic: false);
    game.overlays.remove('dialogBox');
    game.shopMenu = ShopMenu(game, items);
    game.addCustomWidgetOverlay('shopMenu', game.shopMenu!);
    game.overlays.add('dialogBox');
    return #NONE;
  });
  x('hp-machine', 1, (Cell? x) {
    var items = <Item>[];
    var it = (x!.car as Cell).iterator;
    while (it.moveNext()) {
      items.add(
        Item({
          'id': (it.current as Cell).car as String,
          'name': itemData[(it.current as Cell).car as String]!.rawName,
          'description':
              itemData[(it.current as Cell).car as String]!.description,
          'price': (it.current as Cell).cdr.car as int,
          'action': (it.current as Cell).cdr.cdr.car,
        }),
      );
    }
    game.pause(stopMusic: false);
    game.overlays.remove('dialogBox');
    game.shopMenu = ShopMenu(game, items, machine: true);
    game.addCustomWidgetOverlay('shopMenu', game.shopMenu!);
    game.overlays.add('dialogBox');
    return #NONE;
  });
  x('black-curtain', 0, (Cell? x) {
    game.addCustomWidgetOverlay('blackCurtain', BlackCurtain(game));
    return #NONE;
  });
  x('remove-overlay', 1, (Cell? x) {
    game.overlays.remove(x!.car as String);
    return #NONE;
  });
  x('teleport', 1, (Cell? x) {
    game.worldMap(enable: false);
    game.miniMap(enable: false);
    game.changeRoom((x!.car as String) + '/teleport');
    return #NONE;
  });
  x('teleport-with-dialog', 2, (Cell? x) {
    game.worldMap(enable: false);
    game.miniMap(enable: false);
    game.startingDialog = x!.cdr.car as String;
    game.changeRoom((x.car as String) + '/teleport');
    return #NONE;
  });
  x('teleport-multi', 2, (Cell? x) {
    mainCharacter.visitedRooms.add(x!.car as String);
    game.changeRoom(x.cdr.car as String);
    return #NONE;
  });
  x('teleport-random', 0, (Cell? x) async {
    final Map<String, dynamic> manifestMap = json.decode(
      await rootBundle.loadString('AssetManifest.json'),
    );
    var maps = manifestMap.keys
        .where((String key) => key.contains('.tmx'))
        .map((e) => e.split('/').last)
        .toList();
    game.changeRoom(
      basenameWithoutExtension(maps[Random().nextInt(maps.length)]) +
          '/teleport',
    );
    game.setMessage(
      Message(
        game,
        'Where am I? How did I end up here?'.i18n,
        author: '/hero',
        translate: false,
      ),
    );
    return #NONE;
  });
  x('start-battle', 0, (Cell? x) {
    // this procedure MUST be used if map.startBattle == true
    game.startBattle();
    return #NONE;
  });
  x('in-battle', 0, (Cell? x) => game.inBattle);
  x('battle-rules', 0, (Cell? x) {
    game.battleRules();
    return #NONE;
  });
  x('animate', 2, (Cell? x) {
    var actorAndValue = getActorAndValue(x!.cdr as Cell);
    Walker actor = actorAndValue[0];
    int direction = actorAndValue[1];
    String animation = x.car as String;
    actor.animation = actor.atlas.getAnimation(
      '${actor.name}-$direction-$animation',
    );
    return #NONE;
  });
  x('milla-in-noleaf', 0, (Cell? x) async {
    var atlas = await game.loadCustomAtlas(
      'images/metadata/hero-and-milla.xfa',
    );
    game.playerOne!.renderHeight = 2;
    game.playerOne!.renderTranslateY = 1;
    game.playerOne!.animation = atlas.getAnimation('milla-in-noleaf');
    game.playerOne!.sprite = atlas.getSprite('hero-and-milla');
    return #NONE;
  });
  x('milla-in', 0, (Cell? x) async {
    var atlas = await game.loadCustomAtlas(
      'images/metadata/hero-and-milla.xfa',
    );
    game.playerOne!.renderHeight = 2;
    game.playerOne!.renderTranslateY = 1;
    game.playerOne!.animation = atlas.getAnimation('milla-in');
    game.playerOne!.sprite = atlas.getSprite('hero-and-milla');
    return #NONE;
  });
  x('milla-out', 0, (Cell? x) async {
    var atlas = await game.loadCustomAtlas(
      'images/metadata/hero-and-milla.xfa',
    );
    game.playerOne!.animation = atlas.getAnimation('milla-out');
    game.playerOne!.animationTicker = SpriteAnimationTicker(
      game.playerOne!.animation!,
    );
    game.playerOne!.animationTicker!.onComplete = () {
      game.playerOne!.renderHeight = 1;
      game.playerOne!.renderTranslateY = 0;
      game.playerOne!.updateOrientation();
    };
    return #NONE;
  });
  x('milla-dialog', 0, (Cell? x) {
    if (game.map.milla == null) {
      var dialogs = [
        [
          'Mitsu Forest used to be bigger, it was deforested to build Greentwig City.'
              .i18n,
        ],
        ['The Xeonjia Tower is the tallest building in the Kingdom.'.i18n],
        ['There are 3 regions in the Kingdom.'.i18n],
        [
          'If you click on a point on the world map you can travel to places you have already been.'
              .i18n,
        ],
        ['Zzz…', 'sleepy'],
        ['The world is big.'.i18n],
        ['What time is it?'.i18n],
        ["If we walk around long enough, we're sure to arrive somewhere!".i18n],
        ['How are you?'.i18n],
        ["It's cold here.".i18n],
        ['How are you?'.i18n],
        [
          "Green! Green!\nGreen is the answer, but I don't remember the question."
              .i18n,
        ],
        [
          "Ours is a strange world, it's cold here but a little warmer there."
              .i18n,
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
      game.setMessage(
        Message(game, dialog.first, author: '/milla$mood', translate: false),
      );
    } else {
      game.executeAction(
        action: game.map.milla![Random().nextInt(game.map.milla!.length)],
      );
    }
    return #NONE;
  });
  x(
    'get',
    1,
    (Cell? x) => (game.currentEventLog.containsKey(x!.car.toString()))
        ? game.currentEventLog[x.car.toString()]
        : false,
  );
  x(
    '!get', // only for boolean
    1,
    (Cell? x) => (game.currentEventLog.containsKey(x!.car.toString()))
        ? !game.currentEventLog[x.car.toString()]
        : true,
  );
  x('set', 2, (Cell? x) {
    game.currentEventLog[x!.car.toString()] = x.cdr.car;
    return #NONE;
  });
  x('set-permanent', 2, (Cell? x) {
    game.currentEventLog[x!.car.toString()] = x.cdr.car;
    mainCharacter.eventLog[x.car.toString()] = x.cdr.car;
    saveUserData();
    return #NONE;
  });
  x('map-name', 1, (Cell? x) {
    if (game.inBattle) return #NONE;
    game.map.name = stringify(x!.car, false);
    game.addCustomWidgetOverlay('mapNameBox', MapNameBox(game, below: true));
    game.add(
      TimerComponent(
        period: 3,
        removeOnFinish: true,
        onTick: () {
          if (!game.miniMapEnabled) game.overlays.remove('mapNameBox');
        },
      ),
    );
    return #NONE;
  });
  x('music', 1, (Cell? x) {
    if (settings.backgroundMusic) {
      game.playBackgroundMusic(custom: x!.car as String);
    }
    return #NONE;
  });
  x('disable-world-map', 0, (Cell? x) {
    game.map.disableWorldMap = true;
    return #NONE;
  });
  x('give-leaf', 0, (Cell? x) {
    game.overlays.remove('leafButton');
    game.overlays.add('leafButton');
    return #NONE;
  });
  x('remove-story-button', 0, (Cell? x) {
    game.overlays.remove('skipButton');
    game.map.skipStory = null;
    return #NONE;
  });
  x('earthquake', 0, (Cell? x) {
    game.camera.viewfinder.add(
      MoveEffect.by(
        Vector2(5, 5),
        NoiseEffectController(duration: 4, noise: PerlinNoise(frequency: 400)),
      ),
    );
    return #NONE;
  });
  x('king-of-evil-out', 1, (Cell? x) async {
    var atlas = await game.loadCustomAtlas('images/metadata/tower.xfa');
    var component = game.getComponentFromId(x!.car as int);
    component?.animation = atlas.getAnimation('king-of-evil-out');
    component?.animationTicker = SpriteAnimationTicker(component.animation!);
    component?.animationTicker!.onComplete = () =>
        component.delete(silently: true);
    return #NONE;
  });
  x('the-end', 0, (Cell? x) {
    mainCharacter.eventLog = Map.from(game.currentEventLog);
    mainCharacter.eventLog['the-end'] = true;
    mainCharacter.eventLog['${game.map.id}-safe'] = true;
    mainCharacter.itemList = List.from(game.playerOne!.itemList);
    mainCharacter.visitedRooms.addAll(['0', '1_home_2']);
    mainCharacter.currentHP = game.playerOne!.maxHP;
    mainCharacter.money = game.playerOne!.money;
    mainCharacter.minutesPlayed += game.elapsed / 60;
    mainCharacter.movesCounter += game.playerOne!.movesCounter;
    saveUserData();
    // i18n: "And that's it.\nWe have now reached the end of this fantastic adventure!\nYour determination and courage made this victory possible.\nKeep exploring, dreaming and being the hero the world needs, because your adventures will never end.\nWhere will your next journey take you?\nThank you for playing Xeonjia!\nMaybe our paths will cross again.".i18n
    // i18n: 'Bye!'.i18n
    game.executeAction(
      action: r'''
    (begin
      (music "finale")
      (dialog-hide-map-then-close
        '(("the-end/book" "And that's it.\nWe have now reached the end of this fantastic adventure!\nYour determination and courage made this victory possible.\nKeep exploring, dreaming and being the hero the world needs, because your adventures will never end.\nWhere will your next journey take you?\nThank you for playing Xeonjia!\nMaybe our paths will cross again.")
        ("/milla_happy" "Bye!"))))''',
    );
    return #NONE;
  });
  x('shot-snowball', 1, (Cell? x) {
    SnowBallWeapon(level: -5, powerPoints: 999).shoot(
      shooter: game.getComponentFromId(x!.car as int) as CharacterComponent,
      forced: true,
    );
    return #NONE;
  });
  x('get-inspect-key', 0, (Cell? x) => game.inspectButtonKey);
  x('get-snowball-key', 0, (Cell? x) => game.snowballButtonKey);
  x('get-mine-key', 0, (Cell? x) => game.mineButtonKey);
  x('hide-donation-worker', 0, (Cell? x) => Config.hideDonationWorker);
  x(
    'donation-page',
    0,
    (Cell? x) => launchUrl(
      Uri.parse(Config.donateUrl),
      mode: LaunchMode.externalApplication,
    ),
  );

  // Built-in procedures
  x('car', 1, (Cell? x) => (x!.car as Cell).car!);
  x('cdr', 1, (Cell? x) => (x!.car as Cell).cdr);
  x('cons', 2, (Cell? x) => Cell(x!.car, x.cdr.car));
  x('eq?', 2, (Cell? x) => identical(x!.car, x.cdr.car));
  x('==', 2, (Cell? x) => (x!.car as String) == (x.cdr.car as String));
  x('pair?', 1, (Cell? x) => x!.car is Cell);
  x('null?', 1, (Cell? x) => x!.car == null);
  x('not', 1, (Cell? x) => x!.car == false);
  x('!', 1, (Cell? x) => x!.car == false);
  x('list', -1, (Cell? x) => x!);
  x('eof-object?', 1, (Cell? x) => x!.car == #EOF);
  x('symbol?', 1, (Cell? x) => x!.car is Sym);

  env.defineSymbol(callccSym, #CALLCC);
  env.defineSymbol(applySym, #APPLY);

  x('and', 2, (Cell? x) => (x!.car as bool) && x.cdr.car);
  x('or', 2, (Cell? x) => (x!.car as bool) || x.cdr.car);
  x('+', 2, (Cell? x) => add(x!.car!, x.cdr.car));
  x('-', 2, (Cell? x) => subtract(x!.car!, x.cdr.car));
  x('*', 2, (Cell? x) => multiply(x!.car!, x.cdr.car));
  x('<', 2, (Cell? x) => compare(x!.car!, x.cdr.car) < 0);
  x('>', 2, (Cell? x) => compare(x!.car!, x.cdr.car) > 0);
  x('=', 2, (Cell? x) => compare(x!.car!, x.cdr.car) == 0);
  x('<=', 2, (Cell? x) => compare(x!.car!, x.cdr.car) <= 0);
  x('>=', 2, (Cell? x) => compare(x!.car!, x.cdr.car) >= 0);
  x('number?', 1, (Cell? x) => isNumber(x!.car!));
  x('error', 2, (Cell? x) => throw ErrorException(x!.car!, x.cdr.car));
  x('globals', 0, (Cell? x) {
    late Cell j;
    for (final symbol in game.environment.names) {
      j = Cell(symbol, j);
    }
    return j;
  });
  return env;
}
