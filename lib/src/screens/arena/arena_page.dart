import 'package:flutter/material.dart';

import 'package:xeonjia/src/resources/global_variables.dart';
import 'package:xeonjia/src/screens/arena/resources/maps.dart';
import 'package:xeonjia/src/screens/game/game_page.dart';
import 'package:xeonjia/src/widgets/basic.dart';

class ArenaPage extends StatefulWidget {
  static _ArenaPageState of(BuildContext context) =>
      context.findAncestorStateOfType();

  @override
  _ArenaPageState createState() => _ArenaPageState();
}

class _ArenaPageState extends State<ArenaPage> {
  GameMode _mode = GameMode.tdm;
  int _teamSize = 3;
  int _maxTime = 3;
  int _maxPoints = 1500;
  int _mapId = 0;
  bool _friendlyFire = true;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('A R E N A'),
          centerTitle: true,
        ),
        body: ListView(children: <Widget>[
          ListTile(
              title: const Text(
                'Mode',
                style: TextStyle(
                  fontSize: kTextFontSize,
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
                            ))
                    .toList(),
              )),
          ListTile(
              title: const Text(
                'Players',
                style: TextStyle(
                  fontSize: kTextFontSize,
                ),
              ),
              subtitle: const Text('Number of players'),
              trailing: DropdownButton<int>(
                value: _teamSize,
                onChanged: (int newValue) {
                  setState(() {
                    _teamSize = newValue;
                  });
                },
                items: [3, 4, 5, 6]
                    .map<DropdownMenuItem<int>>(
                        (int value) => DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString()),
                            ))
                    .toList(),
              )),
          ListTile(
              title: const Text(
                'Time available',
                style: TextStyle(
                  fontSize: kTextFontSize,
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
                items: [3, 4, 5]
                    .map<DropdownMenuItem<int>>(
                        (int value) => DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString()),
                            ))
                    .toList(),
              )),
          ListTile(
              title: const Text(
                'Points to score',
                style: TextStyle(
                  fontSize: kTextFontSize,
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
                items: [1500, 2000, 2500]
                    .map<DropdownMenuItem<int>>(
                        (int value) => DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString()),
                            ))
                    .toList(),
              )),
          ListTile(
              title: const Text(
                'Map',
                style: TextStyle(
                  fontSize: kTextFontSize,
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
                items: [0, 1]
                    .map<DropdownMenuItem<int>>(
                        (int value) => DropdownMenuItem<int>(
                              value: value,
                              child: Text(mapNames[value]),
                            ))
                    .toList(),
              )),
          CheckboxListTile(
              title: const Text(
                'Friendly Fire',
                style: TextStyle(
                  fontSize: kTextFontSize,
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
              }),
        ]),
        floatingActionButton: Hero(
          tag: 'Play',
          child: PlayButton(
            page: GamePage(
              _mode,
              teamSize: _teamSize,
              maxTime: _maxTime * 60,
              maxPoints: _maxPoints,
              mapId: _mapId,
              friendlyFire: _friendlyFire,
            ),
            gradient: false,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
}
