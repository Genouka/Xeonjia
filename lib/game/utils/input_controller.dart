import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flame/extensions.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xeonjia/game/xeonjia.dart';

/// Handle user input
extension InputController on XeonjiaGame {
  String get inspectButtonKey =>
      Platform.isLinux || Platform.isWindows ? 'X' : 'A';
  String get punchButtonKey =>
      Platform.isLinux || Platform.isWindows ? 'Q' : 'P';
  String get snowballButtonKey => Platform.isLinux || Platform.isWindows
      ? 'Snowball (%s)'.i18n.fill(['E'])
      : 'Snowball'.i18n;
  String get mineButtonKey => Platform.isLinux || Platform.isWindows
      ? 'Mine (%s)'.i18n.fill(['R'])
      : 'Mine'.i18n;

  static Direction? _gesturesDirection;
  static double _gesturesElapsed = 0;
  static bool _gesturesPlayerMoved = false;
  static String _gesturesMapId = '';

  /// Handle pan start event
  void panStartHandler(DragStartInfo info) {
    _gesturesElapsed = 1;
    _gesturesMapId = map.id;
  }

  /// Handle pan update event
  void panUpdateHandler(DragUpdateInfo info) async {
    if (longPressMoving ||
        (elapsed > longPressTime + 1 &&
            longPressButton != null &&
            longPressButton ==
                children.firstWhereOrNull((e) =>
                    e is Button &&
                    e.containsPoint(info.eventPosition.widget)))) {
      longPressMoving = true;
      settings.buttonsOffset = Offset(
          settings.buttonsOffset.dx - info.raw.delta.dx,
          settings.buttonsOffset.dy - info.raw.delta.dy);
      for (final component in children) {
        if (component is Button) component.updatePosition();
      }
      return;
    }
    if (settings.showDPad && !miniMapEnabled) return;
    if (isNotPaused) {
      _gesturesDirection = GetDirection.fromOffset(
          info.raw.delta.dx.abs() > info.raw.delta.dy.abs()
              ? Offset(info.raw.delta.dx, 0)
              : Offset(0, info.raw.delta.dy));
      if (_gesturesElapsed > 0) {
        if (!_gesturesPlayerMoved) {
          _gesturesPlayerMoved = true;
          movePlayer(_gesturesDirection!);
        }
        return;
      }
      while (_gesturesDirection != null &&
          isNotPaused &&
          _gesturesMapId == map.id) {
        movePlayer(_gesturesDirection!, slow: true);
        await Future.delayed(const Duration(milliseconds: 50));
      }
    } else if (miniMapEnabled) {
      camera.snapTo(Vector2(
          moveCamera(size.x, map.width,
              camera.position.x - info.raw.delta.dx + size.x / 2),
          moveCamera(size.y, worldMapEnabled ? map.width * 0.7 : map.height,
              camera.position.y - info.raw.delta.dy + size.y / 2)));
    }
  }

  /// Handle pan end event
  void panEndHandler(DragEndInfo info) => panCancelHandler();

  /// Handle pan cancel event
  void panCancelHandler() {
    _gesturesDirection = null;
    _gesturesPlayerMoved = false;
    longPressTime = double.infinity;
  }

  /// Handle tap up event
  void tapUpHandler(int pointerId, TapUpInfo info) {
    messageManager.isActive
        ? dialogBox.state!.next()
        : _tapHandler(info.raw.globalPosition);
  }

  /// Handle tap gesture
  void _tapHandler(Offset position) {
    if (isPaused ||
        !(user?.isMyTurn ?? false) ||
        children
            .any((e) => e is Button && e.containsPoint(position.toVector2()))) {
      return;
    }

    // Ignore tap near buttons (top left)
    var topLeftSize = children.whereType<HideHintsButton>().firstOrNull?.size ??
        Vector2.zero();
    if (position.dx < topLeftSize.x && position.dy < topLeftSize.y * 2 + 20) {
      return;
    }

    // Update orientation
    var relativeTapX =
        position.dx - (user!.x + componentSize / 2 - camera.position.x);
    var relativeTapY =
        position.dy - (user!.y + componentSize / 2 - camera.position.y);

    if (position.dx < componentSize || position.dx > size.x - componentSize) {
      user!.updateOrientation(
          GetDirection.fromXY(position.dx - componentSize, 0));
    } else if (position.dy < componentSize ||
        position.dy > size.y - componentSize) {
      user!.updateOrientation(
          GetDirection.fromXY(0, position.dy - componentSize));
    } else if (relativeTapX.abs() > 15 || relativeTapY.abs() > 15) {
      relativeTapX.abs() > relativeTapY.abs()
          ? user!.updateOrientation(GetDirection.fromXY(relativeTapX, 0))
          : user!.updateOrientation(GetDirection.fromXY(0, relativeTapY));
    }
  }

