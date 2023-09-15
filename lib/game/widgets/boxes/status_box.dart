import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia.dart';

/// Box that shows HP
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
    return widget.gameRef.playerOne?.isLoaded != true ||
            widget.gameRef.miniMapEnabled ||
            widget.gameRef.messageManager.hideMap
        ? Container()
        : InfoBox(
            onTap: () => widget.gameRef.pause(mode: PauseMode.pause),
            radius: 30,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        (widget.gameRef.user?.isPlayerOne ?? true)
                            ? Icons.favorite
                            : (widget.gameRef.user?.name == 'milla')
                                ? Icons.energy_savings_leaf
                                : Icons.person,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                    Expanded(
                      child: _PercentIndicator(
                        values: [
                          widget.gameRef.user!.hp,
                          widget.gameRef.user!.maxHP,
                        ],
                        text: widget.gameRef.user!.hp.round().toString(),
                        colors: [
                          MyColors.healthPointsColor(widget.gameRef.user!.hp /
                              widget.gameRef.user!.maxHP),
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
    required this.colors,
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
            style: Theme.of(context).textTheme.labelLarge,
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
