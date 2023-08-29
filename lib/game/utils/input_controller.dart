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
  String get snowballButtonKey =>
      Platform.isLinux || Platform.isWindows ? 'E' : 'S';
  String get mineButtonKey =>
      Platform.isLinux || Platform.isWindows ? 'R' : 'M';

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
    if (!(settings.gestures || miniMapEnabled)) return;
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
  }

  /// Handle tap up event
  void tapUpHandler(int pointerId, TapUpInfo info) {
    messageManager.isActive
        ? dialogBox.state!.next()
        : _tapHandler(info.raw.globalPosition);
  }

  /// Handle tap gesture
  void _tapHandler(Offset position) {
    if (isPaused || !(user?.isMyTurn ?? false)) return;

    // Ignore tap near buttons (bottom right)
    var buttonSize =
        children.whereType<Button>().firstOrNull?.size ?? Vector2.zero();
    if (position.dx > canvasSize.x - buttonSize.x * (inBattle ? 4 : 2) &&
        position.dy > canvasSize.y - buttonSize.y * (inBattle ? 4 : 2)) {
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
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        dialogBox.state?.selectNextAnswer();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        dialogBox.state?.selectPreviousAnswer();
      } else if ((event.logicalKey == LogicalKeyboardKey.space ||
              event.logicalKey == LogicalKeyboardKey.keyX) &&
          (dialogBox.state?.isShowingAnswers ?? false)) {
        dialogBox.state?.chooseAnswer();
      }
    } else if (miniMapEnabled) {
      /// Mini map and World map
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (worldMapEnabled) {
          worldMapComponent?.movePointer(Direction.down);
        } else {
          camera.snapTo(Vector2(
              moveCamera(size.x, map.width, camera.position.x + size.x / 2),
              moveCamera(
                  size.y, map.height, camera.position.y + 50 + size.y / 2)));
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (worldMapEnabled) {
          worldMapComponent?.movePointer(Direction.up);
        } else {
          camera.snapTo(Vector2(
              moveCamera(size.x, map.width, camera.position.x + size.x / 2),
              moveCamera(
                  size.y, map.height, camera.position.y - 50 + size.y / 2)));
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (worldMapEnabled) {
          worldMapComponent?.movePointer(Direction.right);
        } else {
          camera.snapTo(Vector2(
              moveCamera(
                  size.x, map.width, camera.position.x + 50 + size.x / 2),
              moveCamera(size.y, map.height, camera.position.y + size.y / 2)));
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (worldMapEnabled) {
          worldMapComponent?.movePointer(Direction.left);
        } else {
          camera.snapTo(Vector2(
              moveCamera(
                  size.x, map.width, camera.position.x - 50 + size.x / 2),
              moveCamera(size.y, map.height, camera.position.y + size.y / 2)));
        }
      } else if (event.logicalKey == LogicalKeyboardKey.add) {
        zoomMiniMap();
      } else if (event.logicalKey == LogicalKeyboardKey.minus) {
        zoomMiniMap(out: true);
      } else if (event.logicalKey == LogicalKeyboardKey.keyM &&
          !worldMapDisabled) {
        worldMap();
      } else if (event.logicalKey == LogicalKeyboardKey.keyH) {
        hideHints = !hideHints;
      } else if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.keyX) {
        worldMapComponent?.selectPoint();
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        miniMap();
      }
    } else if (overlays.isActive('backpackMenu') && !messageManager.isActive) {
      /// Backpack menu (without dialog)
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        backpackMenu?.state?.nextItem();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        backpackMenu?.state?.previousItem();
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        backpackMenu?.state?.chooseItem();
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        overlays.remove('backpackMenu');
        resume();
      }
    } else if (overlays.isActive('backpackMenu') && messageManager.isActive) {
      /// Backpack menu (with dialog)
      if (event.logicalKey == LogicalKeyboardKey.space) {
        dialogBox.state?.next();
      }
    } else if (overlays.isActive('shopMenu') && !messageManager.isActive) {
      /// Shop menu (without dialog)
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        shopMenu?.state?.nextItem();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        shopMenu?.state?.previousItem();
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        shopMenu?.state?.chooseItem();
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        overlays.remove('shopMenu');
        resume();
      }
    } else if (overlays.isActive('shopMenu') && messageManager.isActive) {
      /// Shop menu (with dialog)
      if (event.logicalKey == LogicalKeyboardKey.space) {
        dialogBox.state?.next();
      }
    } else if (overlays.isActive('pauseMenu')) {
      /// Pause menu
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        pauseMenu?.state?.selectNextOption();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        pauseMenu?.state?.selectPreviousOption();
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        pauseMenu?.state?.chooseOption();
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        overlays.remove('pauseMenu');
        resume();
      }
    } else if (overlays.isActive('youLostMenu')) {
      /// You lost menu
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.escape) {
        restartAfterEnd();
      }
    } else if (!paused && !messageManager.isActive) {
      /// In-game
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        movePlayer(Direction.down);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        movePlayer(Direction.up);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        movePlayer(Direction.right);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        movePlayer(Direction.left);
      } else if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.keyX) {
        user?.inspect();
      } else if (event.logicalKey == LogicalKeyboardKey.keyA) {
        user!.updateOrientation(Direction.left);
      } else if (event.logicalKey == LogicalKeyboardKey.keyW) {
        user!.updateOrientation(Direction.up);
      } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
        user!.updateOrientation(Direction.right);
      } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
        user!.updateOrientation(Direction.down);
      } else if (event.logicalKey == LogicalKeyboardKey.keyQ) {
        if (inBattle) user!.shoot(Weapons.punch.id);
      } else if (event.logicalKey == LogicalKeyboardKey.keyE) {
        if (inBattle && user!.hasWeaponId(Weapons.snowball.id)) {
          user!.shoot(Weapons.snowball.id);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.keyR) {
        if (inBattle && user!.hasWeaponId(Weapons.mine.id)) {
          user!.shoot(Weapons.mine.id);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.keyB) {
        if (overlays.isActive('backpackButton') && isBackpackButtonActive) {
          backpack();
        }
      } else if (event.logicalKey == LogicalKeyboardKey.keyL) {
        if (overlays.isActive('leafButton')) millaLeaf();
      } else if (event.logicalKey == LogicalKeyboardKey.keyH) {
        hideHints = !hideHints;
      } else if (event.logicalKey == LogicalKeyboardKey.keyM) {
        if (worldMapEnabled || (!map.disableMiniMap && isMiniMapButtonActive)) {
          miniMap();
        }
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        pause(mode: PauseMode.pause);
      }
    } else if (messageManager.isActive) {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        dialogBox.state?.next();
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        pause(mode: PauseMode.pause);
      }
    }
    return KeyEventResult.handled;
  }
}
