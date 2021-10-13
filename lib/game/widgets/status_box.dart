import 'package:flutter/material.dart';
import 'package:xeonjia/game/util/lifepoints_color.dart';
import 'package:xeonjia/game/widgets/info_box.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/game_mode.dart';

// Box that shows points and lifepoints
class StatusBox extends StatefulWidget {
  @override
  final GlobalKey<_StatusBoxState> key = GlobalKey();
  _StatusBoxState get state => key.currentState;

  @override
  _StatusBoxState createState() => _StatusBoxState();
}

class _StatusBoxState extends State<StatusBox> {
  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return game.playerOne == null || game.miniMapEnabled
        ? Container()
        : InfoBox(
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
                      child: _PercentIndicator(
                        values: [
                          game.playerOne.lifePoints,
                          game.playerOne.maxLifePoints
                        ],
                        text: game.playerOne.lifePoints.round().toString(),
                        colors: [
                          lifePointsColor(game.playerOne.lifePoints /
                              game.playerOne.maxLifePoints),
                          Colors.grey
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: const Icon(Icons.pause,
                          color: Colors.white, size: 18),
                    ),
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
                          values:
                              game.teams.first.points == game.teams.last.points
                                  ? [0.5, 1]
                                  : [
                                      game.teams.first.points.toDouble(),
                                      game.teams.last.points.toDouble() +
                                          game.teams.first.points,
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
                        style: Theme.of(context).textTheme.button,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
  }
}

// Linear percent indicator
class _PercentIndicator extends StatelessWidget {
  final List<double> values;
  final String text;
  final List<Color> colors;
  final bool poisoned;
  final double fillStop;

  _PercentIndicator({
    @required this.values,
    @required this.text,
    this.colors = const [Colors.lightBlue, Color(0xFF81D4FA)],
    this.poisoned = false,
  })  : assert(colors.length == 2),
        fillStop = values[0] / values[1];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        height: 24,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              colors[0].withOpacity(0.4),
              colors[0].withOpacity(0.4),
              colors[1].withOpacity(0.4),
              colors[1].withOpacity(0.4),
            ],
            stops: [0.0, fillStop, fillStop, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.contain,
          child: Text(
            text,
            style: Theme.of(context).textTheme.button,
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
