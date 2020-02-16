import 'package:flutter/material.dart';

import 'package:xeonjia/src/resources/global_variables.dart';
import 'package:xeonjia/src/widgets/basic.dart';

class ArenaPage extends StatefulWidget {
  static _ArenaPageState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<_ArenaPageState>());

  @override
  _ArenaPageState createState() => _ArenaPageState();
}

class _ArenaPageState extends State<ArenaPage> {
  GameMode _mode = GameMode.tdm;
  int _teamSize = 3;
  bool _friendlyFire = false;

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
          CheckboxListTile(
              title: const Text(
                'Friendly Fire',
                style: TextStyle(
                  fontSize: kTextFontSize,
                ),
              ),
              activeColor: Colors.blueGrey,
              subtitle: const Text(
                  'If enabled, players can hit their teammates'),
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
            mode: _mode,
            teamSize: _teamSize,
            friendlyFire: _friendlyFire,
            gradient: false,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
}
