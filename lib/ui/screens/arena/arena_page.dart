import 'package:flutter/material.dart';
import 'package:xeonjia/ui/screens/arena/widgets/help_dialog.dart';
import 'package:xeonjia/ui/screens/arena/widgets/play_button.dart';
import 'package:xeonjia/ui/screens/game/game_page.dart';
import 'package:xeonjia/utils/game_properties.dart';
import 'package:xeonjia/utils/i18n.dart';

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

// Map names
Map<int, String> mapNames = {
  0: 'Kontrast',
  1: 'Stopovers',
  2: 'Flussi',
};

// Difficulty
// i18n: 'Easy'.i18n, 'Medium'.i18n, 'Hard'.i18n
Map<int, String> difficultyNames = {
  3: 'Easy',
  4: 'Medium',
  5: 'Hard',
};

class ArenaPage extends StatefulWidget {
  @override
  State<ArenaPage> createState() => _ArenaPageState();
}

class _ArenaPageState extends State<ArenaPage> {
  final List<int> _teamSizeOptions = [3, 4, 5, 6, 7];
  final List<int> _maxTimeOptions = [2, 3, 4, 5];
  final List<int> _maxPointsOptions = [1000, 1500, 2000, 2500];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multiplayer'.i18n.toUpperCase()),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showDialog(context: context, builder: helpDialog),
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
              onChanged: (int? newValue) =>
                  setState(() => _config.mapId = newValue!),
              items: mapNames.keys
                  .map<DropdownMenuItem<int>>(
                    (int value) => DropdownMenuItem<int>(
                      value: value,
                      child: Text(mapNames[value]!),
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
              onChanged: (int? newValue) =>
                  setState(() => _config.difficulty = newValue!),
              items: difficultyNames.keys
                  .map<DropdownMenuItem<int>>(
                    (int value) => DropdownMenuItem<int>(
                      value: value,
                      child: Text(difficultyNames[value]!.i18n),
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
              onChanged: (int? newValue) =>
                  setState(() => _config.maxPoints = newValue!),
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
              onChanged: (int? newValue) =>
                  setState(() => _config.maxTime = newValue!),
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
              onChanged: (int? newValue) =>
                  setState(() => _config.teamSize = newValue!),
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
            subtitle: Text('If enabled, players can hit their teammates'.i18n),
            value: _config.friendlyFire,
            onChanged: (newValue) =>
                setState(() => _config.friendlyFire = newValue!),
          ),
        ],
      ),
      floatingActionButton: PlayButton(() => GamePage(_config)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
