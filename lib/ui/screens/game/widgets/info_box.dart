import 'dart:math';
import 'package:flutter/material.dart';

import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/game_mode.dart';
import 'package:xeonjia/ui/screens/game/widgets/percent_indicator.dart';
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
        onTap: game.pauseDialog,
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
                    child: PercentIndicator(
                      values: playerOne == null
                          ? [1, 0]
                          : [
                              playerOne.lifePoints.round(),
                              playerOne.initialLifePoints.round() -
                                  playerOne.lifePoints.round()
                            ],
                      texts: [playerOne?.lifePoints?.toString() ?? ''],
                      colors: [
                        lifePointsColor((playerOne?.lifePoints ?? 1) /
                            (playerOne?.initialLifePoints ?? 1)),
                        Colors.grey
                      ],
                    ),
                  ),
                  const Text(' ▐ ▌', style: TextStyle(color: Colors.white))
                ],
              ),
              if (game.mode == GameMode.tdm) ...[
                Container(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: PercentIndicator(
                        values: playerOne == null
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
                      '  ' + (game.remainingTime ?? game.maxTime).toString(),
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
