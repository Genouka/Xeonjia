import 'package:flutter/material.dart';
import 'package:xeonjia/game/utils/extensions.dart';
import 'package:xeonjia/game/widgets/boxes/info_box.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/utils/game_properties.dart';

// Box that shows points and lifepoints
class StatusBox extends StatefulWidget {
  StatusBox(this.gameRef);
  final XeonjiaGame gameRef;

  @override
  final GlobalKey<State<StatusBox>> key = GlobalKey();
  StatusBoxState? get state => key.currentState as StatusBoxState?;

  @override
  State<StatusBox> createState() => StatusBoxState();
}

class StatusBoxState extends State<StatusBox> {
  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.gameRef.playerOne == null || widget.gameRef.miniMapEnabled
        ? Container()
        : InfoBox(
            widget.gameRef,
            radius: widget.gameRef.config.mode == GameMode.tdm ? 10 : 30,
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
                          widget.gameRef.playerOne!.lifePoints,
                          widget.gameRef.playerOne!.maxLifePoints
                        ],
                        text: widget.gameRef.playerOne!.lifePoints
                            .round()
                            .toString(),
                        colors: [
                          MyColors.lifePointsColor(
                              widget.gameRef.playerOne!.lifePoints /
                                  widget.gameRef.playerOne!.maxLifePoints),
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
                if (widget.gameRef.config.mode == GameMode.tdm) ...[
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
                          values: widget.gameRef.teams!.first.points ==
                                  widget.gameRef.teams!.last.points
                              ? [0.5, 1]
                              : [
                                  widget.gameRef.teams!.first.points.toDouble(),
                                  widget.gameRef.teams!.last.points.toDouble() +
                                      widget.gameRef.teams!.first.points,
                                ],
                          text: widget.gameRef.teams!.first.points.toString() +
                              ' - ' +
                              widget.gameRef.teams!.last.points.toString(),
                          colors: [
                            widget.gameRef.teams!.first.color,
                            widget.gameRef.teams!.last.color,
                          ],
                        ),
                      ),
                      Text(
                        '  ${widget.gameRef.remainingTime}',
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
  _PercentIndicator({
    required this.values,
    required this.text,
    this.colors = const [Colors.lightBlue, Color(0xFF81D4FA)],
    // ignore: unused_element
    this.poisoned = false,
  })  : assert(colors.length == 2),
        fillStop = values[0] / values[1];

  final List<double> values;
  final String text;
  final List<Color> colors;
  final bool poisoned;
  final double fillStop;

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