  /// Update [_gesturesElapsed]
  void inputControllerUpdate(double dt) {
    if (_gesturesDirection != null) _gesturesElapsed -= dt;
  }

  /// Handle keyboard input
  KeyEventResult keyboardHandler(
      RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event.logicalKey.keyLabel.contains('Audio Volume')) {
      return KeyEventResult.skipRemainingHandlers;
    } else if (event is! RawKeyDownEvent || overlays.isActive('loading')) {
      return KeyEventResult.ignored;
    }

    /// Handle input based on game state
    if (messageManager.isActive && messageManager.isShowingAQuestion) {
      /// Dialog menu (with question)
      if (_down(event)) {
        dialogBox.state?.selectNextAnswer();
      } else if (_up(event)) {
        dialogBox.state?.selectPreviousAnswer();
      } else if (_enter(event) &&
          (dialogBox.state?.isShowingAnswers ?? false)) {
        dialogBox.state?.chooseAnswer();
      }
    } else if (miniMapEnabled) {
      /// Mini map and World map
      if (_down(event)) {
        if (worldMapEnabled) {
          worldMapComponent?.movePointer(Direction.down);
        } else {
          camera.snapTo(Vector2(
              moveCamera(size.x, map.width, camera.position.x + size.x / 2),
              moveCamera(
                  size.y, map.height, camera.position.y + 50 + size.y / 2)));
        }
      } else if (_up(event)) {
        if (worldMapEnabled) {
          worldMapComponent?.movePointer(Direction.up);
        } else {
          camera.snapTo(Vector2(
              moveCamera(size.x, map.width, camera.position.x + size.x / 2),
              moveCamera(
                  size.y, map.height, camera.position.y - 50 + size.y / 2)));
        }
      } else if (_right(event)) {
        if (worldMapEnabled) {
          worldMapComponent?.movePointer(Direction.right);
        } else {
          camera.snapTo(Vector2(
              moveCamera(
                  size.x, map.width, camera.position.x + 50 + size.x / 2),
              moveCamera(size.y, map.height, camera.position.y + size.y / 2)));
        }
      } else if (_left(event)) {
        if (worldMapEnabled) {
          worldMapComponent?.movePointer(Direction.left);
        } else {
          camera.snapTo(Vector2(
              moveCamera(
                  size.x, map.width, camera.position.x - 50 + size.x / 2),
              moveCamera(size.y, map.height, camera.position.y + size.y / 2)));
        }
      } else if (_zoomIn(event)) {
        zoomMiniMap();
      } else if (_zoomOut(event)) {
        zoomMiniMap(out: true);
      } else if (_map(event) && !worldMapDisabled) {
        worldMap();
      } else if (_hint(event)) {
        hideHints = !hideHints;
      } else if (_enter(event)) {
        messageManager.isActive
            ? dialogBox.state?.next()
            : worldMapComponent?.selectPoint();
      } else if (_esc(event) && !messageManager.isActive) {
        miniMap();
      }
    } else if (overlays.isActive('backpackMenu') && !messageManager.isActive) {
      /// Backpack menu (without dialog)
      if (_down(event)) {
        backpackMenu?.state?.nextItem();
      } else if (_up(event)) {
        backpackMenu?.state?.previousItem();
      } else if (_enter(event)) {
        backpackMenu?.state?.chooseItem();
      } else if (_esc(event)) {
        overlays.remove('backpackMenu');
        resume();
      }
    } else if (overlays.isActive('backpackMenu') && messageManager.isActive) {
      /// Backpack menu (with dialog)
      if (_enter(event)) {
        dialogBox.state?.next();
      }
    } else if (overlays.isActive('shopMenu') && !messageManager.isActive) {
      /// Shop menu (without dialog)
      if (_down(event)) {
        shopMenu?.state?.nextItem();
      } else if (_up(event)) {
        shopMenu?.state?.previousItem();
      } else if (_enter(event)) {
        shopMenu?.state?.chooseItem();
      } else if (_esc(event)) {
        overlays.remove('shopMenu');
        resume();
      }
    } else if (overlays.isActive('shopMenu') && messageManager.isActive) {
      /// Shop menu (with dialog)
      if (_enter(event)) dialogBox.state?.next();
    } else if (overlays.isActive('pauseMenu')) {
      /// Pause menu
      if (_right(event)) {
        pauseMenu?.state?.selectNextOption();
      } else if (_left(event)) {
        pauseMenu?.state?.selectPreviousOption();
      } else if (_enter(event)) {
        pauseMenu?.state?.chooseOption();
      } else if (_esc(event)) {
        overlays.remove('pauseMenu');
        resume();
      }
    } else if (overlays.isActive('youLostMenu')) {
      /// You lost menu
      if (_enter(event) || _esc(event)) restartAfterEnd();
    } else if (!paused && !messageManager.isActive) {
      /// In-game
      if (_down(event)) {
        movePlayer(Direction.down);
      } else if (_up(event)) {
        movePlayer(Direction.up);
      } else if (_right(event)) {
        movePlayer(Direction.right);
      } else if (_left(event)) {
        movePlayer(Direction.left);
      } else if (_enter(event)) {
        user?.inspect();
      } else if (_leftOrientation(event)) {
        user!.updateOrientation(Direction.left);
      } else if (_upOrientation(event)) {
        user!.updateOrientation(Direction.up);
      } else if (_rightOrientation(event)) {
        user!.updateOrientation(Direction.right);
      } else if (_downOrientation(event)) {
        user!.updateOrientation(Direction.down);
      } else if (_punch(event)) {
        if (inBattle) user!.shoot(Weapons.punch.id);
      } else if (_snowball(event)) {
        if (inBattle && user!.hasWeaponId(Weapons.snowball.id)) {
          user!.shoot(Weapons.snowball.id);
        }
      } else if (_mine(event)) {
        if (inBattle && user!.hasWeaponId(Weapons.mine.id)) {
          user!.shoot(Weapons.mine.id);
        }
      } else if (_backpack(event)) {
        if (overlays.isActive('backpackButton') && isBackpackButtonActive) {
          backpack();
        }
      } else if (_milla(event)) {
        if (overlays.isActive('leafButton')) millaLeaf();
      } else if (_hint(event)) {
        hideHints = !hideHints;
      } else if (_map(event)) {
        if (worldMapEnabled || (!map.disableMiniMap && isMiniMapButtonActive)) {
          miniMap();
        }
      } else if (_esc(event)) {
        pause(mode: PauseMode.pause);
      }
    } else if (messageManager.isActive) {
      if (_enter(event)) {
        dialogBox.state?.next();
      } else if (_esc(event)) {
        pause(mode: PauseMode.pause);
      }
    }
    return KeyEventResult.handled;
  }
}

