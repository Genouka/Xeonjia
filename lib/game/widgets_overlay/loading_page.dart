import 'package:flutter/material.dart';

// Page shown while the map is loading
class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Loading...\nPlease wait',
            style: TextStyle(
                color: Colors.white, fontSize: 32, letterSpacing: 1.4),
            textAlign: TextAlign.center,
          ),
          Container(height: 25),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
