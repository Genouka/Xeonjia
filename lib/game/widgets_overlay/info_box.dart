import 'dart:math';
import 'package:flutter/material.dart';

import 'package:xeonjia/game/widgets_overlay/pause_menu.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/game_mode.dart';
import 'package:xeonjia/util/lifepoints_color.dart';
import 'package:xeonjia/util/screen_dimension.dart';

class InfoBox extends StatefulWidget {
  final _InfoBoxState state = _InfoBoxState();

  @override
  _InfoBoxState createState() => state;
}

class _InfoBoxState extends State<InfoBox> {
  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      child: InkWell(
        onTap: () => game.pause(mode: PauseMode.pause),
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(15),
          width: screenSize.width / 2.2,
          decoration: BoxDecoration(
              color: Colors.grey[800].withOpacity(0.7),
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: Column(
            children: [
              Row(
                children: [
                  const Text('❤️  '),
                  Expanded(
                    child: _PercentIndicator(
                      values: game.playerOne == null
                          ? [1, 0]
                          : [
                              game.playerOne.lifePoints.round(),
                              game.playerOne.initialLifePoints.round() -
                                  game.playerOne.lifePoints.round()
                            ],
                      texts: [game.playerOne?.lifePoints?.toString() ?? ''],
                      colors: [
                        lifePointsColor((game.playerOne?.lifePoints ?? 1) /
                            (game.playerOne?.initialLifePoints ?? 1)),
                        Colors.grey
                      ],
                    ),
                  ),
                  const Text(' ▐ ▌', style: TextStyle(color: Colors.white))
                ],
              ),
              if (game.config.mode == GameMode.tdm) ...[
                Container(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _PercentIndicator(
                        values: game.playerOne == null
                            ? [1, 1]
                            : [
                                max(game.teams.first.points, 1),
                                max(game.teams.last.points, 1),
                              ],
                        texts: [
                          game.teams.first.points.toString() ?? '',
                          game.teams.last.points.toString() ?? ''
                        ],
                        colors: [
                          game.teams.first.color ?? '',
                          game.teams.last.color ?? '',
                        ],
                      ),
                    ),
                    Text(
                      '  ${game.remainingTime}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Linear percent indicator
class _PercentIndicator extends StatelessWidget {
  final List<int> values;
  final List<String> texts;
  final List<Color> colors;
  final bool poisoned;

  _PercentIndicator({
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
