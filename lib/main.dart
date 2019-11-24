import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:xeonjia/src/resources/global_variables.dart';
import 'package:xeonjia/src/util/local_data_controller.dart';
import 'package:xeonjia/src/xeonjia.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  loadStoredData().then((v) {
    // Set fullscreen
    if (settings.fullScreen) SystemChrome.setEnabledSystemUIOverlays([]);
  });
  return runApp(Xeonjia());
}
