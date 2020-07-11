import 'package:flutter/material.dart';
import 'package:xeonjia/models/game_mode.dart';

import 'package:xeonjia/ui/screens/arena/resources/maps.dart';
import 'package:xeonjia/ui/screens/arena/widgets/play_button.dart';
import 'package:xeonjia/ui/screens/game/game_page.dart';

// List of possible options
const List<int> _teamSizeOptions = [3, 4, 5, 6, 7];
const List<int> _maxTimeOptions = [2, 3, 4, 5];
const List<int> _maxPointsOptions = [1000, 1500, 2000, 2500];

// Match settings
GameMode _mode = GameMode.tdm;
int _teamSize = 5;
int _maxTime = 3;
int _maxPoints = 1500;
int _mapId = 0;
int _difficulty = 4;
bool _friendlyFire = true;

class ArenaPage extends StatefulWidget {
  static _ArenaPageState of(BuildContext context) =>
      context.findAncestorStateOfType();

  @override
  _ArenaPageState createState() => _ArenaPageState();
}

class _ArenaPageState extends State<ArenaPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('ARENA'),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 70),
          children: <Widget>[
            ListTile(
              title: const Text(
                'Mode',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              subtitle: const Text('Game mode'),
              trailing: DropdownButton<GameMode>(
                value: _mode,
                onChanged: (GameMode newValue) {
                  setState(() {
                    _mode = newValue;
                  });
                },
                items: [GameMode.tdm]
                    .map<DropdownMenuItem<GameMode>>(
                      (GameMode value) => DropdownMenuItem<GameMode>(
                        value: value,
                        child: Text(modeNames[value]),
                      ),
                    )
                    .toList(),
              ),
            ),
            ListTile(
              title: const Text(
                'Map',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              subtitle: const Text('Place to play'),
              trailing: DropdownButton<int>(
                value: _mapId,
                onChanged: (int newValue) {
                  setState(() {
                    _mapId = newValue;
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
              title: const Text(
                'Difficulty',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              subtitle: const Text('Match difficulty'),
              trailing: DropdownButton<int>(
                value: _difficulty,
                onChanged: (int newValue) {
                  setState(() {
                    _difficulty = newValue;
                  });
                },
                items: difficultyNames.keys
                    .map<DropdownMenuItem<int>>(
                      (int value) => DropdownMenuItem<int>(
                        value: value,
                        child: Text(difficultyNames[value]),
                      ),
                    )
                    .toList(),
              ),
            ),
            ListTile(
              title: const Text(
                'Points required',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              subtitle: const Text('Points needed to win'),
              trailing: DropdownButton<int>(
                value: _maxPoints,
                onChanged: (int newValue) {
                  setState(() {
                    _maxPoints = newValue;
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
              title: const Text(
                'Time available',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              subtitle: const Text('Maximum time for a match (minutes)'),
              trailing: DropdownButton<int>(
                value: _maxTime,
                onChanged: (int newValue) {
                  setState(() {
                    _maxTime = newValue;
                  });
                },
                items: _maxTimeOptions
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
              title: const Text(
                'Players',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              subtitle: const Text('Number of players per team'),
              trailing: DropdownButton<int>(
                value: _teamSize,
                onChanged: (int newValue) {
                  setState(() {
                    _teamSize = newValue;
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
              title: const Text(
                'Friendly Fire',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              activeColor: Colors.blueGrey,
              subtitle:
                  const Text('If enabled, players can hit their teammates'),
              value: _friendlyFire,
              onChanged: (_newValue) {
                setState(() {
                  _friendlyFire = _newValue;
                });
              },
            ),
          ],
        ),
        floatingActionButton: PlayButton(
          GamePage(
            _mode,
            teamSize: _teamSize,
            maxTime: _maxTime * 60,
            maxPoints: _maxPoints,
            mapId: _mapId,
            difficulty: _difficulty,
            friendlyFire: _friendlyFire,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
}
