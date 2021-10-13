import 'package:flutter/material.dart';
import 'package:xeonjia/i18n/ui.i18n.dart';
import 'package:xeonjia/models/game_mode.dart';
import 'package:xeonjia/models/match_config.dart';
import 'package:xeonjia/ui/screens/arena/resources/maps.dart';
import 'package:xeonjia/ui/screens/arena/widgets/help_dialog.dart';
import 'package:xeonjia/ui/screens/arena/widgets/play_button.dart';
import 'package:xeonjia/ui/screens/game/game_page.dart';

// Match settings
MatchConfig _config = MatchConfig(
  GameMode.tdm,
  teamSize: 5,
  maxTime: 180,
  maxPoints: 1500,
  mapId: 0,
  difficulty: 4,
  friendlyFire: true,
);

class ArenaPage extends StatefulWidget {
  static _ArenaPageState of(BuildContext context) =>
      context.findAncestorStateOfType();

  @override
  _ArenaPageState createState() => _ArenaPageState();
}

class _ArenaPageState extends State<ArenaPage> {
  // List of possible options
  final _teamSizeOptions = <int>[3, 4, 5, 6, 7];
  final _maxTimeOptions = <int>[2, 3, 4, 5];
  final _maxPointsOptions = <int>[1000, 1500, 2000, 2500];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Multiplayer'.i18n.toUpperCase()),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => helpDialog(context),
                );
              },
            )
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 70),
          children: <Widget>[
            ListTile(
              title: Text('Map'.i18n, style: const TextStyle(fontSize: 20)),
              subtitle: Text('Place to play'.i18n),
              trailing: DropdownButton<int>(
                value: _config.mapId,
                onChanged: (int newValue) {
                  setState(() {
                    _config.mapId = newValue;
                  });
                },
                items: mapNames.keys
                    .map<DropdownMenuItem<int>>(
                      (int value) => DropdownMenuItem<int>(
                        value: value,
                        child: Text(mapNames[value]),
                      ),
                    )
                    .toList(),
              ),
            ),
            ListTile(
              title:
                  Text('Difficulty'.i18n, style: const TextStyle(fontSize: 20)),
              subtitle: Text('Match difficulty'.i18n),
              trailing: DropdownButton<int>(
                value: _config.difficulty,
                onChanged: (int newValue) {
                  setState(() {
                    _config.difficulty = newValue;
                  });
                },
                items: difficultyNames.keys
                    .map<DropdownMenuItem<int>>(
                      (int value) => DropdownMenuItem<int>(
                        value: value,
                        child: Text(difficultyNames[value].i18n),
                      ),
                    )
                    .toList(),
              ),
            ),
            ListTile(
              title: Text(
                'Points required'.i18n,
                style: const TextStyle(fontSize: 20),
              ),
              subtitle: Text('Points needed to win'.i18n),
              trailing: DropdownButton<int>(
                value: _config.maxPoints,
                onChanged: (int newValue) {
                  setState(() {
                    _config.maxPoints = newValue;
                  });
                },
                items: _maxPointsOptions
                    .map<DropdownMenuItem<int>>(
                      (int value) => DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      ),
                    )
                    .toList(),
              ),
            ),
            ListTile(
              title: Text(
                'Time available'.i18n,
                style: const TextStyle(fontSize: 20),
              ),
              subtitle: Text('Maximum time for a match (minutes)'.i18n),
              trailing: DropdownButton<int>(
                value: _config.maxTime,
                onChanged: (int newValue) {
                  setState(() {
                    _config.maxTime = newValue;
                  });
                },
                items: _maxTimeOptions
                    .map<DropdownMenuItem<int>>(
                      (int value) => DropdownMenuItem<int>(
                        value: value * 60,
                        child: Text(value.toString()),
                      ),
                    )
                    .toList(),
              ),
            ),
            ListTile(
              title: Text('Players'.i18n, style: const TextStyle(fontSize: 20)),
              subtitle: Text('Number of players per team'.i18n),
              trailing: DropdownButton<int>(
                value: _config.teamSize,
                onChanged: (int newValue) {
                  setState(() {
                    _config.teamSize = newValue;
                  });
                },
                items: _teamSizeOptions
                    .map<DropdownMenuItem<int>>(
                      (int value) => DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      ),
                    )
                    .toList(),
              ),
            ),
            CheckboxListTile(
              title: Text(
                'Friendly Fire'.i18n,
                style: const TextStyle(fontSize: 20),
              ),
              activeColor: Colors.blueGrey,
              subtitle:
                  Text('If enabled, players can hit their teammates'.i18n),
              value: _config.friendlyFire,
              onChanged: (_newValue) {
                setState(() {
                  _config.friendlyFire = _newValue;
                });
              },
            ),
          ],
        ),
        floatingActionButton: PlayButton(() => GamePage(_config)),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
}
