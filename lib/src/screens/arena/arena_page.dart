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
  int _players = 3;
  GameMode _mode = GameMode.tdm;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('A R E N A'),
          centerTitle: true,
        ),
        body: ListView(children: <Widget>[
          ListTile(
              title: Text(
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
              title: Text(
                'Players',
                style: TextStyle(
                  fontSize: kTextFontSize,
                ),
              ),
              subtitle: const Text('Number of players'),
              trailing: DropdownButton<int>(
                value: _players,
                onChanged: (int newValue) {
                  setState(() {
                    _players = newValue;
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
        ]),
        floatingActionButton: Hero(
          tag: 'Play',
          child: PlayButton(
            mode: _mode,
            teamSize: _players,
            gradient: false,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
}
