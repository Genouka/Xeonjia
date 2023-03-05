import 'package:flame_audio/flame_audio.dart';
import 'package:xeonjia/game/utils/sfx.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/utils/local_data_controller.dart';

extension AudioController on XeonjiaGame {
  /// Start the background music
  void playBackgroundMusic({String? custom}) {
    if (!settings.backgroundMusic || messageManager.hideMap) return;
    customBgm = custom;
    String newBgm = custom ?? map.music ?? 'route';
    if (newBgm == 'none') {
      FlameAudio.bgm.stop();
      return;
    }
    var currentMap = map.id;
    if (newBgm == currentBgm) {
      // Workaround to "fix" performance degradation caused by sound effects.
      // How to reproduce: play a sfx (e.g. Sfx.dialog) multiple times in the
      // same room (~50 times or more).
      // With this workaround the performance returns to normal with each room
      // change. Don't know why.
      // AudioPool, clearing cache, and other solutions didn't work.
      FlameAudio.bgm.pause().then((_) {
        if (!paused && currentMap == map.id) FlameAudio.bgm.resume();
      });
      return;
    }
    currentBgm = newBgm;
    FlameAudio.bgm.stop();
    Future.delayed(const Duration(seconds: 1), () {
      if (!paused && currentMap == map.id) {
        FlameAudio.bgm.play('bgm/' + currentBgm! + '.oga');
      }
    });
  }

  /// Play sound effect
  void playSound(Sfx sfx, {double volume = 0.5}) {
    if (settings.soundEffects) FlameAudio.play(sfx.fileName, volume: volume);
  }
}
