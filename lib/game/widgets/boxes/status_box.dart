import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia.dart';

/// Box that shows HP
class StatusBox extends StatefulWidget {
  StatusBox(this.game);
  final XeonjiaGame game;

  @override
  final GlobalKey<State<StatusBox>> key = GlobalKey();
  StatusBoxState? get state => key.currentState as StatusBoxState?;

  @override
  State<StatusBox> createState() => StatusBoxState();
}

class StatusBoxState extends State<StatusBox> {
  void refresh([CharacterComponent? c]) {
    if (mounted) setState(() => character = c);
  }

  /// StatusBox shows HP of this character
  CharacterComponent? character;
  CharacterComponent? get shownCharacter => character ?? widget.game.user;

  @override
  Widget build(BuildContext context) {
    return widget.game.playerOne?.isLoaded != true ||
            widget.game.miniMapEnabled ||
            widget.game.messageManager.hideMap
        ? Container()
        : InfoBox(
            onTap: () => widget.game.pause(mode: PauseMode.pause),
            radius: 30,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        (shownCharacter?.isPlayerOne ?? true)
                            ? Icons.favorite
                            : (shownCharacter?.name == 'milla')
                            ? Icons.energy_savings_leaf
                            : Icons.person,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                    Expanded(
                      child: _PercentIndicator(
                        values: [shownCharacter!.hp, shownCharacter!.maxHP],
                        text: shownCharacter!.hp.round().toString(),
                        colors: [
                          MyColors.healthPointsColor(
                            shownCharacter!.hp / shownCharacter!.maxHP,
                          ),
                          Colors.grey,
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: const Icon(
                        Icons.pause,
                        color: Colors.white,
                        size: 18,
                      ),
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
  }) : assert(colors.length == 2),
       fillStop = values[0] / values[1];

  final List<double> values;
  final String text;
  final List<Color> colors;
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
              colors[0].withAlpha((255.0 * 0.4).round()),
              colors[0].withAlpha((255.0 * 0.4).round()),
              colors[1].withAlpha((255.0 * 0.4).round()),
              colors[1].withAlpha((255.0 * 0.4).round()),
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
