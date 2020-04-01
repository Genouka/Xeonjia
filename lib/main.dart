import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:xeonjia/src/resources/global_variables.dart';
import 'package:xeonjia/src/util/settings.dart';
import 'package:xeonjia/src/xeonjia.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadStoredData().then((_) {
    // Set fullscreen
    if (settings.fullScreen) SystemChrome.setEnabledSystemUIOverlays([]);
  });
  return runApp(Xeonjia());
}
