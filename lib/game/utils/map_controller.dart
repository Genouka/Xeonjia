import 'dart:math';

import 'package:xeonjia/game/xeonjia.dart';

/// Manage mini-map and world-map
extension MapController on XeonjiaGame {
  /// Open/Close mini-map
  void miniMap({bool? enable}) {
    miniMapEnabled = enable ?? !miniMapEnabled;
    if (miniMapEnabled) {
      zoomMiniMap(toValue: miniMapZoom, enable: true);
      pause(stopEngine: false, stopMusic: false);
      statusBox.state?.refresh();
      overlays.remove('mapNameBox');
      overlays.remove('skipButton');
      if (!inBattle) addCustomWidgetOverlay('mapNameBox', MapNameBox(this));
      overlays.remove('miniMapButton');
      overlays.remove('backpackButton');
      overlays.remove('leafButton');
      overlays.remove('rulesButton');
      overlays.remove('virtualDPad');
      addAll([zoomInButton, zoomOutButton]);
      miniMapActive = true;
    } else {
      zoomMiniMap(toValue: 1);
      if (worldMapEnabled) worldMap(); // remove the world map
      updateCamera(user!.x, user!.y);
      overlays.remove('mapNameBox');
      overlays.remove('miniMapButton');
      removeAll([zoomInButton, zoomOutButton]);
      overlays.add('backpackButton');
      overlays.remove('dialogBox');
      overlays.add('virtualDPad');
      overlays.add('dialogBox');
      overlays.remove('statusBox');
      overlays.add('statusBox');
      if (map.skipStory != null &&
          (currentEventLog['${map.id}-story'] ?? false) &&
          !(currentEventLog['${map.id}-safe'] ?? false)) {
        overlays.add('skipButton');
      }
      overlays.add(inBattle ? 'rulesButton' : 'leafButton');
      statusBox.state?.refresh();
      resume();
      miniMapActive = false;
    }
    overlays.add('miniMapButton');
  }

  /// Open/Close world-map
  void worldMap({bool? enable}) {
    worldMapEnabled = enable ?? !worldMapEnabled;
    if (worldMapEnabled) {
      zoomMiniMap(toValue: 1);
      worldMapComponent = WorldMap();
      this.add(worldMapComponent!);
      overlays.remove('mapNameBox');
      if (!(currentEventLog['howToWorldMap'] ?? false) && map.id != '1') {
        currentEventLog['howToWorldMap'] = true;
        setMessage(Message(
            this,
            'By clicking on the map I can go back to places I have already been.'
                .i18n,
            author: '/hero'));
      }
    } else {
      zoomMiniMap(toValue: 1);
      updateCamera(user!.x, user!.y);
      worldMapComponent?.removeFromParent();
      worldMapComponent = null;
      addCustomWidgetOverlay('mapNameBox', MapNameBox(this));
    }
  }

  /// Change mini-map zoom
  void zoomMiniMap({double? toValue, bool out = false, bool enable = false}) {
    var previousValue = enable ? 1 : miniMapZoom;
    var delta = 16 / componentSize;
    if (!out ||
        miniMapZoom * componentSize * map.width > canvasSize.x ||
        (worldMapEnabled
            ? miniMapZoom * componentSize * map.width * 0.7 > canvasSize.y
            : miniMapZoom * componentSize * map.height > canvasSize.y)) {
      miniMapZoom = toValue ??
          (out
              ? max(previousValue - delta, delta)
              : min(previousValue + delta, 2));
    }
    if (previousValue != miniMapZoom) {
      updateCamera(
          (camera.position.x + size.x / 2) * miniMapZoom / previousValue,
          (camera.position.y + size.y / 2) * miniMapZoom / previousValue);
    }
  }
}
