import 'package:flutter/material.dart';

import 'package:xeonjia/i18n/game.i18n.dart';

// Page shown while the map is loading
class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Loading...\nPlease wait'.i18n,
            style: const TextStyle(
                color: Colors.white, fontSize: 48, letterSpacing: 1.2),
            textAlign: TextAlign.center,
          ),
          Container(height: 25),
          const CircularProgressIndicator(backgroundColor: Colors.white),
        ],
      ),
    );
  }
}
