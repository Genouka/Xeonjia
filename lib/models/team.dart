import 'package:flutter/material.dart';

import 'package:xeonjia/game/components/dynamic/character.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

// Group of players
class Team {
  // Team id
  final int id;

  // Team name
  final String name;

  // Team color
  final Color color;

  Team({@required this.id, this.name = 'Team', this.color = Colors.blue});

  // Team members
  List<CharacterComponent> get members =>
      game.players.where((player) => player.teamId == id).toList();

  // Team points acquired by friendly fire kills
  int basisPoints = 0;

  // Team points (basePoints + players points)
  int get points {
    var _points = 0;
    members.forEach((member) {
      _points += member.points;
    });
    return _points + basisPoints;
  }
}