bool _down(RawKeyEvent e) => e.logicalKey == LogicalKeyboardKey.arrowDown;
bool _up(RawKeyEvent e) => e.logicalKey == LogicalKeyboardKey.arrowUp;
bool _right(RawKeyEvent e) => e.logicalKey == LogicalKeyboardKey.arrowRight;
bool _left(RawKeyEvent e) => e.logicalKey == LogicalKeyboardKey.arrowLeft;
bool _downOrientation(RawKeyEvent e) => e.logicalKey == LogicalKeyboardKey.keyS;
bool _upOrientation(RawKeyEvent e) => e.logicalKey == LogicalKeyboardKey.keyW;
bool _rightOrientation(RawKeyEvent e) =>
    e.logicalKey == LogicalKeyboardKey.keyD;
bool _leftOrientation(RawKeyEvent e) => e.logicalKey == LogicalKeyboardKey.keyA;
bool _enter(RawKeyEvent e) =>
    e.logicalKey == LogicalKeyboardKey.space ||
    e.logicalKey == LogicalKeyboardKey.keyX;
bool _esc(RawKeyEvent e) => e.logicalKey == LogicalKeyboardKey.escape;
bool _zoomIn(RawKeyEvent e) => e.logicalKey == LogicalKeyboardKey.add;
bool _zoomOut(RawKeyEvent e) => e.logicalKey == LogicalKeyboardKey.minus;
bool _map(RawKeyEvent e) => e.logicalKey == LogicalKeyboardKey.keyM;
bool _hint(RawKeyEvent e) => e.logicalKey == LogicalKeyboardKey.keyH;
bool _punch(RawKeyEvent e) => e.logicalKey == LogicalKeyboardKey.keyQ;
bool _snowball(RawKeyEvent e) => e.logicalKey == LogicalKeyboardKey.keyE;
bool _mine(RawKeyEvent e) => e.logicalKey == LogicalKeyboardKey.keyR;
bool _backpack(RawKeyEvent e) => e.logicalKey == LogicalKeyboardKey.keyB;
bool _milla(RawKeyEvent e) => e.logicalKey == LogicalKeyboardKey.keyL;
