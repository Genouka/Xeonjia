import 'package:flutter/material.dart';

// Linear percent indicator used for top and bottom in-game bars
class PercentIndicator extends StatefulWidget {
  final VoidCallback onTap;
  PercentIndicator({this.onTap});

  final _PercentIndicatorState state = _PercentIndicatorState();

  @override
  _PercentIndicatorState createState() => state;
}

class _PercentIndicatorState extends State<PercentIndicator> {
  int firstValue = 0;
  int secondValue = 0;
  String firstText = '';
  String secondText = '';
  Color firstColor = Colors.lightBlue;
  Color secondColor = Colors.lightBlue[200];
  bool poisoned = false;
  String text = '';

  void refresh({
    @required double percent,
    @required String text,
    bool poisoned = false,
  }) {
    this.poisoned = poisoned;
    firstValue = (percent * 100).round();
    secondValue = 100 - firstValue;
    _updateColor();
    this.text = text;
    if (mounted) setState(() {});
  }

  void _updateColor() {
    if (poisoned) {
      firstColor = const Color(0xFF7B1FA2);
    } else if (firstValue < 15) {
      firstColor = const Color(0xFFBF360C);
    } else if (firstValue < 30) {
      firstColor = const Color(0xFFF57F17);
    } else {
      firstColor = const Color(0xFF0288D1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Stack(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              if (firstValue != 0)
                Expanded(
                  flex: firstValue,
                  child: Container(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Center(
                      child: Text(
                        firstText,
                        style: const TextStyle(fontSize: 18),
                        maxLines: 1,
                      ),
                    ),
                    color: firstColor.withOpacity(0.4),
                  ),
                ),
              if (secondValue > 0)
                Expanded(
                  flex: secondValue,
                  child: Container(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Center(
                      child: Text(
                        secondText,
                        style: const TextStyle(fontSize: 18),
                        maxLines: 1,
                      ),
                    ),
                    color: secondColor.withOpacity(0.4),
                  ),
                ),
            ],
          ),
          Center(
            child: Text(
              text,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
