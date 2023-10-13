import 'package:flame_audio/flame_audio.dart';
import 'package:xeonjia/game/xeonjia.dart';

extension AudioController on XeonjiaGame {
  /// Start the background music
  void playBackgroundMusic({String? custom}) {
    if (!settings.backgroundMusic || messageManager.hideMap) return;
    customBgm = custom;
    String newBgm = custom ?? map.music ?? 'route';
    if (newBgm == 'none') {
      bgm?.stop();
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
      bgm?.pause().then((_) {
        if (!paused && currentMap == map.id) bgm?.resume();
      });
      return;
    }
    currentBgm = newBgm;
    bgm?.stop();
    Future.delayed(const Duration(seconds: 1), () {
      if (!paused && currentMap == map.id) {
        bgm?.play('bgm/' + currentBgm! + '.oga');
      }
    });
  }

  /// Play sound effect
  void playSound(Sfx sfx, {double volume = 0.5}) {
    if (settings.soundEffects) FlameAudio.play(sfx.fileName, volume: volume);
  }
}
