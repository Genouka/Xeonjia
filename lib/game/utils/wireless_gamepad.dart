import 'package:flutter/services.dart';
import 'package:xeonjia/game/utils/direction.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

// Manage a wireless gamepad
extension WirelessGamepad on XeonjiaGame {
  void initGamepad() async {
    gamepad ??= (FlameGamepad()
      ..setListener((evtType, key) {
        switch (key) {
          case GAMEPAD_DPAD_UP:
            movePlayer(Direction.up);
            break;
          case GAMEPAD_DPAD_DOWN:
            movePlayer(Direction.down);
            break;
          case GAMEPAD_DPAD_RIGHT:
            movePlayer(Direction.right);
            break;
          case GAMEPAD_DPAD_LEFT:
            movePlayer(Direction.left);
            break;
          case GAMEPAD_BUTTON_A:
            playerOne!.inspect();
            break;
          case GAMEPAD_BUTTON_B:
            playerOne!.shoot();
            break;
          case GAMEPAD_BUTTON_X:
            playerOne!.shoot();
            break;
          case GAMEPAD_BUTTON_Y:
            playerOne!.shoot();
            break;
          case GAMEPAD_BUTTON_L1:
            playerOne!.nextWeapon();
            break;
          case GAMEPAD_BUTTON_L2:
            playerOne!.nextWeapon();
            break;
          case GAMEPAD_BUTTON_R1:
            playerOne!.nextWeapon();
            break;
          case GAMEPAD_BUTTON_R2:
            playerOne!.nextWeapon();
            break;
          case GAMEPAD_BUTTON_START:
            break;
        }
      }));
  }
}

// flame_gamepad (edited)
// Original repo: https://github.com/flame-engine/flame_gamepad/

/* MIT License
*
* Copyright (c) 2019 Fire Slime Games
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

// ignore_for_file: constant_identifier_names
const GAMEPAD_BUTTON_UP = 'UP';
const GAMEPAD_BUTTON_DOWN = 'DOWN';

const GAMEPAD_DPAD_UP = 'UP';
const GAMEPAD_DPAD_DOWN = 'DOWN';
const GAMEPAD_DPAD_LEFT = 'LEFT';
const GAMEPAD_DPAD_RIGHT = 'RIGHT';

const GAMEPAD_BUTTON_A = 'A';
const GAMEPAD_BUTTON_B = 'B';
const GAMEPAD_BUTTON_X = 'X';
const GAMEPAD_BUTTON_Y = 'Y';

const GAMEPAD_BUTTON_L1 = 'L1';
const GAMEPAD_BUTTON_L2 = 'L2';

const GAMEPAD_BUTTON_R1 = 'R1';
const GAMEPAD_BUTTON_R2 = 'R2';

const GAMEPAD_BUTTON_START = 'START';
const GAMEPAD_BUTTON_SELECT = 'SELECT';

typedef KeyListener = void Function(RawKeyEvent event);
typedef GamepadListener = void Function(String evtType, String key);

const ANDROID_MAPPING = {
  19: GAMEPAD_DPAD_UP,
  20: GAMEPAD_DPAD_DOWN,
  21: GAMEPAD_DPAD_LEFT,
  22: GAMEPAD_DPAD_RIGHT,
  96: GAMEPAD_BUTTON_A,
  97: GAMEPAD_BUTTON_B,
  99: GAMEPAD_BUTTON_X,
  100: GAMEPAD_BUTTON_Y,
  102: GAMEPAD_BUTTON_L1,
  103: GAMEPAD_BUTTON_R1,
  104: GAMEPAD_BUTTON_L2,
  105: GAMEPAD_BUTTON_R2,
  108: GAMEPAD_BUTTON_START,
  109: GAMEPAD_BUTTON_SELECT
};

class FlameGamepad {
  late KeyListener listener;

  static Future<bool> get isGamepadConnected async {
    final isConnected = await _channel.invokeMethod('isGamepadConnected');
    return isConnected;
  }

  static const MethodChannel _channel = MethodChannel('flame_gamepad');

  void setListener(GamepadListener gamepadListener) {
    listener = (RawKeyEvent e) {
      final evtType =
          e is RawKeyDownEvent ? GAMEPAD_BUTTON_DOWN : GAMEPAD_BUTTON_UP;

      if (e.data is RawKeyEventDataAndroid) {
        final androidEvent = e.data as RawKeyEventDataAndroid;

        final key = ANDROID_MAPPING[androidEvent.keyCode];
        if (key != null) gamepadListener(evtType, key);
      }
    };
    RawKeyboard.instance.addListener(listener);
  }

  void removeListener() {
    RawKeyboard.instance.removeListener(listener);
  }
}
