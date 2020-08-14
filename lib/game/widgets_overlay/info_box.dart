import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:xeonjia/game/widgets_overlay/pause_menu.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/game_mode.dart';
import 'package:xeonjia/util/lifepoints_color.dart';

// Box that shows points and lifepoints
class StatusBox extends StatefulWidget {
  final _StatusBoxState state = _StatusBoxState();

  @override
  _StatusBoxState createState() => state;
}

class _StatusBoxState extends State<StatusBox> {
  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return InfoBox(
      opacity: 0.7,
      radius: game.config.mode == GameMode.tdm ? 10 : 30,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 15,
                ),
              ),
              Expanded(
                child: Container(
                  child: _PercentIndicator(
                    values: game.playerOne == null
                        ? [1, 0]
                        : [
                            game.playerOne.lifePoints.round(),
                            game.playerOne.initialLifePoints.round() -
                                game.playerOne.lifePoints.round()
                          ],
                    text: game.playerOne != null
                        ? game.playerOne.lifePoints.round().toString()
                        : '',
                    colors: [
                      lifePointsColor((game.playerOne?.lifePoints ?? 1) /
                          (game.playerOne?.initialLifePoints ?? 1)),
                      Colors.grey
                    ],
                  ),
                ),
              ),
              Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: const Icon(
                    Icons.pause,
                    color: Colors.white,
                    size: 18,
                  )),
            ],
          ),
          if (game.config.mode == GameMode.tdm) ...[
            Container(height: 10),
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: const Icon(
                    Icons.whatshot,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
                Expanded(
                  child: _PercentIndicator(
                    values: game.playerOne == null
                        ? [1, 1]
                        : [
                            max(game.teams.first.points, 1),
                            max(game.teams.last.points, 1),
                          ],
                    text: (game.teams.first.points.toString() ?? '') +
                        ' - ' +
                        (game.teams.last.points.toString() ?? ''),
                    colors: [
                      game.teams.first.color ?? '',
                      game.teams.last.color ?? '',
                    ],
                  ),
                ),
                Text(
                  '  ${game.remainingTime}',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// Top left container
class InfoBox extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double radius;
  InfoBox({this.opacity, this.child, this.radius = 30});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 6,
      left: 6,
      child: InkWell(
        onTap: () => game.pause(mode: PauseMode.pause),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          width: MediaQuery.of(context).size.width / 2.2,
          constraints: const BoxConstraints(maxWidth: 320),
          decoration: BoxDecoration(
              color: Colors.grey[800].withOpacity(opacity),
              borderRadius: BorderRadius.all(Radius.circular(radius))),
          child: child,
        ),
      ),
    );
  }
}

// Linear percent indicator
class _PercentIndicator extends StatelessWidget {
  final List<int> values;
  final String text;
  final List<Color> colors;
  final bool poisoned;

  _PercentIndicator({
    @required this.values,
    @required this.text,
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
                    height: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: colors[i].withOpacity(0.4),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                  ),
                ),
          ],
        ),
        Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
