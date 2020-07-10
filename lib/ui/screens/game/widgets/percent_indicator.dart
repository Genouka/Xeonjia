import 'package:flutter/material.dart';

// Linear percent indicator used for top and bottom in-game bars
class PercentIndicator extends StatelessWidget {
  final List<int> values;
  final List<String> texts;
  final List<Color> colors;
  final bool poisoned;

  PercentIndicator({
    @required this.values,
    @required this.texts,
    this.colors = const [Colors.lightBlue, Color(0xFF81D4FA)],
    this.poisoned = false,
  }) : assert(colors.length == 2);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            for (var i in [0, 1])
              if (values[i] > 0)
                Expanded(
                  flex: values[i],
                  child: Container(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Center(
                      child: Text(
                        texts.length == 2 ? texts[i] : '',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    color: colors[i].withOpacity(0.4),
                  ),
                ),
          ],
        ),
        if (texts.length == 1)
          Center(
            child: Text(
              texts.single,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
            ),
          ),
      ],
    );
  }
}
