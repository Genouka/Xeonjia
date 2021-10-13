import 'package:flutter/painting.dart';
import 'package:xeonjia/game/components/abstract_basic.dart';

// Show a text above the component for a few seconds
mixin TextAnimation on BasicComponent {
  final _seconds = 0.4;
  double _remainingSeconds;
  bool get _show => _text != null;
  String _text;

  // Show text for _seconds
  void showText(String text) {
    _text = text;
    _remainingSeconds = _seconds;
  }

  @override
  void update(double dt) {
    if (_show) {
      _remainingSeconds -= dt;
      if (_remainingSeconds <= 0) _text = null;
    } else {
      super.update(dt);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_show) _showTextAnimation(canvas);
  }

  void _showTextAnimation(Canvas canvas) {
    TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
            text: _text,
            style: const TextStyle(
                fontSize: 28,
                fontFamily: 'dd5x7',
                color: Color(0xFF000000),
                letterSpacing: 1.1,
                fontWeight: FontWeight.w600)))
      ..layout()
      ..paint(canvas, Offset(0, -55 * (0.2 + _seconds - _remainingSeconds)));
  }
}
